//
//  CometChatOutgoingCall + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 09/02/25.
//

import CometChatSDK
import Foundation

#if canImport(CometChatCallsSDK)

    public extension CometChatOutgoingCall {
        // MARK: Data

        @discardableResult
        func set(call: Call) -> Self {
            self.call = call
            return self
        }

        @discardableResult func set(callSettingsBuilder: Any) -> Self {
            if let callSettingsBuilder = callSettingsBuilder as? CallSettingsBuilder {
                self.callSettingsBuilder = callSettingsBuilder
            }
            return self
        }

        // MARK: Events

        @discardableResult
        func set(onCancelClick: @escaping (_ call: Call?, _ controller: UIViewController?) -> Void) -> Self {
            self.onCancelClick = onCancelClick
            return self
        }

        @discardableResult
        func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
            self.onError = onError
            return self
        }

        @discardableResult
        func set(user: User) -> Self {
            self.user = user
            return self
        }

        // MARK: Configuration

        @discardableResult
        func disable(soundForCalls: Bool) -> Self {
            disableSoundForCalls = soundForCalls
            return self
        }

        @discardableResult
        func set(customSoundForCalls: URL?) -> Self {
            self.customSoundForCalls = customSoundForCalls
            return self
        }

        // MARK: Overrides

        @discardableResult
        func set(subtitleView: ((_ call: Call) -> UIView)?) -> Self {
            self.subtitleView = subtitleView
            return self
        }

        @discardableResult
        func set(titleView: ((_ call: Call) -> UIView)?) -> Self {
            self.titleView = titleView
            return self
        }

        @discardableResult
        func set(avatarView: ((_ call: Call) -> UIView)?) -> Self {
            self.avatarView = avatarView
            return self
        }

        @discardableResult
        func set(cancelView: ((_ call: Call) -> UIView)?) -> Self {
            self.cancelView = cancelView
            return self
        }
    }
#endif
