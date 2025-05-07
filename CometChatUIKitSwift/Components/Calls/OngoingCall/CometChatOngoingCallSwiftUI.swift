//
//
//

#if canImport(CometChatCallsSDK)

    import CometChatSDK
    import SwiftUI

    public struct CometChatOngoingCallSwiftUI: View {
        @StateObject private var viewModel = OngoingCallViewModelSwiftUI()
        @State private var containerView = UIView()

        private var sessionId: String?
        private var callSettingsBuilder: CallSettingsBuilder?
        private var callWorkFlow: CallWorkFlow = .defaultCalling
        private var onCallEnded: ((Call) -> Void)?

        public init() {}

        public var body: some View {
            ZStack {
                Color(CometChatTheme.backgroundColor03)
                    .edgesIgnoringSafeArea(.all)

                UIViewRepresentable(containerView: $containerView)
                    .onAppear {
                        setupCall()
                    }
            }
            .onChange(of: viewModel.isCallEnded) { isEnded in
                if isEnded {}
            }
            .onChange(of: viewModel.isError) { isError in
                if isError {}
            }
        }

        private func setupCall() {
            viewModel.set(callView: containerView)

            if let sessionId {
                viewModel.set(sessionId: sessionId)
            }

            if let callSettingsBuilder {
                viewModel.set(callSettingsBuilder: callSettingsBuilder)
            } else {
                viewModel.set(callSettingsBuilder: CallingDefaultBuilder.callSettingsBuilder as! CallSettingsBuilder)
            }

            viewModel.set(callWorkFlow: callWorkFlow)
            viewModel.startCall()
        }

        @discardableResult
        public func set(sessionId: String) -> Self {
            var view = self
            view.sessionId = sessionId
            return view
        }

        @discardableResult
        public func set(callSettingsBuilder: CallSettingsBuilder?) -> Self {
            var view = self
            view.callSettingsBuilder = callSettingsBuilder
            return view
        }

        @discardableResult
        public func set(callWorkFlow: CallWorkFlow) -> Self {
            var view = self
            view.callWorkFlow = callWorkFlow
            return view
        }

        @discardableResult
        public func setOnCallEnded(onCallEnded: @escaping ((Call) -> Void)) -> Self {
            var view = self
            view.onCallEnded = onCallEnded
            return view
        }
    }

    struct UIViewRepresentable: View {
        @Binding var containerView: UIView

        var body: some View {
            UIViewWrapper(containerView: $containerView)
        }

        struct UIViewWrapper: UIViewRepresentable {
            @Binding var containerView: UIView

            func makeUIView(context _: Context) -> UIView {
                containerView
            }

            func updateUIView(_: UIView, context _: Context) {}
        }
    }

    public extension CometChatOngoingCallSwiftUI {
        func toUIKit() -> UIViewController {
            let hostingController = UIHostingController(rootView: self)
            return hostingController
        }

        static func present(on viewController: UIViewController, sessionId: String, callSettingsBuilder: CallSettingsBuilder? = nil, callWorkFlow: CallWorkFlow = .defaultCalling) {
            let ongoingCallView = CometChatOngoingCallSwiftUI()
                .set(sessionId: sessionId)
                .set(callWorkFlow: callWorkFlow)

            if let callSettingsBuilder {
                ongoingCallView.set(callSettingsBuilder: callSettingsBuilder)
            }

            let hostingController = UIHostingController(rootView: ongoingCallView)
            hostingController.modalPresentationStyle = .fullScreen

            viewController.present(hostingController, animated: true)
        }
    }

    struct CometChatOngoingCallSwiftUI_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                CometChatOngoingCallSwiftUI()
                    .set(sessionId: "mock-session-id")
                    .previewDisplayName("Ongoing Call (Light)")

                CometChatOngoingCallSwiftUI()
                    .set(sessionId: "mock-session-id")
                    .preferredColorScheme(.dark)
                    .previewDisplayName("Ongoing Call (Dark)")
            }
        }
    }

#endif
