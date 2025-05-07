//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatAISmartReplySwiftUI: View {
    @StateObject private var viewModel = AISmartRepliesViewModelSwiftUI()
    
    private var onAiMessageClicked: ((String) -> Void)?
    private var onAiCloseButtonClicked: (() -> Void)?
    private var id: [String: Any]?
    private var disableLoadingState: Bool = false
    
    public static var style = AISmartRepliesStyle()
    private var style = CometChatAISmartReplySwiftUI.style
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("SUGGEST_A_REPLY".localize())
                    .font(Font(style.titleTextFont))
                    .foregroundColor(Color(style.titleTextColor))
                
                Spacer()
                
                Button(action: {
                    onAiCloseButtonClicked?()
                }) {
                    Image(uiImage: style.cancelButtonImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(style.cancelButtonImageTintColor))
                }
                .frame(width: 20, height: 20)
            }
            .padding(.horizontal, CometChatSpacing.Padding.p3)
            .padding(.top, CometChatSpacing.Padding.p3)
            
            if viewModel.showError {
                errorView
            } else if viewModel.isLoading {
                loadingView
            } else {
                repliesListView
            }
        }
        .background(Color(style.backgroundColor))
        .cornerRadius(style.cornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r4)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r4)
                .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var errorView: some View {
        VStack {
            Text("SOMETHING_WENT_WRONG_WITH_NEW_LINE".localize())
                .font(Font(style.errorViewTextFont))
                .foregroundColor(Color(style.errorViewTextColor))
                .multilineTextAlignment(.center)
                .padding(.horizontal, CometChatSpacing.Padding.p6)
                .padding(.vertical, CometChatSpacing.Padding.p2)
                .frame(height: 200)
        }
        .padding(.top, CometChatSpacing.Padding.p2)
        .padding(.bottom, CometChatSpacing.Padding.p2)
    }
    
    private var loadingView: some View {
        CometChatAISmartRepliesShimmerSwiftUI()
            .frame(height: 217)
            .cornerRadius(16)
            .padding(.top, CometChatSpacing.Padding.p2)
            .padding(.bottom, CometChatSpacing.Padding.p)
    }
    
    private var repliesListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.aiMessagesList, id: \.self) { message in
                    AIRepliesCellSwiftUI(
                        message: message,
                        style: style,
                        onTap: { selectedMessage in
                            onAiMessageClicked?(selectedMessage)
                        }
                    )
                }
            }
            .padding(.top, CometChatSpacing.Padding.p2)
            .padding(.bottom, CometChatSpacing.Padding.p3)
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
    public func onCloseButtonClicked(onAiCloseButtonClicked: @escaping (() -> Void)) -> Self {
        var view = self
        view.onAiCloseButtonClicked = onAiCloseButtonClicked
        return view
    }
    
    @discardableResult
    public func set(id: [String: Any]?) -> Self {
        var view = self
        view.id = id
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
    public func set(style: AISmartRepliesStyle) -> Self {
        var view = self
        view.style = style
        return view
    }
}

struct AIRepliesCellSwiftUI: View {
    let message: String
    let style: AISmartRepliesStyle
    let onTap: (String) -> Void
    
    var body: some View {
        Button(action: {
            onTap(message)
        }) {
            Text(message)
                .font(Font(style.repliesTextFont))
                .foregroundColor(Color(style.repliesTextColor))
                .multilineTextAlignment(.leading)
                .padding(.horizontal, CometChatSpacing.Padding.p3)
                .padding(.vertical, CometChatSpacing.Padding.p2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(style.repliesViewBackgroundColor))
                .cornerRadius(style.repliesViewCornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r2)
                .overlay(
                    RoundedRectangle(cornerRadius: style.repliesViewCornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r2)
                        .stroke(Color(style.repliesViewBorderColor), lineWidth: style.repliesViewBorderWidth)
                )
                .padding(.horizontal, CometChatSpacing.Padding.p3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CometChatAISmartRepliesShimmerSwiftUI: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { _ in
                shimmerCell
            }
        }
        .padding(.horizontal, CometChatSpacing.Padding.p3)
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    private var shimmerCell: some View {
        RoundedRectangle(cornerRadius: CometChatSpacing.Radius.r2)
            .fill(LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemGray5),
                    Color(UIColor.systemGray6),
                    Color(UIColor.systemGray5)
                ]),
                startPoint: .leading,
                endPoint: isAnimating ? .trailing : .leading
            ))
            .frame(height: 36)
    }
}

extension CometChatAISmartReplySwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatAISmartReplySwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatAISmartReplySwiftUI()
                .set(aiMessageOptions: [
                    "Thanks for your help!",
                    "Could you explain more?",
                    "I'll get back to you later",
                    "That sounds great!"
                ])
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Default")
            
            CometChatAISmartReplySwiftUI()
                .showLoadingView()
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Loading")
            
            CometChatAISmartReplySwiftUI()
                .show(error: true)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Error")
            
            CometChatAISmartReplySwiftUI()
                .set(aiMessageOptions: [
                    "Thanks for your help!",
                    "Could you explain more?",
                    "I'll get back to you later",
                    "That sounds great!"
                ])
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Dark Mode")
        }
    }
}
