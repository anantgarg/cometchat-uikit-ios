//
//
//

#if canImport(CometChatCallsSDK)

import SwiftUI
import CometChatSDK

public struct CometChatCallButtonsSwiftUI: View {
    @StateObject private var viewModel = CallButtonsViewModelSwiftUI()
    @State private var controller: UIViewController?
    
    private var callButtonsStyle: ButtonStyle?
    private var outgoingCallConfiguration: OutgoingCallConfiguration?
    private var onVoiceCallClick: ((User?, Group?) -> Void)?
    private var onVideoCallClick: ((User?, Group?) -> Void)?
    private var onError: ((CometChatException?) -> Void)?
    private var callSettingsBuilderCallBack: ((User?, Group?, Bool) -> Any)?
    
    public static var style = CallButtonStyle()
    private var style = CometChatCallButtonsSwiftUI.style
    
    public init(width: CGFloat, height: CGFloat) {}
    
    public var body: some View {
        HStack(spacing: CometChatSpacing.Spacing.s2) {
            if let user = viewModel.user {
                if !viewModel.hideVoiceCallButton {
                    Button(action: {
                        handleVoiceCallClick(user: user)
                    }) {
                        buttonContent(isVoiceCall: true)
                    }
                    .disabled(viewModel.disabled)
                }
                
                if !viewModel.hideVideoCallButton {
                    Button(action: {
                        handleVideoCallClick(user: user)
                    }) {
                        buttonContent(isVoiceCall: false)
                    }
                    .disabled(viewModel.disabled)
                }
            } else if let group = viewModel.group {
                Button(action: {
                    handleVoiceCallClick(group: group)
                }) {
                    buttonContent(isVoiceCall: true)
                }
                .disabled(viewModel.disabled)
                
                Button(action: {
                    handleVideoCallClick(group: group)
                }) {
                    buttonContent(isVoiceCall: false)
                }
                .disabled(viewModel.disabled)
            }
        }
        .onAppear {
            setupController()
        }
    }
    
    private func buttonContent(isVoiceCall: Bool) -> some View {
        HStack {
            Image(uiImage: isVoiceCall ? style.audioCallIcon : style.videoCallIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(Color(isVoiceCall ? style.audioCallIconTint : style.videoCallIconTint))
            
            if let text = isVoiceCall ? viewModel.voiceCallIconText : viewModel.videoCallIconText {
                Text(text)
                    .font(Font(isVoiceCall ? style.audioCallTextFont : style.videoCallTextFont))
                    .foregroundColor(Color(isVoiceCall ? style.audioCallTextColor : style.videoCallTextColor))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(isVoiceCall ? style.audioCallButtonBackground : style.videoCallButtonBackground))
        .cornerRadius((isVoiceCall ? style.audioCallButtonCornerRadius : style.videoCallButtonCornerRadius)?.cornerRadius ?? 8)
        .overlay(
            RoundedRectangle(cornerRadius: (isVoiceCall ? style.audioCallButtonCornerRadius : style.videoCallButtonCornerRadius)?.cornerRadius ?? 8)
                .stroke(Color(isVoiceCall ? style.audioCallButtonBorderColor ?? .clear : style.videoCallButtonBorderColor ?? .clear), 
                        lineWidth: isVoiceCall ? style.audioCallButtonBorder ?? 0 : style.videoCallButtonBorder ?? 0)
        )
    }
    
    private func setupController() {
        let rootViewController = UIApplication.shared.windows.first?.rootViewController
        self.controller = rootViewController
    }
    
    private func handleVoiceCallClick(user: User? = nil, group: Group? = nil) {
        if viewModel.disabled { return }
        
        if let onVoiceCallClick = onVoiceCallClick {
            onVoiceCallClick(user, group)
        } else if let user = user, let uid = user.uid {
            viewModel.setDisabled(true)
            let call = Call(receiverId: uid, callType: .audio, receiverType: .user)
            initiateDefaultAudioCall(call)
        } else if let group = group, let sessionID = group.guid {
            viewModel.setDisabled(true)
            
            let voiceMeeting = CustomMessage(receiverUid: group.guid ?? "", receiverType: .group, customData: ["sessionID":"\(sessionID)", "callType":"audio"], type: "meeting")
            voiceMeeting.metaData = [
                "pushNotification":"\(String(describing: CometChat.getLoggedInUser()?.name))" + "has initiated group audio call",
                "incrementUnreadCount": true
            ]
            voiceMeeting.updateConversation = true
            voiceMeeting.metaData?["incrementUnreadCount"] = true
            voiceMeeting.muid = "\(Int(Date().timeIntervalSince1970))"
            voiceMeeting.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            voiceMeeting.sender = CometChat.getLoggedInUser()
            
            CometChatUIKit.sendCustomMessage(message: voiceMeeting)
            startGroupCall(sessionID: "\(sessionID)_\(Date().timeIntervalSince1970)", group: group, isVideoCall: false)
        }
    }
    
    private func handleVideoCallClick(user: User? = nil, group: Group? = nil) {
        if viewModel.disabled { return }
        
        if let onVideoCallClick = onVideoCallClick {
            onVideoCallClick(user, group)
        } else if let user = user, let uid = user.uid {
            viewModel.setDisabled(true)
            let call = Call(receiverId: uid, callType: .video, receiverType: .user)
            initiateDefaultVideoCall(call)
        } else if let group = group, let sessionID = group.guid {
            viewModel.setDisabled(true)
            
            let videoMeeting = CustomMessage(receiverUid: group.guid ?? "", receiverType: .group, customData: ["sessionID":"\(sessionID)", "callType":"video"], type: "meeting")
            videoMeeting.metaData = [
                "pushNotification":"\(String(describing: CometChat.getLoggedInUser()?.name))" + "has initiated group video call",
                "incrementUnreadCount": true
            ]
            videoMeeting.updateConversation = true
            videoMeeting.metaData?["incrementUnreadCount"] = true
            videoMeeting.muid = "\(Int(Date().timeIntervalSince1970))"
            videoMeeting.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            videoMeeting.sender = CometChat.getLoggedInUser()
            
            CometChatUIKit.sendCustomMessage(message: videoMeeting)
            startGroupCall(sessionID: "\(sessionID)_\(Date().timeIntervalSince1970)", group: group, isVideoCall: true)
        }
    }
    
    private func startGroupCall(sessionID: String, group: Group, isVideoCall: Bool) {
        DispatchQueue.main.async {
            let ongoingCall = CometChatOngoingCall()
            ongoingCall.set(sessionId: sessionID)
            if let callSettingsBuilderCallBack = callSettingsBuilderCallBack {
                let callSettingsBuilder = callSettingsBuilderCallBack(nil, group, false) as? CometChatCallsSDK.CallSettingsBuilder
                ongoingCall.set(callSettingsBuilder: callSettingsBuilder)
            } else {
                var callSettingsBuilder = CallingDefaultBuilder.callSettingsBuilder as? CometChatCallsSDK.CallSettingsBuilder
                callSettingsBuilder = callSettingsBuilder?.setIsAudioOnly(!isVideoCall)
                callSettingsBuilder = callSettingsBuilder?.setDefaultAudioMode(isVideoCall ? "SPEAKER" : "EARPIECE")
                if isVideoCall {
                    callSettingsBuilder = callSettingsBuilder?.setStartVideoMuted(false)
                }
                ongoingCall.set(callSettingsBuilder: callSettingsBuilder)
            }
            ongoingCall.set(callWorkFlow: .directCalling)
            ongoingCall.modalPresentationStyle = .fullScreen
            controller?.present(ongoingCall, animated: true, completion: {
                viewModel.setDisabled(false)
            })
        }
    }
    
    private func setupOutgoingCallConfiguration(outgoingCall: CometChatOutgoingCall) {
        if let outgoingCallConfiguration = outgoingCallConfiguration {
            if let declineButtonIcon = outgoingCallConfiguration.declineButtonIcon {
                outgoingCall.style.declineButtonIcon = declineButtonIcon
            }
            if let disableSoundForCalls = outgoingCallConfiguration.disableSoundForCalls {
                outgoingCall.disable(soundForCalls: disableSoundForCalls)
            }
            if let customSoundForCalls = outgoingCallConfiguration.customSoundForCalls {
                outgoingCall.set(customSoundForCalls: customSoundForCalls)
            }
            if let avatarStyle = outgoingCallConfiguration.avatarStyle {
                outgoingCall.avatarStyle = avatarStyle
            }
            if let outgoingCallStyle = outgoingCallConfiguration.outgoingCallStyle {
                outgoingCall.style = outgoingCallStyle
            }
            if let callSettingsBuilder = outgoingCallConfiguration.callSettingsBuilder {
                outgoingCall.set(callSettingsBuilder: callSettingsBuilder)
            }
        }
    }
    
    private func initiateDefaultAudioCall(_ call: Call) {
        CometChat.initiateCall(call: call) { call in
            DispatchQueue.main.async { [self] in
                guard let call = call else { return }
                CometChatCallEvents.ccOutgoingCall(call: call)
                let outgoingCall = CometChatOutgoingCall()
                outgoingCall.set(call: call)
                outgoingCall.modalPresentationStyle = .fullScreen
                if let callSettingsBuilder = callSettingsBuilderCallBack?(viewModel.user, viewModel.group, true) {
                    outgoingCall.set(callSettingsBuilder: callSettingsBuilder)
                }
                setupOutgoingCallConfiguration(outgoingCall: outgoingCall)
                outgoingCall.set(onCancelClick: { call, controller in
                    CometChat.rejectCall(sessionID: call?.sessionID ?? "", status: .cancelled) { call in
                        if let call = call {
                            CometChatCallEvents.ccCallRejected(call: call)
                        }
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    } onError: { error in
                        onError?(error)
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    }
                })
                
                controller?.present(outgoingCall, animated: true)
            }
        } onError: { error in
            onError?(error)
        }
    }
    
    private func initiateDefaultVideoCall(_ call: Call) {
        CometChat.initiateCall(call: call) { call in
            DispatchQueue.main.async { [self] in
                guard let call = call else { return }
                CometChatCallEvents.ccOutgoingCall(call: call)
                let outgoingCall = CometChatOutgoingCall()
                outgoingCall.set(call: call)
                outgoingCall.modalPresentationStyle = .fullScreen
                if let callSettingsBuilder = callSettingsBuilderCallBack?(viewModel.user, viewModel.group, true) {
                    outgoingCall.set(callSettingsBuilder: callSettingsBuilder)
                }
                setupOutgoingCallConfiguration(outgoingCall: outgoingCall)
                outgoingCall.set(onCancelClick: { call, controller in
                    CometChat.rejectCall(sessionID: call?.sessionID ?? "", status: .cancelled) { call in
                        if let call = call {
                            CometChatCallEvents.ccCallRejected(call: call)
                        }
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    } onError: { error in
                        onError?(error)
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    }
                })
                
                controller?.present(outgoingCall, animated: true)
            }
        } onError: { error in
            onError?(error)
        }
    }
    
    @discardableResult
    public func set(user: User?) -> Self {
        var view = self
        view.viewModel.set(user: user)
        return view
    }
    
    @discardableResult
    public func set(group: Group?) -> Self {
        var view = self
        view.viewModel.set(group: group)
        return view
    }
    
    @discardableResult
    public func set(voiceCallIconText: String?) -> Self {
        var view = self
        view.viewModel.set(voiceCallIconText: voiceCallIconText)
        return view
    }
    
    @discardableResult
    public func set(videoCallIconText: String?) -> Self {
        var view = self
        view.viewModel.set(videoCallIconText: videoCallIconText)
        return view
    }
    
    @discardableResult
    public func set(conferenceCallIconText: String?) -> Self {
        var view = self
        view.viewModel.set(conferenceCallIconText: conferenceCallIconText)
        return view
    }
    
    @discardableResult
    public func set(hideVoiceCallButton: Bool) -> Self {
        var view = self
        view.viewModel.set(hideVoiceCallButton: hideVoiceCallButton)
        return view
    }
    
    @discardableResult
    public func set(hideVideoCallButton: Bool) -> Self {
        var view = self
        view.viewModel.set(hideVideoCallButton: hideVideoCallButton)
        return view
    }
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        var view = self
        view.controller = controller
        return view
    }
    
    @discardableResult
    public func set(callButtonsStyle: ButtonStyle?) -> Self {
        var view = self
        view.callButtonsStyle = callButtonsStyle
        return view
    }
    
    @discardableResult
    public func set(outgoingCallConfiguration: OutgoingCallConfiguration?) -> Self {
        var view = self
        view.outgoingCallConfiguration = outgoingCallConfiguration
        return view
    }
    
    @discardableResult
    public func onVoiceCallClick(onVoiceCallClick: @escaping ((User?, Group?) -> Void)) -> Self {
        var view = self
        view.onVoiceCallClick = onVoiceCallClick
        return view
    }
    
    @discardableResult
    public func onVideoCallClick(onVideoCallClick: @escaping ((User?, Group?) -> Void)) -> Self {
        var view = self
        view.onVideoCallClick = onVideoCallClick
        return view
    }
    
    @discardableResult
    public func onError(onError: @escaping ((CometChatException?) -> Void)) -> Self {
        var view = self
        view.onError = onError
        return view
    }
    
    @discardableResult
    public func set(callSettingsBuilderCallBack: @escaping ((User?, Group?, Bool) -> Any)) -> Self {
        var view = self
        view.callSettingsBuilderCallBack = callSettingsBuilderCallBack
        return view
    }
    
    @discardableResult
    public func set(style: CallButtonStyle) -> Self {
        var view = self
        view.style = style
        return view
    }
}

extension CometChatCallButtonsSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatCallButtonsSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatCallButtonsSwiftUI(width: 200, height: 40)
                .set(user: User(uid: "user1", name: "John Doe"))
                .set(voiceCallIconText: "Audio")
                .set(videoCallIconText: "Video")
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("User Call Buttons")
            
            CometChatCallButtonsSwiftUI(width: 200, height: 40)
                .set(group: Group(guid: "group1", name: "Team Meeting", groupType: .public))
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Group Call Buttons")
            
            CometChatCallButtonsSwiftUI(width: 200, height: 40)
                .set(user: User(uid: "user1", name: "John Doe"))
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Dark Mode")
        }
    }
}

#endif
