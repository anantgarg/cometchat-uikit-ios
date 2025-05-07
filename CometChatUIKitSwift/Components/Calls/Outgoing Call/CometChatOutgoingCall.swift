//
//  CometChatOutgoingCall.swift
//
//
//  Created by Pushpsen Airekar on 08/03/23.
//

import CometChatSDK
import UIKit

#if canImport(CometChatCallsSDK)

    @MainActor
    open class CometChatOutgoingCall: UIViewController {
        public lazy var avatarTopView: UIView = {
            let avatarView = UIView().withoutAutoresizingMaskConstraints()
            avatarView.pin(anchors: [.height, .width], to: 150)
            avatarView.backgroundColor = .clear
            return avatarView
        }()

        public lazy var avatar: CometChatAvatar = {
            let avatarView = CometChatAvatar(frame: .zero).withoutAutoresizingMaskConstraints()
            avatarView.pin(anchors: [.height, .width], to: 120)
            avatarView.setAvatar(avatarUrl: (call?.receiver as? User)?.avatar, with: (call?.receiver as? User)?.name)
            return avatarView
        }()

        public lazy var titleContainerView: UIView = {
            let view = UIView().withoutAutoresizingMaskConstraints()
            view.backgroundColor = .clear
            return view
        }()

        public lazy var subtitleContainerView: UIView = {
            let view = UIView().withoutAutoresizingMaskConstraints()
            view.backgroundColor = .clear
            return view
        }()

        public lazy var nameLabel: UILabel = {
            let nameLabel = UILabel().withoutAutoresizingMaskConstraints()
            nameLabel.textAlignment = .center
            nameLabel.text = user?.name ?? ""
            nameLabel.text = (call?.receiver as? User)?.name ?? ""
            return nameLabel
        }()

        public lazy var callingLabel: UILabel = {
            let callingLabel = UILabel().withoutAutoresizingMaskConstraints()
            callingLabel.textAlignment = .center
            callingLabel.text = "CALLING".localize()
            return callingLabel
        }()

        public lazy var declineButtonView: UIView = {
            let view = UIButton().withoutAutoresizingMaskConstraints()
            view.pin(anchors: [.height, .width], to: 100)
            view.backgroundColor = .clear
            return view
        }()

        public lazy var declineButton: UIButton = {
            let declineButton = UIButton().withoutAutoresizingMaskConstraints()
            declineButton.pin(anchors: [.height, .width], to: 54)
            declineButton.roundViewCorners(corner: .init(cornerRadius: 27))
            declineButton.addTarget(self, action: #selector(onDeclineButtonTapped), for: .primaryActionTriggered)
            return declineButton
        }()

        public lazy var containerView: UIView = {
            let containerView = UIView().withoutAutoresizingMaskConstraints()
            return containerView
        }()

        public static var style = OutgoingCallStyle()
        public static var avatarStyle = CometChatAvatar.style
        public var avatarStyle = CometChatOutgoingCall.avatarStyle
        public var style = CometChatOutgoingCall.style
        var onError: ((_ error: CometChatException) -> Void)?
        var titleView: ((_ call: Call) -> UIView)?
        var subtitleView: ((_ call: Call) -> UIView)?
        var cancelView: ((_ call: Call) -> UIView)?
        var avatarView: ((_ call: Call) -> UIView)?

        public var call: Call?
        public var user: User?
        public var declineButtonText: String = "CANCEL".localize()
        public var declineButtonIcon: UIImage = .init(systemName: "xmark") ?? UIImage()
        public var disableSoundForCalls: Bool = false
        public var customSoundForCalls: URL?
        public var fullscreenView: UIView?
        public var buttonStyle = ButtonStyle()
        public var outgoingCallStyle = OutgoingCallStyle()
        var onCancelClick: ((_ call: Call?, _ controller: UIViewController?) -> Void)?
        var viewModel = OutgoingCallViewModel()
        var callSettingsBuilder: CallSettingsBuilder?

        override open func viewDidLoad() {
            super.viewDidLoad()

            if !disableSoundForCalls {
                CometChatSoundManager().play(sound: .outgoingCall, customSound: customSoundForCalls)
            }

            let callSettingsBuilder = callSettingsBuilder ?? CometChatCallsSDK.CallSettingsBuilder()
                .setDefaultAudioMode(call?.callType == .audio ? "EARPIECE" : "SPEAKER")
                .setIsAudioOnly(call?.callType == .audio)

            viewModel.onOutgoingCallAccepted = { call in
                DispatchQueue.main.async {
                    CometChatSoundManager().pause()
                    weak var pvc = self.presentingViewController
                    self.dismiss(animated: false, completion: {
                        if let controller = pvc {
                            CometChatOngoingCallSwiftUI.present(
                                on: controller,
                                sessionId: call.sessionID ?? "",
                                callSettingsBuilder: callSettingsBuilder,
                                callWorkFlow: .defaultCalling
                            )
                        }
                    })
                }
            }

            viewModel.onError = { _ in
                DispatchQueue.main.async {
                    CometChatSoundManager().pause()
                    self.dismiss(animated: true)
                }
            }

            viewModel.onOutgoingCallRejected = { _ in
                DispatchQueue.main.async {
                    CometChatSoundManager().pause()
                    self.dismiss(animated: true)
                }
            }

            buildUI()
            setupStyle()
            addCustomViews()
        }

        override open func viewWillAppear(_: Bool) {
            viewModel.connect()
        }

        override open func viewWillDisappear(_: Bool) {
            viewModel.disconnect()
        }

        open func buildUI() {
            var constraintsToActive = [NSLayoutConstraint]()

            view.addSubview(titleContainerView)

            titleContainerView.embed(nameLabel)
            constraintsToActive += [
                titleContainerView.centerXAnchor.pin(equalTo: view.centerXAnchor),
                titleContainerView.topAnchor.pin(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            ]

            view.addSubview(subtitleContainerView)
            subtitleContainerView.embed(callingLabel)

            constraintsToActive += [
                subtitleContainerView.centerXAnchor.pin(equalTo: titleContainerView.centerXAnchor),
                subtitleContainerView.topAnchor.pin(equalTo: titleContainerView.bottomAnchor, constant: 5),
            ]

            view.addSubview(avatarTopView)
            constraintsToActive += [
                avatarTopView.topAnchor.pin(equalTo: subtitleContainerView.bottomAnchor, constant: CometChatSpacing.Margin.m10),
                avatarTopView.centerXAnchor.pin(equalTo: titleContainerView.centerXAnchor),
            ]

            avatarTopView.addSubview(avatar)
            avatar.pin(anchors: [.centerX, .centerY], to: avatarTopView)

            view.addSubview(declineButtonView)
            constraintsToActive += [
                declineButtonView.centerXAnchor.pin(equalTo: view.centerXAnchor),
                declineButtonView.bottomAnchor.pin(equalTo: view.bottomAnchor, constant: -80),
            ]

            declineButtonView.addSubview(declineButton)
            declineButton.pin(anchors: [.centerX, .centerY], to: declineButtonView)

            NSLayoutConstraint.activate(constraintsToActive)
        }

        func addCustomViews() {
            if let call, let titleView = titleView?(call) {
                titleContainerView.subviews.forEach { $0.removeFromSuperview() }
                titleContainerView.embed(titleView)
            }

            if let call, let subtitleView = subtitleView?(call) {
                subtitleContainerView.subviews.forEach { $0.removeFromSuperview() }
                subtitleContainerView.embed(subtitleView)
            }

            if let call, let avatarView = avatarView?(call) {
                avatarTopView.subviews.forEach { $0.removeFromSuperview() }
                avatarTopView.embed(avatarView)
            }

            if let call, let cancelView = cancelView?(call) {
                declineButtonView.subviews.forEach { $0.removeFromSuperview() }
                declineButtonView.embed(cancelView)
            }
        }

        open func setupStyle() {
            view.backgroundColor = style.backgroundColor
            view.roundViewCorners(corner: style.cornerRadius)
            view.borderWith(width: style.borderWidth)
            view.borderColor(color: style.borderColor)
            nameLabel.textColor = style.nameTextColor
            nameLabel.font = style.nameTextFont
            callingLabel.textColor = style.callTextColor
            callingLabel.font = style.callTextFont
            declineButton.setImage(style.declineButtonIcon, for: .normal)
            declineButton.backgroundColor = style.declineButtonBackgroundColor
            declineButton.tintColor = style.declineButtonIconTint
            if let radius = style.declineButtonCornerRadius {
                declineButton.roundViewCorners(corner: radius)
            }
            declineButton.borderWith(width: style.declineButtonBorderWidth)
            declineButton.borderColor(color: style.declineButtonBorderColor)
            avatar.style = avatarStyle
        }

        @objc open func onDeclineButtonTapped() {
            dismiss(animated: true)
            if !disableSoundForCalls {
                CometChatSoundManager().pause()
            }
            if let sessionID = call?.sessionID {
                CometChat.rejectCall(sessionID: sessionID, status: .cancelled) { call in
                    if let call {
                        CometChatCallEvents.ccCallRejected(call: call)
                    }
                    print("Call Cancelled Success")
                } onError: { error in
                    print("Call Cancelled Error: \(String(describing: error?.errorDescription))")
                }
            }
        }
    }
#endif
