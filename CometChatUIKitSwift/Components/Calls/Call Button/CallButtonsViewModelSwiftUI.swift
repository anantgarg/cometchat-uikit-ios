//
//
//

#if canImport(CometChatCallsSDK)

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class CallButtonsViewModelSwiftUI: ObservableObject {
    @Published var user: User?
    @Published var group: Group?
    @Published var voiceCallIconText: String?
    @Published var videoCallIconText: String?
    @Published var conferenceCallIconText: String?
    @Published var hideVoiceCallButton: Bool = false
    @Published var hideVideoCallButton: Bool = false
    @Published var disabled: Bool = false
    
    private var uniqueID = Date().timeIntervalSince1970
    
    public init() {
        connect()
    }
    
    deinit {
        disconnect()
    }
    
    public func connect() {
        CometChatMessageEvents.addListener("call-button-message-event-listener-\(uniqueID)", self)
        CometChat.addCallListener("call-button-call-listener-\(uniqueID)", self)
        CometChatCallEvents.addListener("call-button-call-event-listner-\(uniqueID)", self)
    }
    
    public func disconnect() {
        CometChatMessageEvents.removeListener("call-button-message-event-listener-\(uniqueID)")
        CometChat.removeCallListener("call-button-call-listener-\(uniqueID)")
        CometChatCallEvents.removeListener("call-button-call-event-listner-\(uniqueID)")
    }
    
    public func set(user: User?) {
        DispatchQueue.main.async {
            self.user = user
        }
    }
    
    public func set(group: Group?) {
        DispatchQueue.main.async {
            self.group = group
        }
    }
    
    public func set(voiceCallIconText: String?) {
        DispatchQueue.main.async {
            self.voiceCallIconText = voiceCallIconText
        }
    }
    
    public func set(videoCallIconText: String?) {
        DispatchQueue.main.async {
            self.videoCallIconText = videoCallIconText
        }
    }
    
    public func set(conferenceCallIconText: String?) {
        DispatchQueue.main.async {
            self.conferenceCallIconText = conferenceCallIconText
        }
    }
    
    public func set(hideVoiceCallButton: Bool) {
        DispatchQueue.main.async {
            self.hideVoiceCallButton = hideVoiceCallButton
        }
    }
    
    public func set(hideVideoCallButton: Bool) {
        DispatchQueue.main.async {
            self.hideVideoCallButton = hideVideoCallButton
        }
    }
    
    public func setDisabled(_ disabled: Bool) {
        DispatchQueue.main.async {
            self.disabled = disabled
        }
    }
}

extension CallButtonsViewModelSwiftUI: CometChatMessageEventListener {
    public func ccMessageSent(message: CometChatSDK.BaseMessage, status: MessageStatus) {
    }
}

extension CallButtonsViewModelSwiftUI: CometChatCallDelegate {
    public func onIncomingCallReceived(incomingCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
    }
    
    public func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
    }
    
    public func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        setDisabled(false)
    }
    
    public func onIncomingCallCancelled(canceledCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
    }
    
    public func onCallEndedMessageReceived(endedCall: Call?, error: CometChatException?) {
        setDisabled(false)
    }
}

extension CallButtonsViewModelSwiftUI: CometChatCallEventListener {
    public func ccCallEnded(call: Call) {
        setDisabled(false)
    }
    
    public func ccCallRejected(call: Call) {
        setDisabled(false)
    }
    
    public func ccOutgoingCall(call: Call) {
        if call.callStatus == .cancelled || call.callStatus == .rejected {
            setDisabled(false)
        }
    }
}

#endif
