//
//
//

#if canImport(CometChatCallsSDK)

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class OutgoingCallViewModelSwiftUI: ObservableObject {
    @Published var call: Call?
    @Published var isCallAccepted: Bool = false
    @Published var isCallRejected: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    
    private let listenerID = "outgoing-call-listener-swiftui"
    
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
    
    public func cancelCall(call: Call) {
        guard let sessionID = call.sessionID else { return }
        CometChat.rejectCall(sessionID: sessionID, status: .cancelled) { call in
            if let call = call {
                CometChatCallEvents.ccCallRejected(call: call)
                DispatchQueue.main.async {
                    self.isCallRejected = true
                }
            }
        } onError: { error in
            guard let error = error else { return }
            DispatchQueue.main.async {
                self.isError = true
                self.errorMessage = error.errorDescription ?? "Error cancelling call"
            }
        }
    }
}

extension OutgoingCallViewModelSwiftUI: CometChatCallDelegate {
    public func onIncomingCallReceived(incomingCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
    }
    
    public func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let call = acceptedCall {
            DispatchQueue.main.async {
                self.isCallAccepted = true
            }
        }
    }
    
    public func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let call = rejectedCall {
            DispatchQueue.main.async {
                self.isCallRejected = true
            }
        }
    }
    
    public func onIncomingCallCancelled(canceledCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
    }
    
    public func onCallEndedMessageReceived(endedCall: Call?, error: CometChatException?) {
    }
}

#endif
