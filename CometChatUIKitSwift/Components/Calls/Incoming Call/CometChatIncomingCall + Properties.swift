//
//  CometChatIncomingCall + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 09/02/25.
//

import CometChatSDK
import Foundation

#if canImport(CometChatCallsSDK)

    public extension CometChatIncomingCall {
        // MARK: Data

        @discardableResult
        func set(call: Call) -> Self {
            viewModel.call = call
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
        func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
            self.onError = onError
            return self
        }

        @discardableResult
        func set(onCancelClick: @escaping (_ call: Call?, _ controller: UIViewController?) -> Void) -> Self {
            self.onCancelClick = onCancelClick
            return self
        }

        @discardableResult
        func set(onAcceptClick: @escaping (_ call: Call?, _ controller: UIViewController?) -> Void) -> Self {
            self.onAcceptClick = onAcceptClick
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
        func set(trailView: ((_ call: Call) -> UIView)?) -> Self {
            self.trailView = trailView
            return self
        }

        @discardableResult
        func set(titleView: ((_ call: Call) -> UIView)?) -> Self {
            self.titleView = titleView
            return self
        }

        @discardableResult
        func set(listItemView: ((_ call: Call) -> UIView)?) -> Self {
            self.listItemView = listItemView
            return self
        }

        @discardableResult
        func set(leadingView: ((_ call: Call) -> UIView)?) -> Self {
            self.leadingView = leadingView
            return self
        }
    }
#endif
