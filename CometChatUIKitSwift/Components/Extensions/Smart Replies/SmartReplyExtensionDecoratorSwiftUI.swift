//
//
//

import Combine
import CometChatSDK
import Foundation
import SwiftUI

class SmartReplyExtensionDecoratorSwiftUI: DataSourceDecorator {
    var dataStamp: Double?
    var _messageListenerId: String?
    var loggedInUser: User?
    var isVisible = false
    var id = [String: Any]()

    private var cancellables = Set<AnyCancellable>()

    override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
        dataStamp = Date().timeIntervalSince1970
        _messageListenerId = "ExtensionMessageListener"
        loggedInUser = CometChat.getLoggedInUser()
        disconnect()
        connect()
    }

    override func getId() -> String {
        "smart-reply"
    }

    public func connect() {
        if let _messageListenerId {
            CometChatMessageEvents.addListener(_messageListenerId, self)
        }
    }

    public func disconnect() {
        if let _messageListenerId {
            CometChatMessageEvents.removeListener(_messageListenerId)
            CometChatUIEvents.removeListener(_messageListenerId)
        }
    }

    public func getReplies(message: BaseMessage) -> [String]? {
        var replies = [String]()
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), !map.isEmpty, map.containsKey(ExtensionConstants.smartReply), let smartReplies = map[ExtensionConstants.smartReply] {
            if smartReplies.containsKey("reply_neutral") {
                if let reply_neutral = smartReplies["reply_neutral"] as? String {
                    replies.append(reply_neutral)
                }
            }
            if smartReplies.containsKey("reply_negative") {
                if let reply_negative = smartReplies["reply_negative"] as? String {
                    replies.append(reply_negative)
                }
            }
            if smartReplies.containsKey("reply_positive") {
                if let reply_positive = smartReplies["reply_positive"] as? String {
                    replies.append(reply_positive)
                }
            }
            if !replies.isEmpty {
                replies.append("")
            }
        }
        return replies
    }

    func getID(for message: BaseMessage) -> [String: Any] {
        var id = [String: Any]()
        if let receiver = message.receiver {
            if receiver is User {
                id["uid"] = message.sender?.uid
            } else if receiver is Group {
                id["guid"] = message.receiverUid
            }
        }
        if message.parentMessageId != 0 {
            id["parentMessageId"] = message.parentMessageId
        }

        return id
    }

    public func getRepliesPublisher(for message: BaseMessage) -> AnyPublisher<[String], Never> {
        Just(getReplies(message: message) ?? [])
            .eraseToAnyPublisher()
    }

    public func presentSmartReplies(for textMessage: BaseMessage) {
        id = getID(for: textMessage)
        if let replies = getReplies(message: textMessage), !replies.isEmpty {
            let smartRepliesView = CometChatSmartRepliesSwiftUI(titles: replies)
                .onReplySelected { [weak self] title in
                    guard let self else { return }
                    if title == "" {
                        isVisible = false
                        CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
                    } else {
                        let newMessage: TextMessage?
                        if textMessage.receiverType == .user {
                            let receiverUid = textMessage.sender?.uid ?? ""
                            newMessage = TextMessage(receiverUid: receiverUid, text: title, receiverType: .user)
                        } else {
                            let receiverUid = textMessage.receiverUid
                            newMessage = TextMessage(receiverUid: receiverUid, text: title, receiverType: .group)
                        }
                        if let newMessage {
                            newMessage.muid = "\(Int(Date().timeIntervalSince1970))"
                            newMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                            newMessage.sender = CometChat.getLoggedInUser()
                            newMessage.parentMessageId = textMessage.parentMessageId
                            CometChatUIKit.sendTextMessage(message: newMessage)
                            isVisible = false
                            CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
                        }
                    }
                }
                .toUIKit()

            let hostingController = UIHostingController(rootView: smartRepliesView)
            let smartRepliesUIView = hostingController.view
            smartRepliesUIView?.translatesAutoresizingMaskIntoConstraints = false
            smartRepliesUIView?.heightAnchor.constraint(equalToConstant: 60).isActive = true

            isVisible = true
            CometChatUIEvents.showPanel(id: id, alignment: .composerTop, view: smartRepliesUIView ?? UIView())
        } else {
            isVisible = false
            CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
        }
    }
}

extension SmartReplyExtensionDecoratorSwiftUI: CometChatMessageEventListener {
    func ccMessageSent(message _: CometChatSDK.BaseMessage, status _: MessageStatus) {
        if isVisible {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
            }
        }
    }

    func onMediaMessageReceived(mediaMessage _: CometChatSDK.MediaMessage) {
        if isVisible {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
            }
        }
    }

    func onCustomMessageReceived(customMessage _: CometChatSDK.CustomMessage) {
        if isVisible {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
            }
        }
    }

    func onFormMessageReceived(message _: FormMessage) {
        if isVisible {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
            }
        }
    }

    func onCardMessageReceived(message _: CardMessage) {
        if isVisible {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
            }
        }
    }

    func onTextMessageReceived(textMessage _: TextMessage) {
        DispatchQueue.main.async {}
    }
}
