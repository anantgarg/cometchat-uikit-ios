//
//
//

import Combine
import CometChatSDK
import Foundation
import SwiftUI

public class MessageListViewModelSwiftUI: ObservableObject {
    @Published var messages: [(date: Date, messages: [BaseMessage])] = []
    @Published var selectedMessages: [BaseMessage] = []
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    @Published var errorMessage: String = ""
    @Published var newMessageReceived: BaseMessage?

    var user: User?
    var group: Group?
    var parentMessage: BaseMessage?
    var messagesRequestBuilder: MessagesRequest.MessageRequestBuilder
    private var messagesRequest: MessagesRequest?
    private var messageActionRequestBuilder = MessagesRequest.MessageRequestBuilder().build()
    private var messageNextRequestBuilder = MessagesRequest.MessageRequestBuilder().build()
    var isAllMessagesFetchedInPrevious = false
    var hasFetchedMessagesBefore = false
    var currentRandomDate = Date().timeIntervalSinceReferenceDate
    var templates = [String: CometChatMessageTemplate]()
    var additionalConfiguration = AdditionalConfiguration()

    var onError: ((CometChatException) -> Void)?
    var onEmpty: (() -> Void)?
    var onLoad: (([BaseMessage]) -> Void)?
    var onThreadRepliesClick: ((BaseMessage, CometChatMessageTemplate) -> Void)?

    var messageBubbleStyle = CometChatMessageBubble.style {
        didSet {
            additionalConfiguration.messageBubbleStyle = messageBubbleStyle
        }
    }

    var actionBubbleStyle = CometChatMessageBubble.actionBubbleStyle {
        didSet {
            additionalConfiguration.actionBubbleStyle = actionBubbleStyle
        }
    }

    var callActionBubbleStyle = CometChatMessageBubble.callActionBubbleStyle {
        didSet {
            additionalConfiguration.callActionBubbleStyle = callActionBubbleStyle
        }
    }

    var textFormatters = ChatConfigurator.getDataSource().getTextFormatters() {
        didSet {
            additionalConfiguration.textFormatter = textFormatters
        }
    }

    public var hideReplyInThreadOption: Bool = false {
        didSet {
            additionalConfiguration.hideReplyInThreadOption = hideReplyInThreadOption
        }
    }

    public var hideTranslateMessageOption: Bool = false {
        didSet {
            additionalConfiguration.hideTranslateMessageOption = hideTranslateMessageOption
        }
    }

    public var hideEditMessageOption: Bool = false {
        didSet {
            additionalConfiguration.hideEditMessageOption = hideEditMessageOption
        }
    }

    public var hideDeleteMessageOption: Bool = false {
        didSet {
            additionalConfiguration.hideDeleteMessageOption = hideDeleteMessageOption
        }
    }

    public var hideReactionOption: Bool = false {
        didSet {
            additionalConfiguration.hideReactionOption = hideReactionOption
        }
    }

    public var hideMessagePrivatelyOption: Bool = false {
        didSet {
            additionalConfiguration.hideMessagePrivatelyOption = hideMessagePrivatelyOption
        }
    }

    public var hideCopyMessageOption: Bool = false {
        didSet {
            additionalConfiguration.hideCopyMessageOption = hideCopyMessageOption
        }
    }

    public var hideMessageInfoOption: Bool = false {
        didSet {
            additionalConfiguration.hideMessageInfoOption = hideMessageInfoOption
        }
    }

    public init() {
        messagesRequestBuilder = MessagesRequest.MessageRequestBuilder()
        setUpDefaultTemplate()
    }

    func set(group: Group, messagesRequestBuilder: MessagesRequest.MessageRequestBuilder? = nil, parentMessage: BaseMessage? = nil) {
        self.group = group
        self.parentMessage = parentMessage
        self.messagesRequestBuilder = messagesRequestBuilder?.set(guid: group.guid).setParentMessageId(parentMessageId: parentMessage?.id ?? 0) ?? MessagesRequest.MessageRequestBuilder()
            .set(guid: group.guid)
            .hideReplies(hide: true)
            .setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
            .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
        messagesRequest = self.messagesRequestBuilder.build()
        fetchUnreadMessageCount()
    }

    func set(user: User, messagesRequestBuilder: MessagesRequest.MessageRequestBuilder? = nil, parentMessage: BaseMessage? = nil) {
        self.user = user
        self.parentMessage = parentMessage
        self.messagesRequestBuilder = messagesRequestBuilder?.set(uid: user.uid ?? "").setParentMessageId(parentMessageId: parentMessage?.id ?? 0) ?? MessagesRequest
            .MessageRequestBuilder().set(uid: user.uid ?? "")
            .hideReplies(hide: true)
            .setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
            .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
        messagesRequest = self.messagesRequestBuilder.build()
        fetchUnreadMessageCount()
    }

    func set(messagesRequestBuilder: MessagesRequest.MessageRequestBuilder) {
        if let user {
            self.messagesRequestBuilder = messagesRequestBuilder.set(uid: user.uid ?? "").setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
        } else if let group {
            self.messagesRequestBuilder = messagesRequestBuilder.set(guid: group.guid).setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
        }
    }

    func fetchNextMessages() {
        guard let messagesRequest else { return }

        MessagesListBuilder.fetchNextMessages(messageRequest: messagesRequest) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(fetchedMessages):
                if fetchedMessages.count > 0 {
                    processMessageList(fetchedMessages) { processedMessages in
                        self.groupMessages(messages: processedMessages)
                    }
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        }
    }

    func fetchPreviousMessages() {
        guard let messagesRequest else { return }
        if isAllMessagesFetchedInPrevious { return }

        DispatchQueue.main.async {
            self.isLoading = true
        }

        hasFetchedMessagesBefore = true

        MessagesListBuilder.fetchPreviousMessages(messageRequest: messagesRequest) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
            }

            switch result {
            case let .success(fetchedMessages):
                if fetchedMessages.isEmpty {
                    isAllMessagesFetchedInPrevious = true
                }

                processMessageList(fetchedMessages) { processedMessages in
                    self.groupMessages(messages: processedMessages)
                }

                sendActiveChatChangeEvent()

            case let .failure(error):
                DispatchQueue.main.async {
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        }
    }

    func fetchUnreadMessageCount() {
        if let uid = user?.uid {
            CometChat.getUnreadMessageCountForUser(uid) { [weak self] _ in
                guard let self else { return }
            } onError: { [weak self] error in
                guard let self, let error else { return }
                onError?(error)
            }
            return
        }

        if let guid = group?.guid {
            CometChat.getUnreadMessageCountForGroup(guid) { [weak self] _ in
                guard let self else { return }
            } onError: { [weak self] error in
                guard let self, let error else { return }
                onError?(error)
            }
            return
        }
    }

    func copyMessage(_ message: BaseMessage) {
        if let textMessage = message as? TextMessage {
            UIPasteboard.general.string = textMessage.text
        } else if let customMessage = message as? CustomMessage, let customData = customMessage.customData, let text = customData["text"] as? String {
            UIPasteboard.general.string = text
        }
    }

    func editMessage(_ message: BaseMessage) {
        CometChatMessageEvents.ccMessageEdit(message: message)
    }

    func deleteMessage(_ message: BaseMessage) {
        CometChat.deleteMessage(messageId: message.id) { [weak self] message in
            guard let self else { return }

            for (sectionIndex, section) in messages.enumerated() {
                if let messageIndex = section.messages.firstIndex(where: { $0.id == message.id }) {
                    DispatchQueue.main.async {
                        var updatedMessages = self.messages
                        updatedMessages[sectionIndex].messages.remove(at: messageIndex)

                        if updatedMessages[sectionIndex].messages.isEmpty {
                            updatedMessages.remove(at: sectionIndex)
                        }

                        self.messages = updatedMessages
                    }
                    break
                }
            }

        } onError: { [weak self] error in
            guard let self, let error else { return }
            DispatchQueue.main.async {
                self.hasError = true
                self.errorMessage = error.errorDescription
                self.onError?(error)
            }
        }
    }

    func getTemplate(for message: BaseMessage) -> CometChatMessageTemplate? {
        let category = message.category
        let type = message.type
        return templates["\(category)_\(type)"]
    }

    private func setUpDefaultTemplate() {
        additionalConfiguration.textFormatter = textFormatters
        additionalConfiguration.messageBubbleStyle = messageBubbleStyle
        additionalConfiguration.actionBubbleStyle = actionBubbleStyle
        additionalConfiguration.callActionBubbleStyle = callActionBubbleStyle

        let messageTypes = ChatConfigurator.getDataSource().getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
        for template in messageTypes {
            templates["\(template.category)_\(template.type)"] = template
        }
    }

    private func sendActiveChatChangeEvent() {
        var id = [String: Any]()
        if let user {
            id["uid"] = user.uid
        }
        if let group {
            id["guid"] = group.guid
        }
        if parentMessage?.id != 0 {
            id["parentMessageId"] = parentMessage?.id
        }

        CometChatUIEvents.ccActiveChatChanged(id: id, lastMessage: messages.first?.messages.first, user: user, group: group)
    }

    private func groupMessages(messages: [BaseMessage], atBottom: Bool = false) {
        if let lastMessage = messages.last {
            if lastMessage.deliveredAt == 0.0 {
                markAsDelivered(message: lastMessage)
            }
            if lastMessage.readAt == 0.0 {
                markAsRead(message: lastMessage)
            }
        }

        let groupedMessages = Dictionary(grouping: messages) { element -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }

        DispatchQueue.main.async {
            var updatedMessages = self.messages

            for (date, dateMessages) in groupedMessages {
                var reversedMessages = dateMessages
                reversedMessages.reverse()

                if let index = updatedMessages.firstIndex(where: { $0.date == date }) {
                    if atBottom == false {
                        updatedMessages[index].messages.append(contentsOf: reversedMessages)
                    } else {
                        updatedMessages[index].messages.insert(contentsOf: reversedMessages, at: 0)
                    }
                } else {
                    updatedMessages.append((date: date, messages: reversedMessages))
                }
            }

            self.messages = updatedMessages.sorted(by: { $0.date.compare($1.date) == .orderedDescending })

            if !self.messages.isEmpty {
                self.hasError = false
                self.onLoad?(self.messages.flatMap(\.messages))
            } else {
                self.onEmpty?()
            }
        }
    }

    private func processMessageList(_ messageList: [BaseMessage], _ completion: @escaping ([BaseMessage]) -> Void) {
        var messagesList = [BaseMessage]()

        for message in messageList {
            if let message_ = message as? InteractiveMessage, message_.messageCategory == .interactive {
                if message_.type == MessageTypeConstants.form {
                    let formMessage = FormMessage.toFormMessage(message_)
                    messagesList.append(formMessage)
                } else if message_.type == MessageTypeConstants.card {
                    let cardMessage = CardMessage.toCardMessage(message_)
                    messagesList.append(cardMessage)
                } else if message_.type == MessageTypeConstants.scheduler {
                    let schedulerMessage = SchedulerMessage.toSchedulerMessage(message_)
                    messagesList.append(schedulerMessage)
                } else {
                    let customMessage = CustomInteractiveMessage.toCustomInteractiveMessage(message_)
                    messagesList.append(customMessage)
                }
            } else {
                messagesList.append(message)
            }
        }

        completion(messagesList)
    }

    private func markAsRead(message: BaseMessage) {
        if message.sender?.uid != CometChat.getLoggedInUser()?.uid {
            CometChat.markAsRead(baseMessage: message)
        }
    }

    private func markAsDelivered(message: BaseMessage) {
        if message.sender?.uid != CometChat.getLoggedInUser()?.uid {
            CometChat.markAsDelivered(baseMessage: message)
        }
    }

    func connect() {
        CometChatUIEvents.addListener("message-list-event-listener\(currentRandomDate)", self as? CometChatUIEventListener)
        CometChat.addMessageListener("message-list-message-sdk-listener\(currentRandomDate)", self)
        CometChat.addConnectionListener("messages-connection-sdk-listener\(currentRandomDate)", self)
        CometChatMessageEvents.addListener("event-listener-\(currentRandomDate)", self as? CometChatMessageEventListener)
    }

    func disconnect() {
        CometChatUIEvents.removeListener("message-list-event-listener\(currentRandomDate)")
        CometChat.removeMessageListener("message-list-message-sdk-listener\(currentRandomDate)")
        CometChat.removeConnectionListener("messages-connection-sdk-listener\(currentRandomDate)")
        CometChatMessageEvents.removeListener("event-listener-\(currentRandomDate)")
    }
}

extension MessageListViewModelSwiftUI: CometChatMessageDelegate {
    public func onTextMessageReceived(textMessage: TextMessage) {
        if isMessageForThisUser(message: textMessage) {
            DispatchQueue.main.async {
                self.newMessageReceived = textMessage
                self.groupMessages(messages: [textMessage], atBottom: true)
            }
        }
    }

    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        if isMessageForThisUser(message: mediaMessage) {
            DispatchQueue.main.async {
                self.newMessageReceived = mediaMessage
                self.groupMessages(messages: [mediaMessage], atBottom: true)
            }
        }
    }

    public func onCustomMessageReceived(customMessage: CustomMessage) {
        if isMessageForThisUser(message: customMessage) {
            DispatchQueue.main.async {
                self.newMessageReceived = customMessage
                self.groupMessages(messages: [customMessage], atBottom: true)
            }
        }
    }

    private func isMessageForThisUser(message: BaseMessage) -> Bool {
        if let group, message.receiverType == .group, message.receiverUid == group.guid {
            return true
        } else if let user, message.receiverType == .user {
            if CometChat.getLoggedInUser()?.uid == message.receiverUid, message.sender?.uid == user.uid {
                return true
            } else if CometChat.getLoggedInUser()?.uid == message.sender?.uid, message.receiverUid == user.uid {
                return true
            }
        }
        return false
    }
}

extension MessageListViewModelSwiftUI: CometChatConnectionDelegate {
    public func connected() {
        fetchPreviousMessages()
    }

    public func connecting() {}

    public func disconnected() {}
}
