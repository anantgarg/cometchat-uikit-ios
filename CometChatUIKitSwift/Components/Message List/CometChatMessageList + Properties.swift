//
//  CometChatMessageList + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 18/06/24.
//

import CometChatSDK
import Foundation

public extension CometChatMessageList {
    // MARK: Data

    @discardableResult
    func set(user: User, parentMessage: BaseMessage? = nil) -> Self {
        viewModel.set(user: user, messagesRequestBuilder: messagesRequestBuilder, parentMessage: parentMessage)
        return self
    }

    @discardableResult
    func set(group: Group, parentMessage: BaseMessage? = nil) -> Self {
        viewModel.set(group: group, messagesRequestBuilder: messagesRequestBuilder, parentMessage: parentMessage)
        return self
    }

    @discardableResult
    func set(messagesRequestBuilder: MessagesRequest.MessageRequestBuilder) -> Self {
        self.messagesRequestBuilder = messagesRequestBuilder
        viewModel.set(messagesRequestBuilder: messagesRequestBuilder)
        return self
    }

    @discardableResult
    func set(templates: [CometChatMessageTemplate]) -> Self {
        viewModel.templates.removeAll()
        for template in templates {
            viewModel.templates["\(template.category)_\(template.type)"] = template
        }
        return self
    }

    @discardableResult
    func add(templates: [CometChatMessageTemplate]) -> Self {
        for template in templates {
            viewModel.templates["\(template.category)_\(template.type)"] = template
        }
        return self
    }

    @discardableResult
    func set(reactionsRequestBuilder: ReactionsRequestBuilder) -> Self {
        self.reactionsRequestBuilder = reactionsRequestBuilder
        return self
    }

    @discardableResult
    func set(parentMessageId: Int) -> Self {
        viewModel.parentMessage?.id = parentMessageId
        if let user = viewModel.user {
            viewModel.set(user: user, messagesRequestBuilder: messagesRequestBuilder)
        } else {
            viewModel.set(group: viewModel.group!, messagesRequestBuilder: messagesRequestBuilder)
        }

        return self
    }

    // MARK: Event

    @discardableResult
    func set(onReactionClick: ((_ reaction: ReactionCount, _ baseMessage: BaseMessage?) -> Void)?) -> Self {
        self.onReactionClick = onReactionClick
        return self
    }

    @discardableResult
    func set(onReactionListItemClick: ((_ messageReaction: CometChatSDK.Reaction, _ baseMessage: BaseMessage?) -> Void)?) -> Self {
        self.onReactionListItemClick = onReactionListItemClick
        return self
    }

    @discardableResult
    func set(onThreadRepliesClick: ((_ message: BaseMessage, _ template: CometChatMessageTemplate) -> Void)?) -> Self {
        self.onThreadRepliesClick = onThreadRepliesClick
        return self
    }

    @discardableResult
    func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }

    @discardableResult
    func set(onLoad: @escaping (([BaseMessage]) -> Void)) -> Self {
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
        viewModel.textFormatters = textFormatters
        return self
    }

    @discardableResult
    func set(customSoundForMessages: URL) -> Self {
        self.customSoundForMessages = customSoundForMessages
        return self
    }

    @discardableResult
    func set(datePattern: ((_ timestamp: Int?) -> String)?) -> Self {
        self.datePattern = datePattern
        return self
    }

    @discardableResult
    func set(timePattern: ((_ timestamp: Int?) -> String)?) -> Self {
        self.timePattern = timePattern
        return self
    }

    @discardableResult
    func set(dateSeparatorPattern: ((_ timestamp: Int?) -> String)?) -> Self {
        self.dateSeparatorPattern = dateSeparatorPattern
        return self
    }

    @discardableResult
    func scrollToBottom(isAnimated: Bool = true) -> Self {
        if tableView.numberOfSections > 0, tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: isAnimated)
        }
        return self
    }

    @discardableResult
    func set(messageAlignment: MessageListAlignment) -> Self {
        self.messageAlignment = messageAlignment
        return self
    }

    @discardableResult
    func set(smartRepliesKeywords: [String]) -> Self {
        self.smartRepliesKeywords = smartRepliesKeywords
        return self
    }

    @discardableResult
    func set(smartRepliesDelayDuration: Int) -> Self {
        self.smartRepliesDelayDuration = smartRepliesDelayDuration
        return self
    }

    // MARK: Overrides

    @discardableResult
    func set(headerView: UIView?) -> Self {
        headerViewContainer.subviews.forEach { $0.removeFromSuperview() }
        if headerView != nil {
            headerViewContainer.isHidden = false
            if let headerView {
                headerViewContainer.addArrangedSubview(headerView)
            }
        } else {
            headerViewContainer.isHidden = true
        }
        return self
    }

    @discardableResult
    func clear(headerView: Bool) -> Self {
        if headerView {
            hideHeaderView = headerView
            headerViewContainer.subviews.forEach { $0.removeFromSuperview() }
            headerViewContainer.isHidden = headerView
        }
        return self
    }

    @discardableResult
    func set(footerView: UIView) -> Self {
        footerViewContainer.subviews.forEach { $0.removeFromSuperview() }
        footerViewContainer.isHidden = false
        footerViewContainer.addArrangedSubview(footerView)
        return self
    }

    @discardableResult
    func clear(footerView: Bool) -> Self {
        hideFooterView = footerView
        footerViewContainer.isHidden = true
        footerViewContainer.subviews.forEach { $0.removeFromSuperview() }
        layoutIfNeeded()
        return self
    }

    @discardableResult
    func set(loadingView: UIView) -> Self {
        loadingStateView = loadingView
        return self
    }

    @discardableResult
    func set(errorView: UIView) -> Self {
        errorStateView = errorView
        return self
    }

    @discardableResult
    func set(emptyView: UIView) -> Self {
        emptyStateView = emptyView
        return self
    }

    @discardableResult
    func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }

    @discardableResult
    func connect() -> Self {
        viewModel.connect()
        addKeyboardDismissGesture()
        return self
    }

    @discardableResult
    func disconnect() -> Self {
        viewModel.disconnect()
        removeKeyboardDismissGesture()
        return self
    }

    @discardableResult
    func add(message: BaseMessage) -> Self {
        viewModel.add(message: message)
        return self
    }

    @discardableResult
    func update(message: BaseMessage) -> Self {
        viewModel.update(message: message)
        return self
    }

    @discardableResult
    func remove(message: BaseMessage) -> Self {
        viewModel.remove(message: message)
        return self
    }

    @discardableResult
    func delete(message: BaseMessage) -> Self {
        viewModel.delete(message: message)
        return self
    }

    @discardableResult
    func didMessageInformationClicked(message: BaseMessage) -> Self {
        let messageInformationController = CometChatMessageInformation()
        let navigationController = UINavigationController(rootViewController: messageInformationController)

        if let messageInformationConfiguration {
            configureMessageInformation(configuration: messageInformationConfiguration, messageInformation: messageInformationController)
        }
        messageInformationController.dateTimeFormatter = dateTimeFormatter
        messageInformationController.set(message: message)

        if let indexPath = viewModel.getIndexPath(for: message), let cell = tableView.cellForRow(at: indexPath) as? CometChatMessageBubble {
            messageInformationController.bubbleSnapshotView = cell.bubbleStackView.snapshotView(afterScreenUpdates: true)
        }

        if #available(iOS 15.0, *) {
            if let presentationController = navigationController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium(), .large()]
                presentationController.prefersGrabberVisible = true
                controller?.present(navigationController, animated: true)
            }
        } else {
            controller?.present(navigationController, animated: true)
        }

        return self
    }

    @discardableResult
    func clearList() -> Self {
        viewModel.clearList()
        return self
    }

    @discardableResult
    func isEmpty() -> Bool {
        viewModel.messages.isEmpty ? true : false
    }

    func scrollToLastVisibleCell() {
        if let lastCell = tableView.indexPathsForVisibleRows, let lastIndex = lastCell.last {
            tableView.scrollToLastVisibleCell(lastIndex: lastIndex)
        }
    }

    func getAdditionalConfiguration() -> AdditionalConfiguration {
        viewModel.additionalConfiguration
    }
}
