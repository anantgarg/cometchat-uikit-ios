//
//
//

import Combine
import CometChatSDK
import Foundation
import SwiftUI

public class UsersViewModelSwiftUI: ObservableObject {
    @Published var users: [[User]] = .init()
    @Published var filteredUsers: [User] = []
    @Published var selectedUsers: [User] = []
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    @Published var errorMessage: String = ""

    private var userRequest: UsersRequest?
    private var filterUserRequest: UsersRequest?
    var userRequestBuilder: UsersRequest.UsersRequestBuilder
    private var listenerRandomID = Date().timeIntervalSince1970

    var isFetching = false
    var isFetchedAll = false
    var isSearching: Bool = false
    var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                fetchUsers()
            }
        }
    }

    var onError: ((CometChatException) -> Void)?

    public init(userRequestBuilder: UsersRequest.UsersRequestBuilder = UsersBuilder.getDefaultRequestBuilder()) {
        self.userRequestBuilder = userRequestBuilder
        userRequest = userRequestBuilder.build()
    }

    deinit {
        disconnect()
    }

    func fetchUsers() {
        if isRefresh {
            isFetchedAll = false
            userRequestBuilder = UsersBuilder.getDefaultRequestBuilder()
            userRequest = userRequestBuilder.build()
        }

        guard let userRequest else { return }
        if isFetchedAll { return }

        isLoading = true
        isFetching = true

        UsersBuilder.fetchUsers(userRequest: userRequest) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                self.isFetching = false

                switch result {
                case let .success(fetchedUsers):
                    if fetchedUsers.isEmpty {
                        self.isFetchedAll = true
                    } else {
                        if self.isRefresh {
                            self.users.removeAll()
                            self.isRefresh = false
                        }
                        self.isFetchedAll = fetchedUsers.count < userRequest.limit
                    }
                    self.groupUsers(users: fetchedUsers)

                case let .failure(error):
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        }
    }

    private func groupUsers(users: [User]) {
        var staticUsers: [[User]] = self.users

        for index in 0 ..< users.count {
            let lastCharter = staticUsers.last?.first?.name?.first
            let user = users[index]

            if let lastCharter {
                if user.name?.first?.lowercased() == lastCharter.lowercased() {
                    staticUsers[staticUsers.count - 1].append(user)
                } else {
                    staticUsers.append([user])
                }
            } else {
                staticUsers.append([user])
            }
        }

        DispatchQueue.main.async {
            self.users.removeAll()
            self.users = staticUsers
        }
    }

    func filterUsers(text: String) {
        self.filterUserRequest = userRequestBuilder.set(searchKeyword: text).build()

        guard let filterUserRequest else { return }

        isLoading = true

        UsersBuilder.getfilteredUsers(filterUserRequest: filterUserRequest) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case let .success(filteredUsers):
                    self.filteredUsers = filteredUsers
                case let .failure(error):
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        }
    }

    func getIndexPath(for user: User) -> IndexPath? {
        for (section, users) in users.enumerated() {
            for (row, currentUser) in users.enumerated() {
                if currentUser.uid == user.uid {
                    return IndexPath(row: row, section: section)
                }
            }
        }
        return nil
    }

    func connect() {
        CometChat.addUserListener("users-list-users-sdk-listener-\(listenerRandomID)", self as? CometChatUserDelegate)
        CometChatUserEvents.addListener("users-list-user-event-listener-\(listenerRandomID)", self as? CometChatUserEventListener)
    }

    func disconnect() {
        CometChat.removeUserListener("users-list-users-sdk-listener-\(listenerRandomID)")
        CometChatUserEvents.removeListener("users-list-user-event-listener-\(listenerRandomID)")
    }

    @discardableResult
    func add(user: User) -> Self {
        if users.isEmpty {
            users.append([user])
        } else if !users.contains(where: { $0.contains(where: { $0.uid == user.uid }) }) {
            users[0].insert(user, at: 0)
        }
        return self
    }

    @discardableResult
    func update(user: User) -> Self {
        if let indexPath = getIndexPath(for: user) {
            DispatchQueue.main.async {
                self.users[indexPath.section][indexPath.row] = user
            }
        }
        return self
    }

    @discardableResult
    func remove(user: User) -> Self {
        if let indexPath = getIndexPath(for: user) {
            DispatchQueue.main.async {
                self.users[indexPath.section].remove(at: indexPath.row)
                if self.users[indexPath.section].isEmpty {
                    self.users.remove(at: indexPath.section)
                }
            }
        }
        return self
    }

    @discardableResult
    func clearList() -> Self {
        DispatchQueue.main.async {
            self.users.removeAll()
        }
        return self
    }

    func size() -> Int {
        users.count
    }

    func selectUser(_ user: User) {
        if !selectedUsers.contains(where: { $0.uid == user.uid }) {
            selectedUsers.append(user)
        }
    }

    func deselectUser(_ user: User) {
        if let index = selectedUsers.firstIndex(where: { $0.uid == user.uid }) {
            selectedUsers.remove(at: index)
        }
    }

    func clearSelection() {
        selectedUsers.removeAll()
    }
}
