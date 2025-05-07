//
//  CometChatGroups + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 19/06/24.
//

import CometChatSDK
import Foundation

public extension CometChatGroups {
    // MARK: Data Props

    @discardableResult
    func set(groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder) -> Self {
        viewModel = GroupsViewModel(groupsRequestBuilder: groupsRequestBuilder)
        return self
    }

    @discardableResult
    func set(searchRequestBuilder: GroupsRequest.GroupsRequestBuilder) -> Self {
        viewModel.set(searchRequestBuilder: searchRequestBuilder)
        return self
    }

    func set(searchKeyword: String) -> Self {
        viewModel.filterGroups(text: searchKeyword)
        return self
    }

    // MARK: Events

    @discardableResult
    func onSelection(_ onSelection: @escaping (([Group]?) -> Void)) -> Self {
        self.onSelection = onSelection
        return self
    }

    @discardableResult
    func set(onLoad: @escaping (([Group]) -> Void)) -> Self {
        self.onLoad = onLoad
        return self
    }

    @discardableResult
    func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }

    @discardableResult
    func set(onEmpty: @escaping (() -> Void)) -> Self {
        self.onEmpty = onEmpty
        return self
    }

    @discardableResult
    func set(onItemClick: @escaping ((_ group: Group, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }

    @discardableResult
    func set(onItemLongClick: @escaping ((_ group: Group, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemLongClick = onItemLongClick
        return self
    }

    // MARK: Configuration

    @discardableResult
    func set(options: ((_ group: Group?) -> [CometChatGroupOption])?) -> Self {
        self.options = options
        return self
    }

    @discardableResult
    func add(options: ((_ group: Group?) -> [CometChatGroupOption])?) -> Self {
        addOptions = options
        return self
    }

    // MARK: Overrides

    @discardableResult
    func set(subtitle: ((_ group: Group?) -> UIView)?) -> Self {
        self.subtitle = subtitle
        return self
    }

    @discardableResult
    func set(listItemView: ((_ group: Group?) -> UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }

    @discardableResult
    func set(titleView: ((_ group: Group?) -> UIView)?) -> Self {
        self.titleView = titleView
        return self
    }

    @discardableResult
    func set(leadingView: ((_ group: Group?) -> UIView)?) -> Self {
        self.leadingView = leadingView
        return self
    }

    @discardableResult
    func set(trailingView: ((_ group: Group?) -> UIView)?) -> Self {
        self.trailingView = trailingView
        return self
    }

    @discardableResult
    internal func add(group: Group) -> Self {
        viewModel.add(group: group)
        return self
    }

    @discardableResult
    internal func insert(group: Group, at: Int) -> Self {
        viewModel.insert(group: group, at: at)
        return self
    }

    @discardableResult
    internal func update(group: Group) -> Self {
        viewModel.update(group: group)
        return self
    }

    @discardableResult
    internal func remove(group: Group) -> Self {
        viewModel.remove(group: group)
        return self
    }

    @discardableResult
    private func clearList() -> Self {
        viewModel.clearList()
        return self
    }

    private func size() -> Int {
        viewModel.size()
    }

    @discardableResult
    func set(title: String) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    func set(selectionLimit: Int) -> Self {
        self.selectionLimit = selectionLimit
        return self
    }
}
