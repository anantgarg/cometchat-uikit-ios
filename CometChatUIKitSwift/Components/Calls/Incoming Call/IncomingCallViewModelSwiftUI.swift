//
//
//

#if canImport(CometChatCallsSDK)

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class IncomingCallViewModelSwiftUI: ObservableObject {
    @Published var call: Call?
    @Published var isCallAccepted: Bool = false
    @Published var isCallRejected: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    
    private let listenerID = "incoming-call-listener-swiftui"
    
    public init() {}
    
    public func set(call: Call?) {
        DispatchQueue.main.async {
            self.call = call
        }
    }
    
    public func connect() {
        CometChat.addCallListener(listenerID, self)
    }
    
    public func disconnect() {
        CometChat.removeCallListener(listenerID)
    }
    
    public func acceptCall(call: Call) {
        guard let sessionID = call.sessionID else { return }
        CometChat.acceptCall(sessionID: sessionID) { call in
            guard let call = call else { return }
            CometChatCallEvents.ccCallAccepted(call: call)
            DispatchQueue.main.async {
                self.isCallAccepted = true
            }
        } onError: { error in
            guard let error = error else { return }
            DispatchQueue.main.async {
                self.isError = true
                self.errorMessage = error.errorDescription ?? "Error accepting call"
            }
        }
    }
    
    public func rejectCall(call: Call) {
        guard let sessionID = call.sessionID else { return }
        CometChat.rejectCall(sessionID: sessionID, status: .rejected) { call in
            guard let call = call else { return }
            CometChatCallEvents.ccCallRejected(call: call)
            DispatchQueue.main.async {
                self.isCallRejected = true
            }
        } onError: { error in
            guard let error = error else { return }
            DispatchQueue.main.async {
                self.isError = true
                self.errorMessage = error.errorDescription ?? "Error rejecting call"
            }
        }
    }
    
    public func getSubtitle(call: Call) -> String {
        return call.callType == .audio ? "INCOMING_AUDIO_CALL".localize() : "INCOMING_VIDEO_CALL".localize()
    }
}

extension IncomingCallViewModelSwiftUI: CometChatCallDelegate {
    public func onIncomingCallReceived(incomingCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let call = incomingCall {
            DispatchQueue.main.async {
                self.call = call
            }
        }
    }
    
    public func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if acceptedCall?.sessionID == call?.sessionID {
            if let _ = acceptedCall {
                DispatchQueue.main.async {
                    self.isCallAccepted = true
                }
            }
        }
    }
    
    public func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if rejectedCall?.sessionID == call?.sessionID {
            if let _ = rejectedCall {
                DispatchQueue.main.async {
                    self.isCallRejected = true
                }
            }
        }
    }
    
    public func onIncomingCallCancelled(canceledCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if canceledCall?.sessionID == call?.sessionID {
            if let _ = canceledCall {
                DispatchQueue.main.async {
                    self.isCallRejected = true
                }
            }
        }
    }
    
    public func onCallEndedMessageReceived(endedCall: Call?, error: CometChatException?) {
    }
}

#endif
