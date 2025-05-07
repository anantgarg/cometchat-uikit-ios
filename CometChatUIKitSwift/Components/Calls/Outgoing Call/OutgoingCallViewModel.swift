//
//  OutgoingCallViewModel.swift
//
//
//  Created by Pushpsen Airekar on 14/03/23.
//

import CometChatSDK
import Foundation

protocol OutgoingCallViewModelProtocol {
    var onOutgoingCallAccepted: ((CometChatSDK.Call) -> Void)? { get }
    var onOutgoingCallRejected: ((CometChatSDK.Call) -> Void)? { get }
    var onError: ((CometChatSDK.CometChatException) -> Void)? { get }
}

class OutgoingCallViewModel: OutgoingCallViewModelProtocol {
    let listenerID = "outgoing-call-listener"
    var onOutgoingCallAccepted: ((CometChatSDK.Call) -> Void)?
    var onOutgoingCallRejected: ((CometChatSDK.Call) -> Void)?
    var onError: ((CometChatSDK.CometChatException) -> Void)?

    public init() {}

    func connect() {
        CometChat.addCallListener(listenerID, self)
    }

    func disconnect() {
        CometChat.removeCallListener(listenerID)
    }
}

extension OutgoingCallViewModel: CometChatCallDelegate {
    func onIncomingCallReceived(incomingCall _: CometChatSDK.Call?, error _: CometChatSDK.CometChatException?) {}

    func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error _: CometChatSDK.CometChatException?) {
        if let call = acceptedCall {
            onOutgoingCallAccepted?(call)
        }
    }

    func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error _: CometChatSDK.CometChatException?) {
        if let call = rejectedCall {
            onOutgoingCallRejected?(call)
        }
    }

    func onIncomingCallCancelled(canceledCall _: CometChatSDK.Call?, error _: CometChatSDK.CometChatException?) {}
}
