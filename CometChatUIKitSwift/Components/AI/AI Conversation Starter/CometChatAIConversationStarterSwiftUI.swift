//
//
//

import SwiftUI
import CometChatSDK

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
        .padding(.vertical, CometChatSpacing.Padding.p2)
    }
    
    private var errorView: some View {
        VStack {
            Text("SOMETHING_WENT_WRONG_WITH_NEW_LINE".localize())
                .font(Font(style.errorViewTextFont))
                .foregroundColor(Color(style.errorViewTextColor))
                .multilineTextAlignment(.center)
                .padding(.horizontal, CometChatSpacing.Padding.p6)
                .padding(.vertical, CometChatSpacing.Padding.p2)
                .frame(height: 120)
        }
    }
    
    private var loadingView: some View {
        CometChatAIConversationStarterShimmerSwiftUI()
            .frame(height: 120)
            .cornerRadius(16)
    }
    
    private var messageListView: some View {
        VStack(spacing: 8) {
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
                    .padding(.horizontal, CometChatSpacing.Padding.p5)
                    .padding(.vertical, CometChatSpacing.Padding.p2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(style.backgroundColor))
                    .cornerRadius(style.cornerRadius?.cornerRadius ?? 15)
                    .overlay(
                        RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? 15)
                            .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
                    )
            }
            .padding(.horizontal, CometChatSpacing.Padding.p)
            .padding(.vertical, CometChatSpacing.Padding.p1)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CometChatAIConversationStarterShimmerSwiftUI: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 8) {
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
        RoundedRectangle(cornerRadius: 15)
            .fill(LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemGray5),
                    Color(UIColor.systemGray6),
                    Color(UIColor.systemGray5)
                ]),
                startPoint: .leading,
                endPoint: isAnimating ? .trailing : .leading
            ))
            .frame(height: 32)
            .padding(.horizontal, CometChatSpacing.Padding.p)
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
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Default")
            
            CometChatAIConversationStarterSwiftUI()
                .showLoadingView()
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Loading")
            
            CometChatAIConversationStarterSwiftUI()
                .show(error: true)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Error")
            
            CometChatAIConversationStarterSwiftUI()
                .set(aiMessageOptions: [
                    "How can I help you today?",
                    "Tell me about your product",
                    "What are your business hours?"
                ])
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Dark Mode")
        }
    }
}
