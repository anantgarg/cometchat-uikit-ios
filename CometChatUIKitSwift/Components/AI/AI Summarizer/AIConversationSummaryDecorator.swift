//
//  AIConversationSummaryDecorator.swift
//
//
//  Created by SuryanshBisen on 20/10/23.
//

import CometChatSDK
import Foundation

class AIConversationSummaryDecorator: DataSourceDecorator {
    var configuration: AIConversationSummaryConfiguration?
    var eventID = "conversation-summary-decorator"
    var isErrorViewPresented = false
    var uiEventId: [String: Any]?

    init(dataSource: DataSource, configuration: AIConversationSummaryConfiguration? = nil) {
        self.configuration = configuration
        super.init(dataSource: dataSource)
        connect()
    }

    override func getId() -> String {
        ExtensionConstants.aiConversationSummary
    }

    override func getAIOptions(controller: UIViewController, user: User?, group: Group?, id: [String: Any]?, aiOptionsStyle: AIOptionsStyle?) -> [CometChatMessageComposerAction]? {
        uiEventId = id

        let conversationSummaryComposerAction = CometChatMessageComposerAction(
            id: getId(),
            text: "CONVERSATION_SUMMARY".localize(),
            startIcon: UIImage(named: "ai_conversation_summary", in: CometChatUIKit.bundle, with: nil),
            startIconTint: nil,
            textColor: (
                aiOptionsStyle?.textColor
            ),
            textFont: (
                aiOptionsStyle?.textFont
            ),
            backgroundColour: (
                aiOptionsStyle?.backgroundColor
            ),
            borderRadius: (
                aiOptionsStyle?.cornerRadius
            ),
            borderWidth: (
                aiOptionsStyle?.borderWidth
            ),
            borderColor: (
                aiOptionsStyle?.borderColor
            )
        ) {
            self.getConversationSummary(id: id, user: user, group: group)
        }
        var superComposerAction = super.getAIOptions(controller: controller, user: user, group: group, id: id, aiOptionsStyle: aiOptionsStyle)
        superComposerAction?.append(conversationSummaryComposerAction)
        return superComposerAction
    }

    func connect() {
        CometChatUIEvents.addListener(eventID, self)
    }

    func getConversationSummary(id: [String: Any]?, user: CometChatSDK.User?, group: CometChatSDK.Group?) {
        let receiverId = user?.uid ?? group?.guid ?? ""
        let receiverType = user != nil ? CometChat.ReceiverType.user : CometChat.ReceiverType.group

        if let apiConfiguration = configuration?.apiConfiguration {
            apiConfiguration(user, group) { [weak self] config in
                guard let self else { return }
                getConversationSummary(id: id, receiverType: receiverType, receiverId: receiverId, configuration: config)
            }
            return
        }
        getConversationSummary(id: id, receiverType: receiverType, receiverId: receiverId)
    }

    func getConversationSummary(id: [String: Any]?, receiverType: CometChat.ReceiverType, receiverId: String?, configuration _: [String: Any]? = nil) {
        guard let receiverId else { return }

        let summaryView = CometChatAIConversationSummary()
            .set(configuration: configuration)
            .set(id: id)

        if let configurationLoadingView = configuration?.loadingView {
            CometChatUIEvents.showPanel(id: id, alignment: .messageListBottom, view: configurationLoadingView)
        } else {
            summaryView.showLoadingView()
        }

        CometChat.getConversationSummary(receiverId: receiverId, receiverType: receiverType) { conversationSummary in
            DispatchQueue.main.async {
                summaryView.hideLoadingView()
                if conversationSummary.isEmpty {
                    self.showEmptyView(id: id, summaryView: summaryView)
                } else {
                    if let customViewCallBack = self.configuration?.customView {
                        let customView = customViewCallBack(conversationSummary) {
                            CometChatUIEvents.hidePanel(id: id, alignment: .messageListBottom)
                        }
                        CometChatUIEvents.showPanel(id: id, alignment: .messageListBottom, view: customView)
                        return
                    }
                    summaryView.set(summary: conversationSummary)
                }
            }
        } onError: { error in
            DispatchQueue.main.async {
                debugPrint("getConversationSummary failed with error: \(String(describing: error?.errorDescription))")
                self.showErrorView(id: id, summaryView: summaryView)
            }
        }
        CometChatUIEvents.showPanel(id: id, alignment: .composerTop, view: summaryView)
    }

    private func showErrorView(id: [String: Any]?, summaryView: CometChatAIConversationSummary) {
        if let configurationErrorView = configuration?.errorView {
            CometChatUIEvents.showPanel(id: id, alignment: .messageListBottom, view: configurationErrorView)
            return
        }
        summaryView.hideLoadingView()
        summaryView.show(error: true)
    }

    private func showEmptyView(id: [String: Any]?, summaryView: CometChatAIConversationSummary) {
        if let configurationEmptyView = configuration?.emptyRepliesView {
            CometChatUIEvents.showPanel(id: id, alignment: .messageListBottom, view: configurationEmptyView)
            return
        }
        summaryView.hideLoadingView()
        summaryView.show(error: true)
    }
}

extension AIConversationSummaryDecorator: CometChatUIEventListener {
    func onActiveChatChanged(id: [String: Any]?, lastMessage _: CometChatSDK.BaseMessage?, user: CometChatSDK.User?, group: CometChatSDK.Group?) {
        if let unReadMessageCount = (id?["unReadMessageCount"] as? Int) {
            if unReadMessageCount >= (configuration?.unreadMessageThreshold ?? 30) {
                getConversationSummary(id: id, user: user, group: group)
            }
        }
    }
}

extension AIConversationSummaryDecorator: CometChatMessageEventListener {
    func ccMessageSent(message _: CometChatSDK.BaseMessage, status _: MessageStatus) {
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventId, alignment: .messageListBottom)
            CometChatMessageEvents.removeListener(getId())
        }
    }
}
