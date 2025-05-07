//
//
//

import CometChatSDK
import CometChatUIKitSwift.Components.Shared.Constants
import SwiftUI

public struct CometChatCallBubbleSwiftUI: View {
    @StateObject private var viewModel = CallBubbleViewModelSwiftUI()

    private var onClick: ((CometChatSDK.CallType) -> Void)?

    public static var style = CallBubbleStyle()
    private var style = CometChatCallBubbleSwiftUI.style

    public init() {}

    public var body: some View {
        VStack(spacing: LayoutMetrics.spacingStandard) {
            HStack(spacing: LayoutMetrics.spacingStandard) {
                ZStack {
                    Circle()
                        .fill(Color(style.callImageBackgroundColor))
                        .frame(width: LayoutMetrics.avatarMedium, height: LayoutMetrics.avatarMedium)
                        .overlay(
                            Circle()
                                .stroke(Color(style.callImageBorderColor), lineWidth: style.callImageBorderWidth)
                        )

                    Image(systemName: viewModel.callType == .audio ? "phone.fill" : "video.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: LayoutMetrics.mediumIconSize, height: LayoutMetrics.mediumIconSize)
                        .foregroundColor(Color(style.callImageTintColor))
                }

                VStack(alignment: .leading, spacing: LayoutMetrics.spacingSmall) {
                    Text(viewModel.callType == .audio ? viewModel.audioCallTitleText : viewModel.videoCallTitleText)
                        .font(Font(style.titleTextFont))
                        .foregroundColor(Color(style.titleTextColor))

                    Text(viewModel.dateText)
                        .font(Font(style.subtitleTextFont))
                        .foregroundColor(Color(style.subtitleTextColor))
                }

                Spacer()
            }
            .padding(.horizontal, LayoutMetrics.spacingStandard)
            .padding(.top, LayoutMetrics.spacingMedium)

            Rectangle()
                .fill(Color(style.separatorBackgroundColor))
                .frame(height: LayoutMetrics.dividerHeight)
                .padding(.horizontal, LayoutMetrics.spacingSmall)

            Button(action: {
                onClick?(viewModel.callType)
            }) {
                Text("JOIN".localize())
                    .font(Font(style.joinButtonTextFont))
                    .foregroundColor(Color(style.joinButtonTextColor))
            }
            .padding(.bottom, LayoutMetrics.spacingStandard)
        }
    }

    @discardableResult
    public func set(callType: CometChatSDK.CallType) -> Self {
        var view = self
        view.viewModel.set(callType: callType)
        return view
    }

    @discardableResult
    public func set(audioCallTitleText: String) -> Self {
        var view = self
        view.viewModel.set(audioCallTitleText: audioCallTitleText)
        return view
    }

    @discardableResult
    public func set(videoCallTitleText: String) -> Self {
        var view = self
        view.viewModel.set(videoCallTitleText: videoCallTitleText)
        return view
    }

    @discardableResult
    public func set(dateText: String) -> Self {
        var view = self
        view.viewModel.set(dateText: dateText)
        return view
    }

    @discardableResult
    public func setOnClick(onClick: @escaping ((CometChatSDK.CallType) -> Void)) -> Self {
        var view = self
        view.onClick = onClick
        return view
    }

    @discardableResult
    public func set(style: CallBubbleStyle) -> Self {
        var view = self
        view.style = style
        return view
    }
}

public extension CometChatCallBubbleSwiftUI {
    func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatCallBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatCallBubbleSwiftUI()
                .set(callType: .audio)
                .set(dateText: "10:30 AM")
                .padding()
                .previewDisplayName("Audio Call (Light)")

            CometChatCallBubbleSwiftUI()
                .set(callType: .audio)
                .set(dateText: "10:30 AM")
                .preferredColorScheme(.dark)
                .padding()
                .previewDisplayName("Audio Call (Dark)")

            CometChatCallBubbleSwiftUI()
                .set(callType: .video)
                .set(dateText: "Yesterday")
                .padding()
                .previewDisplayName("Video Call (Light)")

            CometChatCallBubbleSwiftUI()
                .set(callType: .video)
                .set(dateText: "Yesterday")
                .preferredColorScheme(.dark)
                .padding()
                .previewDisplayName("Video Call (Dark)")
        }
    }
}
