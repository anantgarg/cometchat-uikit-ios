//
//  CometChatGroupMembers + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 09/02/25.
//

import CometChatSDK
import Foundation

public extension CometChatGroupMembers {
    // MARK: Data

    @discardableResult
    func set(groupMemberRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder) -> Self {
        viewModel.set(groupMembersRequestBuilder: groupMemberRequestBuilder)
        return self
    }

    @discardableResult
    func set(group: Group) -> Self {
        viewModel.set(group: group)
        return self
    }

    @discardableResult
    func set(groupMemberSearchRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder) -> Self {
        viewModel.set(searchGroupMembersRequestBuilder: groupMemberSearchRequestBuilder)
        return self
    }

    func onSelection(_ onSelection: @escaping ([GroupMember]?) -> Void) {
        onSelection(viewModel.selectedGroupMembers)
    }

    // MARK: Events

    @discardableResult
    func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }

    @discardableResult
    func set(onLoad: @escaping (([GroupMember]) -> Void)) -> Self {
        self.onLoad = onLoad
        return self
    }

    @discardableResult
    func set(onEmpty: @escaping () -> Void) -> Self {
        self.onEmpty = onEmpty
        return self
    }

    @discardableResult
    func set(onItemClick: @escaping ((_ groupMember: GroupMember, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }

    @discardableResult
    func set(onItemLongClick: @escaping ((_ groupMember: GroupMember, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemLongClick = onItemLongClick
        return self
    }

    // MARK: Overrides

    @discardableResult
    func set(trailView: ((_ groupMember: GroupMember?) -> UIView)?) -> Self {
        self.trailView = trailView
        return self
    }

    @discardableResult
    func set(leadingView: ((_ groupMember: GroupMember?) -> UIView)?) -> Self {
        self.leadingView = leadingView
        return self
    }

    @discardableResult
    func set(titleView: ((_ groupMember: GroupMember?) -> UIView)?) -> Self {
        self.titleView = titleView
        return self
    }

    @discardableResult
    func set(subtitleView: ((_ groupMember: GroupMember?) -> UIView)?) -> Self {
        subtitle = subtitleView
        return self
    }

    @discardableResult
    func set(listItemView: ((_ groupMember: GroupMember?) -> UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }

    @discardableResult
    func set(options: ((_ group: Group, _ groupMember: GroupMember?) -> [CometChatGroupMemberOption])?) -> Self {
        self.options = options
        return self
    }

    @discardableResult
    func add(options: ((_ group: Group, _ groupMember: GroupMember?) -> [CometChatGroupMemberOption])?) -> Self {
        addOptions = options
        return self
    }

    @discardableResult
    func add(groupMember: GroupMember) -> Self {
        viewModel.add(groupMember: groupMember)
        return self
    }

    @discardableResult
    func update(groupMember: GroupMember) -> Self {
        viewModel.update(groupMember: groupMember)
        return self
    }

    @discardableResult
    func insert(groupMember: GroupMember, at: Int) -> Self {
        viewModel.insert(groupMember: groupMember, at: at)
        return self
    }

    @discardableResult
    func remove(groupMember: GroupMember) -> Self {
        viewModel.remove(groupMember: groupMember)
        return self
    }

    @discardableResult
    func clearList() -> Self {
        viewModel.clearList()
        return self
    }

    func size() -> Int {
        viewModel.size()
    }
}
