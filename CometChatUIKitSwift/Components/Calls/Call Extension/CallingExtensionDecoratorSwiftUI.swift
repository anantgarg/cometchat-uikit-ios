//
//  
//
//

import SwiftUI
import CometChatSDK
import Foundation

#if canImport(CometChatCallsSDK)

class CallingExtensionDecoratorSwiftUI: DataSourceDecorator {
    
    var callCategoryConstant = "call"
    var audioCallTypeConstant = "audio"
    var videoCallTypeConstant = "video"
    var conferenceCallTypeConstant = "meeting"
    var callingConfiguration: CallingConfigurationSwiftUI?
    var anInterface: DataSource?
    var spacer: String = "       "
    private var call: Call?
    
    private override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
        self.anInterface = dataSource
    }
    
    public convenience init(dataSource: DataSource, configuration: CallingConfigurationSwiftUI?) {
        self.init(dataSource: dataSource)
        if let uiKitSettings = CometChatUIKit.uiKitSettings {
            
            let callAppSettings = CallAppSettingsBuilder()
                .setAppId(uiKitSettings.appID)
                .setRegion(uiKitSettings.region)
                .build()
            
            CometChatCalls.init(callsAppSettings: callAppSettings) {_ in } onError: {_ in }
        }
        self.callingConfiguration = configuration
        disconnect()
        connect()
    }
    
    @discardableResult
    public func connect() -> Self {
        CometChat.addCallListener("call-decorator-call-listener-swiftui", self)
        return self
    }
    
    @discardableResult
    public func disconnect() -> Self {
        CometChat.removeCallListener("call-decorator-call-listener-swiftui")
        return self
    }
    
    override func getAllMessageTypes() -> [String]? {
        var messageTypes = super.getAllMessageTypes()
        messageTypes?.append(audioCallTypeConstant)
        messageTypes?.append(videoCallTypeConstant)
        messageTypes?.append(conferenceCallTypeConstant)
        return messageTypes
    }
    
    override func getAllMessageCategories() -> [String]? {
        if let categories = super.getAllMessageCategories(), !categories.contains(obj: MessageCategoryConstants.custom) {
            var messageCategories = categories
            messageCategories.append(callCategoryConstant)
            return messageCategories
        }
        return super.getAllMessageCategories()
    }
    
    override func getAllMessageTemplates(additionalConfiguration: AdditionalConfiguration?) -> [CometChatMessageTemplate] {
        var templates = super.getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
        templates.append(getAudioCallTemplate(additionalConfiguration: additionalConfiguration))
        templates.append(getVideoCallTemplate(additionalConfiguration: additionalConfiguration))
        templates.append(getConferenceCallTemplate(additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration()))
        return templates
    }
    
    public func getAudioCallTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.call, type: audioCallTypeConstant, contentView: { [weak self] message, alignment, controller in
            guard let this = self else { return UIView() }
            guard let message = message as? Call else { return UIView() }
            return this.getCallActionBubble(call: message, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }, bubbleView: nil, headerView: nil, footerView: nil, bottomView: nil, options: nil)
    }
    
    public func getVideoCallTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.call, type: videoCallTypeConstant, contentView: { [weak self] message, alignment, controller in
            guard let this = self else { return UIView() }
            guard let message = message as? Call else { return UIView() }
            return this.getCallActionBubble(call: message, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }, bubbleView: nil, headerView: nil, footerView: nil, bottomView: nil, options: nil)
    }
    
    public func getCallActionBubble(call: Call, additionalConfiguration: AdditionalConfiguration) -> UIView {
        let view = UIView().withoutAutoresizingMaskConstraints()
        
        self.call = call
        let isLoggedInUser: Bool = (call.callInitiator as? User)?.uid == LoggedInUserInformation.getUID()
        
        let callType = call.callType
        var icon: String = ""
        var callStatusText = ""
        var textColor: UIColor = additionalConfiguration.callActionBubbleStyle.callTextColor
        let textFont: UIFont = additionalConfiguration.callActionBubbleStyle.callTextFont
        var iconTintColor: UIColor = additionalConfiguration.callActionBubbleStyle.callImageTintColor
        
        switch call.callStatus {
        case .initiated:
            callStatusText = isLoggedInUser ? "OUTGOING_CALL".localize() : "INCOMING_CALL".localize()
            if !isLoggedInUser {
                icon = callType == .audio ? "phone.arrow.down.left" : "arrow.down.left.video"
            } else {
                icon = callType == .audio ? "phone.arrow.up.right" : "arrow.up.right.video"
            }
            
        case .unanswered:
            callStatusText = "MISSED_CALL".localize()
            icon = callType == .audio ? "phone.arrow.down.left" : "arrow.down.left.video"
            textColor = additionalConfiguration.callActionBubbleStyle.missedCallTextColor
            iconTintColor = additionalConfiguration.callActionBubbleStyle.missedCallImageTintColor
            
        case .rejected:
            callStatusText = "CALL_REJECTED".localize()
            icon = callType == .audio ? "phone" : "video"
            
        case .cancelled:
            callStatusText = "CALL_CANCELLED".localize()
            icon = callType == .audio ? "phone" : "video"
            
        case .busy:
            callStatusText = "MISSED_CALL".localize()
            icon = callType == .audio ? "phone.arrow.down.left" : "arrow.down.left.video"
            textColor = additionalConfiguration.callActionBubbleStyle.missedCallTextColor
            iconTintColor = additionalConfiguration.callActionBubbleStyle.missedCallImageTintColor
            
        case .ended:
            callStatusText = "CALL_ENDED".localize()
            icon = callType == .audio ? "phone" : "video"
            
        case .ongoing:
            callStatusText = "CALL_ACCEPTED".localize()
            icon = callType == .audio ? "phone" : "video"
        @unknown default:
            callStatusText = "CALL_CANCELLED".localize()
        }
        
        let callStatusItem = createCallStatusItem(iconName: icon, title: callStatusText, textColor: textColor, textFont: textFont, imageTintColor: iconTintColor)
        view.addSubview(callStatusItem)
        
        callStatusItem.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p2).isActive = true
        callStatusItem.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CometChatSpacing.Padding.p2).isActive = true
        callStatusItem.heightAnchor.constraint(equalToConstant: 32).isActive = true
        callStatusItem.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return view
    }
    
    private func createCallStatusItem(iconName: String, title: String, textColor: UIColor, textFont: UIFont, imageTintColor: UIColor) -> UIStackView {
        let itemStackView = UIStackView().withoutAutoresizingMaskConstraints()
        itemStackView.axis = .horizontal
        itemStackView.alignment = .center
        itemStackView.distribution = .fill
        itemStackView.spacing = CometChatSpacing.Padding.p1
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = imageTintColor
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = textColor
        titleLabel.font = textFont
        
        itemStackView.addArrangedSubview(iconImageView)
        itemStackView.addArrangedSubview(titleLabel)
        iconImageView.pin(anchors: [.height, .width], to: 20)
        
        return itemStackView
    }
    
    public func getConferenceCallTemplate(additionalConfiguration: AdditionalConfiguration) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.custom, type: conferenceCallTypeConstant, contentView: { [weak self] message, alignment, controller in
            
            guard let this = self else { return UIView() }
            guard let call = message as? CustomMessage else { return UIView() }
            if (call.deletedAt != 0.0) {
                if let deletedBubble = this.getDeleteMessageBubble(messageObject: call, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            
            let callBubbleSwiftUI = CometChatCallBubbleSwiftUI()
                .set(callType: ((((message as? CustomMessage)?.customData?["callType"] as? String) ?? "") == "audio") ? .audio : .video)
                .set(dateString: this.formatDate(from: Double(call.sentAt)))
            
            let callBubbleHostingController = UIHostingController(rootView: callBubbleSwiftUI)
            let callBubbleView = callBubbleHostingController.view!
            callBubbleView.backgroundColor = .clear
            callBubbleView.translatesAutoresizingMaskIntoConstraints = false
            callBubbleView.widthAnchor.constraint(equalToConstant: 240).isActive = true
            
            if message?.sender?.uid == CometChat.getLoggedInUser()?.uid {
                callBubbleSwiftUI.style = additionalConfiguration.messageBubbleStyle.outgoing.callBubbleStyle
            } else {
                callBubbleSwiftUI.style = additionalConfiguration.messageBubbleStyle.incoming.callBubbleStyle
            }
            
            let tapGesture = UITapGestureRecognizer(target: this, action: #selector(this.handleCallBubbleTap(_:)))
            callBubbleView.addGestureRecognizer(tapGesture)
            callBubbleView.tag = call.id
            
            return callBubbleView
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let message = message else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: message, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        } options: { message, group, controller in
            guard let message = message, let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: user, messageObject: message, controller: controller, group: group, additionalConfiguration: additionalConfiguration)
        }
    }
    
    @objc private func handleCallBubbleTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, let messageId = view.tag as? Int else { return }
        
        guard let message = findMessageById(messageId) as? CustomMessage else { return }
        
        if let customCallback = self.callingConfiguration?.callBubbleConfiguration?.onClick {
            customCallback()
            return
        }
        
        if let customData = message.customData, let sessionID = customData["sessionID"] as? String {
            DispatchQueue.main.async {
                let group = message.receiver as? Group
                var user: User?
                if group == nil {
                    if (message.receiver as? User)?.uid == CometChat.getLoggedInUser()?.uid {
                        user = message.sender as? User
                    } else {
                        user = message.receiver as? User
                    }
                }
                
                let callType: CallType = ((customData["callType"] as? String) ?? "") == "audio" ? .audio : .video
                
                if let controller = UIApplication.shared.windows.first?.rootViewController {
                    CometChatOngoingCallSwiftUI.present(
                        on: controller,
                        sessionId: sessionID,
                        callSettingsBuilder: self.getCallSettingsBuilder(user: user, group: group, isAudioOnly: callType == .audio),
                        callWorkFlow: .directCalling
                    )
                }
            }
        }
    }
    
    private func getCallSettingsBuilder(user: User?, group: Group?, isAudioOnly: Bool) -> CometChatCallsSDK.CallSettingsBuilder? {
        if let groupCallSettingsBuilder = self.callingConfiguration?.groupCallSettingsBuilder {
            return groupCallSettingsBuilder(user, group, isAudioOnly) as? CometChatCallsSDK.CallSettingsBuilder
        } else {
            var callSettingsBuilder = CallingDefaultBuilderSwiftUI.callSettingsBuilder
            callSettingsBuilder = callSettingsBuilder.setIsAudioOnly(isAudioOnly)
            if !isAudioOnly {
                callSettingsBuilder = callSettingsBuilder.setDefaultAudioMode("SPEAKER")
            }
            return callSettingsBuilder
        }
    }
    
    private func findMessageById(_ messageId: Int) -> BaseMessage? {
        return nil
    }
    
    func formatDate(from timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: CometChatLocalize.getLocale())
        dateFormatter.dateFormat = "dd MMM, hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    override func getId() -> String {
        return "Call-SwiftUI"
    }
    
    override func getLastConversationMessage(conversation: Conversation, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        
        if let lastMessage = conversation.lastMessage as? CustomMessage, lastMessage.type == conferenceCallTypeConstant, let additionalConfiguration {
            if lastMessage.sender?.uid == LoggedInUserInformation.getUID() {
                if (lastMessage.customData?["callType"] as? String ?? "") == "video" {
                    return addImageToText(text: ConversationConstants.youInitiatedGroupCall, image: "initiated_video_call", additionalConfiguration: additionalConfiguration)
                } else {
                    return addImageToText(text: ConversationConstants.youInitiatedGroupAudioCall, image: "initiated_voice_call", additionalConfiguration: additionalConfiguration)
                }
                
            } else {
                if let sender = lastMessage.sender?.name {
                    if (lastMessage.customData?["callType"] as? String ?? "") == "video" {
                        return addImageToText(text: sender + " " + ConversationConstants.hasIntiatedGroupCall, image: "received_video_call", additionalConfiguration: additionalConfiguration)
                    } else {
                        return addImageToText(text: sender + " " + ConversationConstants.hasIntiatedGroupAudioCall, image: "received_voice_call", additionalConfiguration: additionalConfiguration)
                    }
                }
            }
        } else if let call = conversation.lastMessage as? Call {
            let isLoggedInUser: Bool = (call.callInitiator as? User)?.uid == LoggedInUserInformation.getUID()
            switch call.callStatus {
            case .initiated:
                return NSAttributedString(string: isLoggedInUser ? "OUTGOING_CALL".localize() : "INCOMING_CALL".localize())
            case .unanswered:
                return NSAttributedString(string: isLoggedInUser ? "CALL_UNANSWERED".localize() :  "MISSED_CALL".localize())
            case .rejected:
                return NSAttributedString(string: isLoggedInUser ? "CALL_REJECTED".localize() : "MISSED_CALL".localize())
            case .cancelled:
                return NSAttributedString(string: isLoggedInUser ? "CALL_CANCELLED".localize() : "MISSED_CALL".localize())
            case .busy:
                return NSAttributedString(string: isLoggedInUser ? "CALL_REJECTED".localize() : "MISSED_CALL".localize())
            case .ended:
                return NSAttributedString(string: "CALL_ENDED".localize())
            case .ongoing:
                return NSAttributedString(string: "CALL_ACCEPTED".localize())
            @unknown default: break
            }
        }
        
        return super.getLastConversationMessage(conversation: conversation, additionalConfiguration: additionalConfiguration)
    }
    
    override func getAuxiliaryHeaderMenu(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?, additionalConfiguration: AdditionalConfiguration) -> UIStackView? {
        if let user = user, user.blockedByMe != true {
            let callButtonsSwiftUI = CometChatCallButtonsSwiftUI()
                .set(user: user)
            
            setupConfigurationFor(callButtonsSwiftUI: callButtonsSwiftUI, additionalConfiguration: additionalConfiguration)
            
            let hostingController = UIHostingController(rootView: callButtonsSwiftUI)
            hostingController.view.backgroundColor = .clear
            
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.distribution = .fill
            stackView.spacing = 8
            
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.widthAnchor.constraint(equalToConstant: 80).isActive = true
            hostingController.view.heightAnchor.constraint(equalToConstant: 24).isActive = true
            stackView.addArrangedSubview(hostingController.view)
            
            return stackView
        }
        
        if let group = group {
            let callButtonsSwiftUI = CometChatCallButtonsSwiftUI()
                .set(group: group)
            
            setupConfigurationFor(callButtonsSwiftUI: callButtonsSwiftUI, additionalConfiguration: additionalConfiguration)
            
            let hostingController = UIHostingController(rootView: callButtonsSwiftUI)
            hostingController.view.backgroundColor = .clear
            
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.distribution = .fill
            stackView.spacing = 8
            
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.widthAnchor.constraint(equalToConstant: 80).isActive = true
            hostingController.view.heightAnchor.constraint(equalToConstant: 24).isActive = true
            stackView.addArrangedSubview(hostingController.view)
            
            return stackView
        }
        
        return nil
    }
    
    private func setupConfigurationFor(callButtonsSwiftUI: CometChatCallButtonsSwiftUI, additionalConfiguration: AdditionalConfiguration) {
        if let outgoingCallConfiguration = self.callingConfiguration?.outgoingCallConfiguration {
            callButtonsSwiftUI.set(outgoingCallConfiguration: outgoingCallConfiguration)
        }
        
        if let callButtonConfiguration = callingConfiguration?.callButtonConfiguration {
            if let hideVoiceCall = callButtonConfiguration.hideVoiceCall {
                callButtonsSwiftUI.set(hideVoiceCallButton: hideVoiceCall)
            }
            
            if let hideVideoCall = callButtonConfiguration.hideVideoCall {
                callButtonsSwiftUI.set(hideVideoCallButton: hideVideoCall)
            }
            
            if let onError = callButtonConfiguration.onError {
                callButtonsSwiftUI.set(onError: onError)
            }
            
            if let callSettingsBuilder = callButtonConfiguration.callSettingsBuilder {
                callButtonsSwiftUI.set(callSettingsBuilder: callSettingsBuilder)
            }
            
            if let outgoingCallConfiguration = callButtonConfiguration.outgoingCallConfiguration {
                callButtonsSwiftUI.set(outgoingCallConfiguration: outgoingCallConfiguration)
            }
        }
        
        if additionalConfiguration.hideVoiceCallButton {
            callButtonsSwiftUI.set(hideVoiceCallButton: true)
        }
        
        if additionalConfiguration.hideVideoCallButton {
            callButtonsSwiftUI.set(hideVideoCallButton: true)
        }
    }
}

extension CallingExtensionDecoratorSwiftUI: CometChatCallDelegate {
    
    func onIncomingCallReceived(incomingCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        
        if CometChatUIKit.uiKitSettings?.enableIncomingCall == false { return }
        if (incomingCall?.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid { return }
        
        DispatchQueue.main.async {
            if let call = incomingCall {
                let incomingCallSwiftUI = CometChatIncomingCallSwiftUI()
                    .set(call: call)
                
                if let incomingCallConfiguration = self.callingConfiguration?.incomingCallConfiguration {
                    if let disableSoundForCalls = incomingCallConfiguration.disableSoundForCalls {
                        incomingCallSwiftUI.disable(soundForCalls: disableSoundForCalls)
                    }
                    if let customSoundForCalls = incomingCallConfiguration.customSoundForCalls {
                        incomingCallSwiftUI.set(customSoundForCalls: customSoundForCalls)
                    }
                    if let callSettingsBuilder = incomingCallConfiguration.callSettingsBuilder {
                        incomingCallSwiftUI.set(callSettingsBuilder: callSettingsBuilder)
                    }
                    if let onCancelClick = incomingCallConfiguration.onCancelClick {
                        incomingCallSwiftUI.set(onCancelClick: onCancelClick)
                    }
                    if let onAcceptClick = incomingCallConfiguration.onAcceptClick {
                        incomingCallSwiftUI.set(onAcceptClick: onAcceptClick)
                    }
                }
                
                let hostingController = UIHostingController(rootView: incomingCallSwiftUI)
                hostingController.modalPresentationStyle = .overCurrentContext
                
                if let window = UIApplication.shared.windows.first, let rootViewController = window.rootViewController {
                    rootViewController.present(hostingController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {}
    
    func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {}
    
    func onIncomingCallCancelled(canceledCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {}
}

#endif
