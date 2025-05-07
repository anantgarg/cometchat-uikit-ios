//
//  CometChatConversations + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 09/02/25.
//

import CometChatSDK
import Foundation

public extension CometChatConversations {
    // MARK: Events

    @discardableResult
    func set(onItemClick: @escaping ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }

    @discardableResult
    func set(onItemLongClick: @escaping ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemLongClick = onItemLongClick
        return self
    }

    @discardableResult
    func set(onSelection: @escaping ((_ conversation: [Conversation]) -> Void)) -> Self {
        self.onSelection = onSelection
        return self
    }

    @discardableResult
    func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }

    @discardableResult
    func set(onLoad: @escaping ((_ conversation: [Conversation]) -> Void)) -> Self {
        self.onLoad = onLoad
        return self
    }

    @discardableResult
    func set(onEmpty: @escaping (() -> Void)) -> Self {
        self.onEmpty = onEmpty
        return self
    }

    // MARK: Configurations

    @discardableResult
    func set(textFormatters: [CometChatTextFormatter]) -> Self {
        self.textFormatters = textFormatters
        return self
    }

    @discardableResult
    func set(datePattern: @escaping ((_ conversation: Conversation) -> String)) -> Self {
        self.datePattern = datePattern
        return self
    }

    @discardableResult
    func set(options: ((_ conversation: Conversation?) -> [CometChatConversationOption])?) -> Self {
        self.options = options
        return self
    }

    @discardableResult
    func add(options: ((_ conversation: Conversation?) -> [CometChatConversationOption])?) -> Self {
        addOptions = options
        return self
    }

    @discardableResult
    func set(customSoundForMessages: URL) -> Self {
        self.customSoundForMessages = customSoundForMessages
        return self
    }

    // MARK: UI updates

    @discardableResult
    func set(listItemView: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.listItemView = listItemView
        return self
    }

    @discardableResult
    func set(trailView _: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        tailView = tailView
        return self
    }

    @discardableResult
    func set(subtitleView: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.subtitleView = subtitleView
        return self
    }

    @discardableResult
    func set(leadingView: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.leadingView = leadingView
        return self
    }

    @discardableResult
    func set(titleView: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.titleView = titleView
        return self
    }

    // MARK: Data

    @discardableResult
    func set(conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder) -> Self {
        viewModel.setRequestBuilder(conversationRequestBuilder: conversationRequestBuilder)
        return self
    }

    @discardableResult
    func insert(conversation: Conversation, at: Int) -> Self {
        viewModel.insert(conversation: conversation, at: at)
        return self
    }

    @discardableResult
    internal func update(conversation: Conversation) -> Self {
        viewModel.update(conversation: conversation)
        return self
    }

    @discardableResult
    internal func remove(conversation: Conversation) -> Self {
        viewModel.remove(conversation: conversation)
        return self
    }

    @discardableResult
    internal func clearList() -> Self {
        viewModel.clearList()
        return self
    }

    internal func size() -> Int {
        viewModel.size()
    }

    @discardableResult
    func getSelectedConversations() -> [Conversation] {
        viewModel.selectedConversations
    }

    func getConversationList() -> [Conversation] {
        viewModel.conversations
    }
}
