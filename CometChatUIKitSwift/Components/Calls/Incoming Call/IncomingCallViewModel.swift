//
//  IncomingCallViewModel.swift
//
//
//  Created by Pushpsen Airekar on 14/03/23.
//

import CometChatSDK
import Foundation

protocol IncomingCallViewModelProtocol {
    var onIncomingCallReceived: ((CometChatSDK.Call) -> Void)? { get }
    var dismissIncomingCallView: ((CometChatSDK.Call) -> Void)? { get }
    var onError: ((CometChatSDK.CometChatException) -> Void)? { get }
}

class IncomingCallViewModel: IncomingCallViewModelProtocol {
    let listenerID = "incoming-call-listener"
    var onIncomingCallReceived: ((CometChatSDK.Call) -> Void)?
    var dismissIncomingCallView: ((CometChatSDK.Call) -> Void)?
    var onCallAccepted: ((CometChatSDK.Call) -> Void)?
    var onCallRejected: ((CometChatSDK.Call) -> Void)?
    var onError: ((CometChatSDK.CometChatException) -> Void)?
    var call: Call?

    public init() {}

    func connect() {
        CometChat.addCallListener(listenerID, self)
    }

    func disconnect() {
        CometChat.removeCallListener(listenerID)
    }

    func acceptCall(call: Call) {
        guard let sessionID = call.sessionID else { return }
        CometChat.acceptCall(sessionID: sessionID) { call in
            guard let call else { return }
            CometChatCallEvents.ccCallAccepted(call: call)
            self.onCallAccepted?(call)
        } onError: { error in
            guard let error else { return }
            self.onError?(error)
        }
    }

    func rejectCall(call: Call) {
        guard let sessionID = call.sessionID else { return }
        CometChat.rejectCall(sessionID: sessionID, status: .rejected) { call in
            guard let call else { return }
            CometChatCallEvents.ccCallRejected(call: call)
            self.onCallRejected?(call)
        } onError: { error in
            guard let error else { return }
            self.onError?(error)
        }
    }

    func getSubtitle(call: Call) -> String {
        call.callType == .audio ? "INCOMING_AUDIO_CALL".localize() : "INCOMING_VIDEO_CALL".localize()
    }
}

extension IncomingCallViewModel: CometChatCallDelegate {
    func onIncomingCallReceived(incomingCall: CometChatSDK.Call?, error _: CometChatSDK.CometChatException?) {
        if let call = incomingCall {
            onIncomingCallReceived?(call)
        }
    }

    func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error _: CometChatSDK.CometChatException?) {
        if acceptedCall?.sessionID == call?.sessionID {
            if let call = acceptedCall {
                dismissIncomingCallView?(call)
            }
        }
    }

    func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error _: CometChatSDK.CometChatException?) {
        if rejectedCall?.sessionID == call?.sessionID {
            if let call = rejectedCall {
                dismissIncomingCallView?(call)
            }
        }
    }

    func onIncomingCallCancelled(canceledCall: CometChatSDK.Call?, error _: CometChatSDK.CometChatException?) {
        if let call = canceledCall {
            dismissIncomingCallView?(call)
        }
    }
}
