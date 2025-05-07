//
//  CometChatUsers + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 19/06/24.
//

import CometChatSDK
import Foundation

public extension CometChatUsers {
    func set(userRequestBuilder: UsersRequest.UsersRequestBuilder) -> Self {
        viewModel.userRequestBuilder = userRequestBuilder
        return self
    }

    func set(searchRequestBuilder: UsersRequest.UsersRequestBuilder) -> Self {
        viewModel.userRequestBuilder = searchRequestBuilder
        return self
    }

    func set(searchKeyword: String) -> Self {
        searchKeyWord = searchKeyword
        return self
    }

    @discardableResult
    func set(onSelection: @escaping ((_ user: [User]) -> Void)) -> Self {
        self.onSelection = onSelection
        return self
    }

    @discardableResult
    func set(subtitle: ((_ user: User?) -> UIView)?) -> Self {
        self.subtitle = subtitle
        return self
    }

    @discardableResult
    func set(listItemView: ((_ user: User?) -> UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }

    @discardableResult
    func set(titleView: ((_ user: User?) -> UIView)?) -> Self {
        self.titleView = titleView
        return self
    }

    @discardableResult
    func set(leadingView: ((_ user: User?) -> UIView)?) -> Self {
        self.leadingView = leadingView
        return self
    }

    @discardableResult
    func set(trailingView: ((_ user: User?) -> UIView)?) -> Self {
        self.trailingView = trailingView
        return self
    }

    @discardableResult
    func set(options: ((_ user: User?) -> [CometChatUserOption])?) -> Self {
        self.options = options
        return self
    }

    @discardableResult
    func add(options: ((_ user: User?) -> [CometChatUserOption])?) -> Self {
        addOptions = options
        return self
    }

    @discardableResult
    func set(onItemClick: @escaping ((_ user: User, _ indexPath: IndexPath?) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }

    @discardableResult
    func set(onItemLongClick: @escaping ((_ user: User, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemLongClick = onItemLongClick
        return self
    }

    @discardableResult
    func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }

    @discardableResult
    func set(onLoad: @escaping (([[User]]) -> Void)) -> Self {
        self.onLoad = onLoad
        return self
    }

    @discardableResult
    func set(onEmpty: @escaping (() -> Void)) -> Self {
        self.onEmpty = onEmpty
        return self
    }

    @discardableResult
    func set(selectionLimit: Int) -> Self {
        self.selectionLimit = selectionLimit
        return self
    }
}
