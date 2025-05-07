//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatCallBubbleSwiftUI: View {
    @StateObject private var viewModel = CallBubbleViewModelSwiftUI()
    
    private var onClick: ((CometChatSDK.CallType) -> Void)?
    
    public static var style = CallBubbleStyle()
    private var style = CometChatCallBubbleSwiftUI.style
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: CometChatSpacing.Padding.p2) {
            HStack(spacing: CometChatSpacing.Padding.p2) {
                ZStack {
                    Circle()
                        .fill(Color(style.callImageBackgroundColor))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color(style.callImageBorderColor), lineWidth: style.callImageBorderWidth)
                        )
                    
                    Image(uiImage: viewModel.callType == .audio ? style.audioCallImage : style.videoCallImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(style.callImageTintColor))
                }
                
                VStack(alignment: .leading, spacing: CometChatSpacing.Padding.p1) {
                    Text(viewModel.callType == .audio ? viewModel.audioCallTitleText : viewModel.videoCallTitleText)
                        .font(Font(style.titleTextFont))
                        .foregroundColor(Color(style.titleTextColor))
                    
                    Text(viewModel.dateText)
                        .font(Font(style.subtitleTextFont))
                        .foregroundColor(Color(style.subtitleTextColor))
                }
                
                Spacer()
            }
            .padding(.horizontal, CometChatSpacing.Padding.p2)
            .padding(.top, CometChatSpacing.Padding.p3)
            
            Rectangle()
                .fill(Color(style.separatorBackgroundColor))
                .frame(height: 1)
                .padding(.horizontal, CometChatSpacing.Padding.p1)
            
            Button(action: {
                onClick?(viewModel.callType)
            }) {
                Text("JOIN".localize())
                    .font(Font(style.joinButtonTextFont))
                    .foregroundColor(Color(style.joinButtonTextColor))
            }
            .padding(.bottom, CometChatSpacing.Padding.p2)
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

extension CometChatCallBubbleSwiftUI {
    public func toUIKit() -> UIView {
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
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Audio Call")
            
            CometChatCallBubbleSwiftUI()
                .set(callType: .video)
                .set(dateText: "Yesterday")
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Video Call")
            
            CometChatCallBubbleSwiftUI()
                .set(callType: .video)
                .set(dateText: "Yesterday")
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Dark Mode")
        }
    }
}
