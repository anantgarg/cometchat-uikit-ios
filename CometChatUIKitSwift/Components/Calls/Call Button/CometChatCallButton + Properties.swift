//
//  CometChatCallButton + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 09/02/25.
//

import CometChatSDK
import Foundation
import UIKit

#if canImport(CometChatCallsSDK)

    public extension CometChatCallButtons {
        // MARK: Data

        @discardableResult
        func set(user: User) -> Self {
            self.user = user
            buildButton(forUser: user)
            return self
        }

        @discardableResult
        func set(group: Group) -> Self {
            self.group = group
            buildButton(forGroup: group)
            return self
        }

        @discardableResult func set(callSettingsBuilder: @escaping ((_ user: User?, _ group: Group?, _ isAudioOnly: Bool) -> Any)) -> Self {
            callSettingsBuilderCallBack = callSettingsBuilder
            return self
        }

        // MARK: Events

        @discardableResult
        func set(onError: @escaping ((_ error: CometChatException?) -> Void)) -> Self {
            self.onError = onError
            return self
        }

        // MARK: Congiguration

        @discardableResult
        func set(outgoingCallConfiguration: OutgoingCallConfiguration?) -> Self {
            self.outgoingCallConfiguration = outgoingCallConfiguration
            return self
        }

        @discardableResult
        func set(controller: UIViewController?) -> Self {
            self.controller = controller
            return self
        }
    }
#endif
