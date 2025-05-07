//
//  GroupsViewModel.swift

//
//  Created by Pushpsen Airekar on 17/11/22.
//

import CometChatSDK
import Foundation

protocol GroupsViewModelProtocol {
    var row: Int { get set }
    var isSearching: Bool { get set }
    var groups: [CometChatSDK.Group] { get set }
    var filteredGroups: [CometChatSDK.Group] { get set }
    var selectedGroups: [CometChatSDK.Group] { get set }
    var groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder { get set }

    var reload: (() -> Void)? { get set }
    var reloadAt: ((Int) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    var hasJoined: ((Group) -> Void)? { get set }

    func fetchGroups()
    func filterGroups(text: String)
    func joinGroup(withGuid: String, name: String, groupType: CometChat.groupType, password: String, indexPath: IndexPath, completion: @escaping (_ joinedGroup: Group?) -> Void)
}

open class GroupsViewModel: NSObject, GroupsViewModelProtocol {
    var row: Int = 0 {
        didSet {
            reloadAt?(row)
        }
    }

    var groups: [Group] = [] {
        didSet {
            reload?()
        }
    }

    var filteredGroups: [Group] = [] {
        didSet {
            reload?()
        }
    }

    var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                fetchGroups()
            }
        }
    }

    var isFetching = false
    var isFetchedAll = false

    var isSearching: Bool = false
    private var searchingText: String = ""
    var selectedGroups: [CometChatSDK.Group] = []
    var groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder
    private var filterGroupsRequestBuilder: GroupsRequest.GroupsRequestBuilder?
    private var groupsRequest: GroupsRequest?
    private var filterGroupsRequest: GroupsRequest?

    var reload: (() -> Void)?
    var reloadAt: ((Int) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    var hasJoined: ((CometChatSDK.Group) -> Void)?

    init(groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder) {
        self.groupsRequestBuilder = groupsRequestBuilder
        groupsRequest = groupsRequestBuilder.build()
    }

    func reloadGroups() {
        groupsRequest = groupsRequestBuilder.build()
        groups.removeAll()
        fetchGroups()
    }

    public func set(searchRequestBuilder: GroupsRequest.GroupsRequestBuilder) {
        filterGroupsRequestBuilder = searchRequestBuilder
        filterGroupsRequest = filterGroupsRequestBuilder!.build()
    }

    func fetchGroups() {
        if isRefresh {
            isFetchedAll = false
            groupsRequestBuilder = GroupsBuilder.getDefaultRequestBuilder()
            groupsRequest = groupsRequestBuilder.build()
        }

        guard let groupsRequest else { return }
        if isFetchedAll { return }

        isFetching = true
        GroupsBuilder.fetchGroups(groupRequest: groupsRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case let .success(fetchedGroups):
                if fetchedGroups.isEmpty {
                    this.isFetchedAll = true
                }

                if this.isRefresh {
                    this.groups.removeAll()
                    this.groups = fetchedGroups
                } else {
                    this.groups.append(contentsOf: fetchedGroups)
                }
                this.isFetching = false
                this.reload?()
            case let .failure(error):
                this.failure?(error)
                this.isFetching = false
            }
        }
    }

    func filterGroups(text: String) {
        searchingText = text
        self.filterGroupsRequest = groupsRequestBuilder.set(searchKeyword: text).build()
        guard let filterGroupsRequest else { return }
        GroupsBuilder.getfilteredGroups(filterGroupRequest: filterGroupsRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case let .success(filteredGroups):
                this.filteredGroups = filteredGroups
            case let .failure(error):
                this.failure?(error)
            }
        }
    }

    func joinGroup(withGuid: String, name _: String, groupType: CometChat.groupType, password: String, indexPath _: IndexPath, completion: @escaping (_ joinedGroup: Group?) -> Void) {
        CometChat.joinGroup(GUID: withGuid, groupType: groupType, password: password, onSuccess: { [weak self] joinedGroup in
            guard let this = self else { return }
            this.hasJoined?(joinedGroup)
            if let user = CometChat.getLoggedInUser() {
                CometChatGroupEvents.ccGroupMemberJoined(joinedUser: user, joinedGroup: joinedGroup)
            }
            completion(joinedGroup)
        }, onError: { [weak self] error in
            guard let error, let this = self else { return }
            completion(nil)
            this.failure?(error)
        })
    }

    func connect() {
        // New.
        CometChat.addGroupListener("groups-groups-sdk-listener", self)
        CometChatGroupEvents.addListener("groups-groups-events-listener", self)
    }

    func disconnect() {
        CometChat.removeGroupListener("groups-groups-sdk-listener")
        CometChatGroupEvents.removeListener("groups-groups-events-listener")
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
}
