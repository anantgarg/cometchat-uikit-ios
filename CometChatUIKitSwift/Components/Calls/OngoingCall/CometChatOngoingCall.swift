//
//  CometChatOngoingCall.swift
//
//
//  Created by Pushpsen Airekar on 07/03/23.
//

#if canImport(CometChatCallsSDK)
    import CometChatSDK
    import UIKit

    public enum CallWorkFlow {
        case defaultCalling
        case directCalling
    }

    open class CometChatOngoingCall: UIViewController {
        public lazy var containerView: UIView = {
            let containerView = UIView().withoutAutoresizingMaskConstraints()
            containerView.backgroundColor = CometChatTheme.backgroundColor03
            return containerView
        }()

        var viewModel: OngoingCallViewModel?
        var onCallEnded: ((_ call: Call) -> Void)?
        var sessionId: String?
        private var callSettingsBuilder: Any?
        private var callWorkFlow: CallWorkFlow?

        override open func viewDidLoad() {
            super.viewDidLoad()
            buildUI()
            startCall()
        }

        open func buildUI() {
            view.embed(containerView)
        }

        private func handleCall() {
            guard let viewModel else { return }
            viewModel.onCallEnded = {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
            viewModel.onError = { _ in
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }

        private func startCall() {
            guard let sessionId else { return }
            viewModel = OngoingCallViewModel(callView: containerView, sessionId: sessionId)
            if let callWorkFlow {
                viewModel?.set(callWorkFlow: callWorkFlow)
            }
            if let callSettingsBuilder = callSettingsBuilder as? CometChatCallsSDK.CallSettingsBuilder {
                viewModel?.set(callSettingsBuilder: callSettingsBuilder)
            } else {
                viewModel?.set(callSettingsBuilder: CallingDefaultBuilderSwiftUI.callSettingsBuilder as! CallSettingsBuilder)
            }
            handleCall()
            viewModel?.startCall()
        }
    }

    public extension CometChatOngoingCall {
        @discardableResult
        func set(sessionId: String) -> Self {
            self.sessionId = sessionId
            return self
        }

        @discardableResult
        func set(callSettingsBuilder: Any?) -> Self {
            self.callSettingsBuilder = callSettingsBuilder
            return self
        }

        @discardableResult
        func set(callWorkFlow: CallWorkFlow) -> Self {
            self.callWorkFlow = callWorkFlow
            return self
        }

        @discardableResult
        func setOnCallEnded(onCallEnded: @escaping ((_ call: Call) -> Void)) -> Self {
            self.onCallEnded = onCallEnded
            return self
        }
    }
#endif
