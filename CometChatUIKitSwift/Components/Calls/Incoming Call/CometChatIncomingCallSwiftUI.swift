//
//
//

#if canImport(CometChatCallsSDK)

    import CometChatSDK
    import CometChatUIKitSwift.Components.Shared.Constants
    import SwiftUI

    public struct CometChatIncomingCallSwiftUI: View {
        @StateObject private var viewModel = IncomingCallViewModelSwiftUI()
        @State private var controller: UIViewController?
        @State private var isPresented: Bool = true
        @State private var timer: Timer? = nil

        private var listItemView: ((Call) -> AnyView)?
        private var trailView: ((Call) -> AnyView)?
        private var titleView: ((Call) -> AnyView)?
        private var subtitleView: ((Call) -> AnyView)?
        private var leadingView: ((Call) -> AnyView)?
        private var onError: ((CometChatException) -> Void)?
        private var onCancelClick: ((Call?, UIViewController?) -> Void)?
        private var onAcceptClick: ((Call?, UIViewController?) -> Void)?
        private var callSettingsBuilder: CallSettingsBuilder?
        private var disableSoundForCalls: Bool = false
        private var customSoundForCalls: URL?

        public static var style = IncomingCallStyle()
        private var style = CometChatIncomingCallSwiftUI.style

        public static var avatarStyle = CometChatAvatar.style
        private var avatarStyle = CometChatIncomingCallSwiftUI.avatarStyle

        public init() {
            setupController()
        }

        public var body: some View {
            ZStack {
                Color(style.overlayBackgroundColor)
                    .edgesIgnoringSafeArea(.all)

                if let call = viewModel.call {
                    containerView(for: call)
                }
            }
            .onAppear {
                setupSound()
                viewModel.connect()

                timer = Timer.scheduledTimer(withTimeInterval: 45, repeats: false) { _ in
                    dismissView()
                }
            }
            .onDisappear {
                viewModel.disconnect()
                timer?.invalidate()
                timer = nil
                CometChatSoundManager().pause()
            }
            .onChange(of: viewModel.isCallAccepted) { isAccepted in
                if isAccepted {
                    handleCallAccepted()
                }
            }
            .onChange(of: viewModel.isCallRejected) { isRejected in
                if isRejected {
                    dismissView()
                }
            }
            .onChange(of: viewModel.isError) { isError in
                if isError {
                    if let onError {
                        let error = CometChatException(
                            message: viewModel.errorMessage,
                            code: "ERROR_IN_CALL"
                        )
                        onError(error)
                    }
                    dismissView()
                }
            }
        }

        private func containerView(for call: Call) -> some View {
            if let listItemView, let call = viewModel.call {
                return listItemView(call)
            } else {
                return AnyView(
                    VStack(spacing: 0) {
                        HStack(spacing: LayoutMetrics.spacingMedium) {
                            if let leadingView, let call = viewModel.call {
                                leadingView(call)
                            } else {
                                if let callByUser = (call.sender as? User) {
                                    CometChatAvatarSwiftUI(style: avatarStyle)
                                        .set(user: callByUser)
                                        .set(width: LayoutMetrics.avatarLarge)
                                        .set(height: LayoutMetrics.avatarLarge)
                                } else {
                                    CometChatAvatarSwiftUI(style: avatarStyle)
                                        .set(width: LayoutMetrics.avatarLarge)
                                        .set(height: LayoutMetrics.avatarLarge)
                                }
                            }

                            VStack(alignment: .leading, spacing: LayoutMetrics.spacingSmall) {
                                if let titleView, let call = viewModel.call {
                                    titleView(call)
                                } else {
                                    if let callByUser = (call.sender as? User) {
                                        Text(callByUser.name)
                                            .font(Font(style.nameLabelFont))
                                            .foregroundColor(Color(style.nameLabelColor))
                                    }
                                }

                                if let subtitleView, let call = viewModel.call {
                                    subtitleView(call)
                                } else {
                                    Text(call.callType == .audio ? "Voice Call" : "Video Call")
                                        .font(Font(style.callLabelFont))
                                        .foregroundColor(Color(style.callLabelColor))
                                }
                            }

                            Spacer()

                            if let trailView, let call = viewModel.call {
                                trailView(call)
                            } else {
                                HStack(spacing: LayoutMetrics.spacingMedium) {
                                    Button(action: {
                                        onRejectButtonTapped()
                                    }) {
                                        Image(systemName: "phone.down.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: LayoutMetrics.largeIconSize, height: LayoutMetrics.largeIconSize)
                                            .foregroundColor(Color(style.rejectButtonTintColor))
                                            .padding(LayoutMetrics.spacingMedium)
                                    }
                                    .frame(width: LayoutMetrics.avatarLarge, height: LayoutMetrics.avatarLarge)
                                    .background(Color(style.rejectButtonBackgroundColor))
                                    .cornerRadius(style.rejectButtonCornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusRound)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: style.rejectButtonCornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusRound)
                                            .stroke(Color(style.rejectButtonBorderColor), lineWidth: style.rejectButtonBorderWidth)
                                    )

                                    Button(action: {
                                        onAcceptButtonTapped()
                                    }) {
                                        Image(systemName: "phone.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: LayoutMetrics.largeIconSize, height: LayoutMetrics.largeIconSize)
                                            .foregroundColor(Color(style.acceptButtonTintColor))
                                            .padding(LayoutMetrics.spacingMedium)
                                    }
                                    .frame(width: LayoutMetrics.avatarLarge, height: LayoutMetrics.avatarLarge)
                                    .background(Color(style.acceptButtonBackgroundColor))
                                    .cornerRadius(style.acceptButtonCornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusRound)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: style.acceptButtonCornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusRound)
                                            .stroke(Color(style.acceptButtonBorderColor), lineWidth: style.acceptButtonBorderWidth)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, LayoutMetrics.spacingLarge)
                        .padding(.vertical, LayoutMetrics.spacingExtraLarge - LayoutMetrics.spacingSmall)
                    }
                    .background(Color(style.backgroundColor))
                    .cornerRadius(style.cornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusLarge * 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusLarge * 3)
                            .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
                    )
                    .padding(.horizontal, LayoutMetrics.spacingStandard)
                    .padding(.top, LayoutMetrics.spacingStandard)
                )
            }
        }

        private func setupController() {
            let rootViewController = UIApplication.shared.windows.first?.rootViewController
            controller = rootViewController
        }

        private func setupSound() {
            if !disableSoundForCalls {
                CometChatSoundManager().play(sound: .incomingCall, customSound: customSoundForCalls)
            }
        }

        private func dismissView() {
            CometChatSoundManager().pause()
            isPresented = false

            if let controller = controller as? UIHostingController<CometChatIncomingCallSwiftUI> {
                DispatchQueue.main.async {
                    controller.dismiss(animated: true)
                }
            }
        }

        private func handleCallAccepted() {
            guard let call = viewModel.call else { return }

            if let onAcceptClick {
                dismissView()
                onAcceptClick(call, controller)
            } else {
                CometChatSoundManager().pause()

                let ongoingCall = CometChatOngoingCall()
                ongoingCall.modalPresentationStyle = .fullScreen
                ongoingCall.set(sessionId: call.sessionID ?? "")

                let callSettingsBuilder = callSettingsBuilder ?? CometChatCallsSDK.CallSettingsBuilder()
                    .setIsAudioOnly(call.callType == .audio)
                    .setDefaultAudioMode(call.callType == .audio ? "EARPIECE" : "SPEAKER")

                ongoingCall.set(callSettingsBuilder: callSettingsBuilder)
                ongoingCall.set(callWorkFlow: .defaultCalling)

                if let controller {
                    DispatchQueue.main.async {
                        controller.dismiss(animated: false) {
                            controller.present(ongoingCall, animated: false)
                        }
                    }
                }
            }
        }

        private func onAcceptButtonTapped() {
            if let call = viewModel.call {
                if let onAcceptClick {
                    dismissView()
                    onAcceptClick(call, controller)
                } else {
                    viewModel.acceptCall(call: call)
                }
            }
        }

        private func onRejectButtonTapped() {
            if let call = viewModel.call {
                if let onCancelClick {
                    onCancelClick(call, controller)
                } else {
                    viewModel.rejectCall(call: call)
                }
            }
        }

        @discardableResult
        public func set(call: Call?) -> Self {
            var view = self
            view.viewModel.set(call: call)
            return view
        }

        @discardableResult
        public func set(listItemView: @escaping ((Call) -> AnyView)) -> Self {
            var view = self
            view.listItemView = listItemView
            return view
        }

        @discardableResult
        public func set(trailView: @escaping ((Call) -> AnyView)) -> Self {
            var view = self
            view.trailView = trailView
            return view
        }

        @discardableResult
        public func set(titleView: @escaping ((Call) -> AnyView)) -> Self {
            var view = self
            view.titleView = titleView
            return view
        }

        @discardableResult
        public func set(subtitleView: @escaping ((Call) -> AnyView)) -> Self {
            var view = self
            view.subtitleView = subtitleView
            return view
        }

        @discardableResult
        public func set(leadingView: @escaping ((Call) -> AnyView)) -> Self {
            var view = self
            view.leadingView = leadingView
            return view
        }

        @discardableResult
        public func set(onError: @escaping ((CometChatException) -> Void)) -> Self {
            var view = self
            view.onError = onError
            return view
        }

        @discardableResult
        public func set(onCancelClick: @escaping ((Call?, UIViewController?) -> Void)) -> Self {
            var view = self
            view.onCancelClick = onCancelClick
            return view
        }

        @discardableResult
        public func set(onAcceptClick: @escaping ((Call?, UIViewController?) -> Void)) -> Self {
            var view = self
            view.onAcceptClick = onAcceptClick
            return view
        }

        @discardableResult
        public func set(callSettingsBuilder: CallSettingsBuilder?) -> Self {
            var view = self
            view.callSettingsBuilder = callSettingsBuilder
            return view
        }

        @discardableResult
        public func disable(soundForCalls: Bool) -> Self {
            var view = self
            view.disableSoundForCalls = soundForCalls
            return view
        }

        @discardableResult
        public func set(customSoundForCalls: URL?) -> Self {
            var view = self
            view.customSoundForCalls = customSoundForCalls
            return view
        }

        @discardableResult
        public func set(style: IncomingCallStyle) -> Self {
            var view = self
            view.style = style
            return view
        }

        @discardableResult
        public func set(avatarStyle: AvatarStyle) -> Self {
            var view = self
            view.avatarStyle = avatarStyle
            return view
        }
    }

    public extension CometChatIncomingCallSwiftUI {
        func toUIKit() -> UIViewController {
            let hostingController = UIHostingController(rootView: self)
            return hostingController
        }

        static func present(on viewController: UIViewController, call: Call) {
            let incomingCallView = CometChatIncomingCallSwiftUI()
                .set(call: call)

            let hostingController = UIHostingController(rootView: incomingCallView)
            hostingController.modalPresentationStyle = .fullScreen

            viewController.present(hostingController, animated: true)
        }
    }

    struct CometChatIncomingCallSwiftUI_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                CometChatIncomingCallSwiftUI()
                    .set(call: createMockCall(type: .audio))
                    .previewDisplayName("Audio Call (Light)")

                CometChatIncomingCallSwiftUI()
                    .set(call: createMockCall(type: .audio))
                    .preferredColorScheme(.dark)
                    .previewDisplayName("Audio Call (Dark)")

                CometChatIncomingCallSwiftUI()
                    .set(call: createMockCall(type: .video))
                    .previewDisplayName("Video Call (Light)")

                CometChatIncomingCallSwiftUI()
                    .set(call: createMockCall(type: .video))
                    .preferredColorScheme(.dark)
                    .previewDisplayName("Video Call (Dark)")
            }
        }

        static func createMockCall(type: CometChatSDK.CallType) -> Call {
            let call = Call(receiverId: "user123", callType: type, receiverType: .user)
            let user = User(uid: "user123", name: "John Doe")
            call.sender = user
            return call
        }
    }

#endif
