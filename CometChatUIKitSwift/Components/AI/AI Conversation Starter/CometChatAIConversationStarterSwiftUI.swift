//
//
//

import SwiftUI
import CometChatSDK
import CometChatUIKitSwift.Components.Shared.Constants

public struct CometChatAIConversationStarterSwiftUI: View {
    @StateObject private var viewModel = AIConversationStarterViewModelSwiftUI()
    
    private var onAiMessageClicked: ((String) -> Void)?
    private var id: [String: Any]?
    private var disableLoadingState: Bool = false
    
    public static var style = AIConversationStarterStyle()
    private var style = CometChatAIConversationStarterSwiftUI.style
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            if viewModel.showError {
                errorView
            } else if viewModel.isLoading {
                loadingView
            } else {
                messageListView
            }
        }
        .background(Color.clear)
        .padding(.vertical, LayoutMetrics.spacingStandard)
    }
    
    private var errorView: some View {
        VStack {
            Text("SOMETHING_WENT_WRONG_WITH_NEW_LINE".localize())
                .font(Font(style.errorViewTextFont))
                .foregroundColor(Color(style.errorViewTextColor))
                .multilineTextAlignment(.center)
                .padding(.horizontal, LayoutMetrics.spacingExtraLarge)
                .padding(.vertical, LayoutMetrics.spacingStandard)
                .frame(height: LayoutMetrics.avatarLarge * 2.5)
        }
    }
    
    private var loadingView: some View {
        CometChatAIConversationStarterShimmerSwiftUI()
            .frame(height: LayoutMetrics.avatarLarge * 2.5)
            .cornerRadius(LayoutMetrics.cornerRadiusLarge)
    }
    
    private var messageListView: some View {
        VStack(spacing: LayoutMetrics.spacingStandard) {
            ForEach(viewModel.aiMessagesList, id: \.self) { message in
                AIConversationStarterCellSwiftUI(
                    message: message,
                    style: style,
                    onTap: { selectedMessage in
                        onAiMessageClicked?(selectedMessage)
                    }
                )
            }
        }
    }
    
    @discardableResult
    public func set(aiMessageOptions: [String]) -> Self {
        var view = self
        view.viewModel.set(aiMessageOptions: aiMessageOptions)
        return view
    }
    
    @discardableResult
    public func onMessageClicked(onAiMessageClicked: @escaping ((String) -> Void)) -> Self {
        var view = self
        view.onAiMessageClicked = onAiMessageClicked
        return view
    }
    
    @discardableResult
    public func show(error: Bool) -> Self {
        var view = self
        view.viewModel.show(error: error)
        return view
    }
    
    @discardableResult
    public func showLoadingView() -> Self {
        var view = self
        if !disableLoadingState {
            view.viewModel.showLoadingView()
        }
        return view
    }
    
    @discardableResult
    public func hideLoadingView() -> Self {
        var view = self
        view.viewModel.hideLoadingView()
        return view
    }
    
    @discardableResult
    public func set(disableLoadingState: Bool) -> Self {
        var view = self
        view.disableLoadingState = disableLoadingState
        return view
    }
    
    @discardableResult
    public func set(style: AIConversationStarterStyle) -> Self {
        var view = self
        view.style = style
        return view
    }
}

struct AIConversationStarterCellSwiftUI: View {
    let message: String
    let style: AIConversationStarterStyle
    let onTap: (String) -> Void
    
    var body: some View {
        Button(action: {
            onTap(message)
        }) {
            HStack {
                Text(message)
                    .font(Font(style.textFont))
                    .foregroundColor(Color(style.textColor))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, LayoutMetrics.spacingLarge)
                    .padding(.vertical, LayoutMetrics.spacingStandard)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(style.backgroundColor))
                    .cornerRadius(style.cornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusMedium)
                    .overlay(
                        RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusMedium)
                            .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
                    )
            }
            .padding(.horizontal, LayoutMetrics.spacingSmall)
            .padding(.vertical, LayoutMetrics.spacingSmall)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CometChatAIConversationStarterShimmerSwiftUI: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: LayoutMetrics.spacingStandard) {
            ForEach(0..<3, id: \.self) { _ in
                shimmerCell
            }
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    private var shimmerCell: some View {
        RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium)
            .fill(LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.3),
                    Color.gray.opacity(0.1),
                    Color.gray.opacity(0.3)
                ]),
                startPoint: .leading,
                endPoint: isAnimating ? .trailing : .leading
            ))
            .frame(height: LayoutMetrics.avatarSmall + LayoutMetrics.spacingStandard)
            .padding(.horizontal, LayoutMetrics.spacingSmall)
    }
}

extension CometChatAIConversationStarterSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatAIConversationStarterSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatAIConversationStarterSwiftUI()
                .set(aiMessageOptions: [
                    "How can I help you today?",
                    "Tell me about your product",
                    "What are your business hours?"
                ])
                .padding()
                .previewDisplayName("Default (Light)")
            
            CometChatAIConversationStarterSwiftUI()
                .set(aiMessageOptions: [
                    "How can I help you today?",
                    "Tell me about your product",
                    "What are your business hours?"
                ])
                .preferredColorScheme(.dark)
                .padding()
                .previewDisplayName("Default (Dark)")
            
            CometChatAIConversationStarterSwiftUI()
                .showLoadingView()
                .padding()
                .previewDisplayName("Loading (Light)")
            
            CometChatAIConversationStarterSwiftUI()
                .showLoadingView()
                .preferredColorScheme(.dark)
                .padding()
                .previewDisplayName("Loading (Dark)")
            
            CometChatAIConversationStarterSwiftUI()
                .show(error: true)
                .padding()
                .previewDisplayName("Error (Light)")
            
            CometChatAIConversationStarterSwiftUI()
                .show(error: true)
                .preferredColorScheme(.dark)
                .padding()
                .previewDisplayName("Error (Dark)")
        }
    }
}
