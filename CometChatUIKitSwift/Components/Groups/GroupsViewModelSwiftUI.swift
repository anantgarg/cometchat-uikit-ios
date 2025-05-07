//
//
//

import Combine
import CometChatSDK
import Foundation
import SwiftUI

public class GroupsViewModelSwiftUI: ObservableObject {
    @Published var groups: [Group] = []
    @Published var filteredGroups: [Group] = []
    @Published var selectedGroups: [Group] = []
    @Published var isLoading: Bool = false
    @Published var isSearching: Bool = false
    @Published var hasError: Bool = false
    @Published var errorMessage: String = ""

    private var groupsRequest: GroupsRequest?
    private var filterGroupsRequest: GroupsRequest?
    private var groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder
    private var filterGroupsRequestBuilder: GroupsRequest.GroupsRequestBuilder?
    private var searchingText: String = ""
    private var listenerRandomId = Date().timeIntervalSince1970

    var isFetching = false
    var isFetchedAll = false
    var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                fetchGroups()
            }
        }
    }

    var onError: ((CometChatException) -> Void)?
    var onGroupJoined: ((Group) -> Void)?

    public init(groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder = GroupsBuilder.getDefaultRequestBuilder()) {
        self.groupsRequestBuilder = groupsRequestBuilder
        groupsRequest = groupsRequestBuilder.build()
    }

    func fetchGroups() {
        if isRefresh {
            isFetchedAll = false
            groupsRequestBuilder = GroupsBuilder.getDefaultRequestBuilder()
            groupsRequest = groupsRequestBuilder.build()
        }

        guard let groupsRequest else { return }
        if isFetchedAll { return }

        isLoading = true
        isFetching = true

        GroupsBuilder.fetchGroups(groupRequest: groupsRequest) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                self.isFetching = false

                switch result {
                case let .success(fetchedGroups):
                    if fetchedGroups.isEmpty {
                        self.isFetchedAll = true
                    }

                    if self.isRefresh {
                        self.groups.removeAll()
                        self.groups = fetchedGroups
                    } else {
                        self.groups.append(contentsOf: fetchedGroups)
                    }

                case let .failure(error):
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        }
    }

    func filterGroups(text: String) {
        searchingText = text
        self.filterGroupsRequest = groupsRequestBuilder.set(searchKeyword: text).build()

        guard let filterGroupsRequest else { return }

        isLoading = true

        GroupsBuilder.getfilteredGroups(filterGroupRequest: filterGroupsRequest) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case let .success(filteredGroups):
                    self.filteredGroups = filteredGroups
                case let .failure(error):
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        }
    }

    func joinGroup(withGuid: String, name _: String, groupType: CometChat.groupType, password: String, completion: @escaping (_ joinedGroup: Group?) -> Void) {
        CometChat.joinGroup(GUID: withGuid, groupType: groupType, password: password, onSuccess: { [weak self] joinedGroup in
            guard let self else { return }

            DispatchQueue.main.async {
                self.onGroupJoined?(joinedGroup)

                if let user = CometChat.getLoggedInUser() {
                    CometChatGroupEvents.ccGroupMemberJoined(joinedUser: user, joinedGroup: joinedGroup)
                }

                completion(joinedGroup)
            }
        }, onError: { [weak self] error in
            guard let error, let self else { return }

            DispatchQueue.main.async {
                self.hasError = true
                self.errorMessage = error.errorDescription
                self.onError?(error)
                completion(nil)
            }
        })
    }

    func set(searchRequestBuilder: GroupsRequest.GroupsRequestBuilder) {
        filterGroupsRequestBuilder = searchRequestBuilder
        filterGroupsRequest = filterGroupsRequestBuilder!.build()
    }

    func reloadGroups() {
        groupsRequest = groupsRequestBuilder.build()
        groups.removeAll()
        fetchGroups()
    }

    func selectGroup(_ group: Group) {
        if !selectedGroups.contains(group) {
            selectedGroups.append(group)
        }
    }

    func deselectGroup(_ group: Group) {
        if let index = selectedGroups.firstIndex(of: group) {
            selectedGroups.remove(at: index)
        }
    }

    func clearSelection() {
        selectedGroups.removeAll()
    }

    @discardableResult
    func add(group: Group) -> Self {
        if groups.firstIndex(where: { $0.guid == group.guid }) == nil {
            groups.append(group)
        }
        return self
    }

    @discardableResult
    func insert(group: Group, at: Int) -> Self {
        if groups.firstIndex(where: { $0.guid == group.guid }) == nil {
            groups.insert(group, at: at)
        }
        return self
    }

    @discardableResult
    func update(group: Group) -> Self {
        if isSearching {
            if let index = filteredGroups.firstIndex(where: { $0.guid == group.guid }) {
                filteredGroups[index] = group
            }
        } else {
            if let index = groups.firstIndex(where: { $0.guid == group.guid }) {
                groups[index] = group
            }
        }
        return self
    }

    @discardableResult
    func remove(group: Group) -> Self {
        if let index = groups.firstIndex(where: { $0.guid == group.guid }) {
            groups.remove(at: index)
        }
        return self
    }

    @discardableResult
    func clearList() -> Self {
        groups.removeAll()
        return self
    }

    func size() -> Int {
        groups.count
    }

    func connect() {
        CometChat.addGroupListener("groups-groups-sdk-listener-\(listenerRandomId)", self as? CometChatGroupDelegate)
        CometChatGroupEvents.addListener("groups-groups-events-listener-\(listenerRandomId)", self as? CometChatGroupEventListener)
    }

    func disconnect() {
        CometChat.removeGroupListener("groups-groups-sdk-listener-\(listenerRandomId)")
        CometChatGroupEvents.removeListener("groups-groups-events-listener-\(listenerRandomId)")
    }
}
