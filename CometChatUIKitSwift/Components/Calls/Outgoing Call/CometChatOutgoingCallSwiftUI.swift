//
//
//

#if canImport(CometChatCallsSDK)

    import CometChatSDK
    import CometChatUIKitSwift.Components.Shared.Constants
    import SwiftUI

    public struct CometChatOutgoingCallSwiftUI: View {
        @StateObject private var viewModel = OutgoingCallViewModelSwiftUI()
        @State private var controller: UIViewController?
        @State private var isPresented: Bool = true

        private var titleView: ((Call) -> AnyView)?
        private var subtitleView: ((Call) -> AnyView)?
        private var cancelView: ((Call) -> AnyView)?
        private var avatarView: ((Call) -> AnyView)?
        private var onError: ((CometChatException) -> Void)?
        private var onCancelClick: ((Call?, UIViewController?) -> Void)?
        private var callSettingsBuilder: CallSettingsBuilder?
        private var disableSoundForCalls: Bool = false
        private var customSoundForCalls: URL?

        public static var style = OutgoingCallStyle()
        private var style = CometChatOutgoingCallSwiftUI.style

        public static var avatarStyle = CometChatAvatar.style
        private var avatarStyle = CometChatOutgoingCallSwiftUI.avatarStyle

        public init() {
            setupController()
        }

        public var body: some View {
            ZStack {
                Color(style.backgroundColor)
                    .edgesIgnoringSafeArea(.all)

                if let call = viewModel.call {
                    VStack(spacing: LayoutMetrics.spacingLarge) {
                        if let titleView, let call = viewModel.call {
                            titleView(call)
                        } else {
                            if let callReceiver = (call.receiver as? User) {
                                Text(callReceiver.name)
                                    .font(Font(style.nameTextFont))
                                    .foregroundColor(Color(style.nameTextColor))
                            }
                        }

                        if let subtitleView, let call = viewModel.call {
                            subtitleView(call)
                        } else {
                            Text("CALLING".localize())
                                .font(Font(style.callTextFont))
                                .foregroundColor(Color(style.callTextColor))
                        }

                        if let avatarView, let call = viewModel.call {
                            avatarView(call)
                                .frame(width: LayoutMetrics.avatarLarge * 3, height: LayoutMetrics.avatarLarge * 3)
                        } else {
                            ZStack {
                                if let callReceiver = (call.receiver as? User) {
                                    CometChatAvatarSwiftUI(style: avatarStyle)
                                        .set(user: callReceiver)
                                        .set(width: LayoutMetrics.avatarLarge * 2.5)
                                        .set(height: LayoutMetrics.avatarLarge * 2.5)
                                } else {
                                    CometChatAvatarSwiftUI(style: avatarStyle)
                                        .set(width: LayoutMetrics.avatarLarge * 2.5)
                                        .set(height: LayoutMetrics.avatarLarge * 2.5)
                                }
                            }
                            .frame(width: LayoutMetrics.avatarLarge * 3, height: LayoutMetrics.avatarLarge * 3)
                        }

                        Spacer()

                        if let cancelView, let call = viewModel.call {
                            cancelView(call)
                                .frame(width: LayoutMetrics.avatarLarge * 2, height: LayoutMetrics.avatarLarge * 2)
                        } else {
                            Button(action: {
                                onDeclineButtonTapped()
                            }) {
                                Image(systemName: "phone.down.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: LayoutMetrics.largeIconSize, height: LayoutMetrics.largeIconSize)
                                    .foregroundColor(Color(style.declineButtonIconTint))
                                    .padding(LayoutMetrics.spacingMedium)
                            }
                            .frame(width: LayoutMetrics.avatarLarge + 6, height: LayoutMetrics.avatarLarge + 6)
                            .background(Color(style.declineButtonBackgroundColor))
                            .cornerRadius(style.declineButtonCornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusRound)
                            .overlay(
                                RoundedRectangle(cornerRadius: style.declineButtonCornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusRound)
                                    .stroke(Color(style.declineButtonBorderColor), lineWidth: style.declineButtonBorderWidth)
                            )
                            .padding(.bottom, LayoutMetrics.spacingExtraLarge * 5)
                        }
                    }
                    .padding(.top, LayoutMetrics.spacingExtraLarge * 5)
                }
            }
            .onAppear {
                setupSound()
                viewModel.connect()

                if let call = viewModel.call {
                    setupOngoingCall(for: call)
                }
            }
            .onDisappear {
                viewModel.disconnect()
                CometChatSoundManager().pause()
            }
            .onChange(of: viewModel.isCallAccepted) { isAccepted in
                if isAccepted {
                    dismissView()
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

        private func setupController() {
            let rootViewController = UIApplication.shared.windows.first?.rootViewController
            controller = rootViewController
        }

        private func setupSound() {
            if !disableSoundForCalls {
                CometChatSoundManager().play(sound: .outgoingCall, customSound: customSoundForCalls)
            }
        }

        private func setupOngoingCall(for call: Call) {
            let ongoingCall = CometChatOngoingCall()
            let callSettingsBuilder = callSettingsBuilder ?? CometChatCallsSDK.CallSettingsBuilder()
                .setDefaultAudioMode(call.callType == .audio ? "EARPIECE" : "SPEAKER")
                .setIsAudioOnly(call.callType == .audio)

            ongoingCall.set(callSettingsBuilder: callSettingsBuilder)
            ongoingCall.modalPresentationStyle = .fullScreen

            viewModel.onOutgoingCallAccepted = { call in
                DispatchQueue.main.async {
                    ongoingCall.set(sessionId: call.sessionID ?? "")
                    ongoingCall.set(callWorkFlow: .defaultCalling)
                    CometChatSoundManager().pause()

                    if let controller {
                        controller.dismiss(animated: false) {
                            controller.present(ongoingCall, animated: false)
                        }
                    }
                }
            }
        }

        private func dismissView() {
            CometChatSoundManager().pause()
            isPresented = false

            if let controller = controller as? UIHostingController<CometChatOutgoingCallSwiftUI> {
                DispatchQueue.main.async {
                    controller.dismiss(animated: true)
                }
            }
        }

        private func onDeclineButtonTapped() {
            if let call = viewModel.call {
                if let onCancelClick {
                    onCancelClick(call, controller)
                } else {
                    CometChatSoundManager().pause()
                    viewModel.cancelCall(call: call)
                    dismissView()
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
        public func set(cancelView: @escaping ((Call) -> AnyView)) -> Self {
            var view = self
            view.cancelView = cancelView
            return view
        }

        @discardableResult
        public func set(avatarView: @escaping ((Call) -> AnyView)) -> Self {
            var view = self
            view.avatarView = avatarView
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
        public func set(style: OutgoingCallStyle) -> Self {
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

    public extension CometChatOutgoingCallSwiftUI {
        func toUIKit() -> UIViewController {
            let hostingController = UIHostingController(rootView: self)
            return hostingController
        }

        static func present(on viewController: UIViewController, call: Call) {
            let outgoingCallView = CometChatOutgoingCallSwiftUI()
                .set(call: call)

            let hostingController = UIHostingController(rootView: outgoingCallView)
            hostingController.modalPresentationStyle = .fullScreen

            viewController.present(hostingController, animated: true)
        }
    }

    struct CometChatOutgoingCallSwiftUI_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                CometChatOutgoingCallSwiftUI()
                    .set(call: createMockCall(type: .audio))
                    .previewDisplayName("Audio Call (Light)")

                CometChatOutgoingCallSwiftUI()
                    .set(call: createMockCall(type: .audio))
                    .preferredColorScheme(.dark)
                    .previewDisplayName("Audio Call (Dark)")

                CometChatOutgoingCallSwiftUI()
                    .set(call: createMockCall(type: .video))
                    .previewDisplayName("Video Call (Light)")

                CometChatOutgoingCallSwiftUI()
                    .set(call: createMockCall(type: .video))
                    .preferredColorScheme(.dark)
                    .previewDisplayName("Video Call (Dark)")
            }
        }

        static func createMockCall(type: CometChatSDK.CallType) -> Call {
            let call = Call(receiverId: "user123", callType: type, receiverType: .user)
            let user = User(uid: "user123", name: "John Doe")
            call.receiver = user
            return call
        }
    }

#endif
