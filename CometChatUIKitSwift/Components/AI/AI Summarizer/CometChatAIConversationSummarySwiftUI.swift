//
//
//

import CometChatSDK
import CometChatUIKitSwift.Components.Shared.Constants
import SwiftUI

public struct CometChatAIConversationSummarySwiftUI: View {
    @StateObject private var viewModel = AIConversationSummaryViewModelSwiftUI()

    private var onCloseButtonClicked: (() -> Void)?
    private var id: [String: Any]?
    private var disableLoadingState: Bool = false

    public static var style = AIConversationSummaryStyle()
    private var style = CometChatAIConversationSummarySwiftUI.style

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(viewModel.title)
                    .font(Font(style.titleTextFont))
                    .foregroundColor(Color(style.titleTextColor))

                Spacer()

                Button(action: {
                    onCloseButtonClicked?() ?? closeButtonAction()
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color(style.cancelButtonImageTintColor))
                }
                .frame(width: 16, height: 16)
            }
            .padding(.horizontal, LayoutMetrics.spacingLarge)
            .padding(.top, LayoutMetrics.spacingMedium)

            if viewModel.showError {
                errorView
            } else if viewModel.isLoading {
                loadingView
            } else {
                summaryView
            }
        }
        .background(Color(style.backgroundColor))
        .cornerRadius(style.cornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusStandard)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusStandard)
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
                .padding(.horizontal, LayoutMetrics.spacingExtraLarge)
                .padding(.vertical, LayoutMetrics.spacingStandard)
                .frame(height: 162)
        }
        .padding(.top, LayoutMetrics.spacingStandard)
        .padding(.bottom, LayoutMetrics.spacingStandard)
    }

    private var loadingView: some View {
        CometChatAIConversationSummaryShimmerSwiftUI()
            .frame(height: 160)
            .cornerRadius(style.cornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusStandard)
            .padding(.top, LayoutMetrics.spacingStandard)
            .padding(.horizontal, LayoutMetrics.spacingStandard)
            .padding(.bottom, LayoutMetrics.spacingMedium)
    }

    private var summaryView: some View {
        Text(viewModel.summary)
            .font(Font(style.summaryTextFont))
            .foregroundColor(Color(style.summaryTextColor))
            .multilineTextAlignment(.leading)
            .padding(.horizontal, LayoutMetrics.spacingLarge)
            .padding(.top, LayoutMetrics.spacingStandard)
            .padding(.bottom, LayoutMetrics.spacingMedium)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func closeButtonAction() {
        if let id {
            CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
        }
    }

    @discardableResult
    public func set(summary: String) -> Self {
        var view = self
        view.viewModel.set(summary: summary)
        return view
    }

    @discardableResult
    public func set(id: [String: Any]?) -> Self {
        var view = self
        view.id = id
        return view
    }

    @discardableResult
    public func set(title: String) -> Self {
        var view = self
        view.viewModel.set(title: title)
        return view
    }

    @discardableResult
    public func onCloseButtonClicked(onCloseButtonClicked: @escaping (() -> Void)) -> Self {
        var view = self
        view.onCloseButtonClicked = onCloseButtonClicked
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
    public func set(style: AIConversationSummaryStyle) -> Self {
        var view = self
        view.style = style
        return view
    }

    @discardableResult
    public func set(configuration: AIConversationSummaryConfiguration?) -> Self {
        var view = self
        if let configuration, let title = configuration.title {
            view.viewModel.set(title: title)
        }
        return view
    }
}

struct CometChatAIConversationSummaryShimmerSwiftUI: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0 ..< 4, id: \.self) { _ in
                shimmerLine
            }
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }

    private var shimmerLine: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.3),
                    Color.gray.opacity(0.1),
                    Color.gray.opacity(0.3),
                ]),
                startPoint: .leading,
                endPoint: isAnimating ? .trailing : .leading
            ))
            .frame(height: 24)
    }
}

public extension CometChatAIConversationSummarySwiftUI {
    func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatAIConversationSummarySwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatAIConversationSummarySwiftUI()
                .set(summary: "This conversation was about scheduling a meeting for next week. The team discussed availability and decided on Tuesday at 2 PM. They also mentioned the need to prepare a presentation for the client.")
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Default")

            CometChatAIConversationSummarySwiftUI()
                .showLoadingView()
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Loading")

            CometChatAIConversationSummarySwiftUI()
                .show(error: true)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Error")

            CometChatAIConversationSummarySwiftUI()
                .set(summary: "This conversation was about scheduling a meeting for next week. The team discussed availability and decided on Tuesday at 2 PM.")
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Dark Mode")
        }
    }
}
