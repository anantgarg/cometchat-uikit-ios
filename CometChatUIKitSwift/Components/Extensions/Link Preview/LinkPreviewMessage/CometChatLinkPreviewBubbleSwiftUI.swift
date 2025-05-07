//
//
//

import SwiftUI
import CometChatSDK
import SafariServices
import MessageUI
import CometChatUIKitSwift.Components.Shared.Constants

public struct CometChatLinkPreviewBubbleSwiftUI: View {
    
    @State private var style: LinkPreviewBubbleStyle = LinkPreviewBubbleStyle()
    @State private var message: TextMessage?
    @State private var controller: UIViewController?
    @State private var attributedText: NSAttributedString?
    
    @State private var url: String?
    @State private var title: String?
    @State private var subtitle: String?
    @State private var thumbnailURL: String?
    @State private var faviconURL: String?
    @State private var showThumbnail: Bool = true
    @State private var showFavicon: Bool = false
    @State private var thumbnailImage: UIImage?
    @State private var faviconImage: UIImage?
    
    private let imageService = ImageService()
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                if showThumbnail, let image = thumbnailImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: LayoutMetrics.loadingContentWidth + LayoutMetrics.spacingLarge, height: LayoutMetrics.loadingContentHeight * 2.5)
                        .clipped()
                }
                
                VStack(alignment: .leading, spacing: LayoutMetrics.spacingSmall) {
                    if let title = title, !title.isEmpty {
                        HStack(spacing: LayoutMetrics.spacingSmall) {
                            Text(title)
                                .font(.headline)
                                .foregroundColor(Color(style.titleTextColor))
                                .lineLimit(3)
                            
                            if showFavicon, let image = faviconImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: LayoutMetrics.avatarMedium, height: LayoutMetrics.avatarMedium)
                                    .cornerRadius(style.linkIconImageCornerRadios.cornerRadius)
                            }
                        }
                    }
                    
                    if let subtitle = subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(Color(style.subtitleTextColor))
                            .lineLimit(4)
                    }
                    
                    if let url = url {
                        Text(url)
                            .font(.caption)
                            .foregroundColor(Color(style.linkTextColor))
                    }
                }
                .padding(LayoutMetrics.spacingStandard)
            }
            .background(Color(style.previewBackgroundColor))
            .cornerRadius(style.previewCornerRadius.cornerRadius)
            .onTapGesture {
                onLinkPreviewClick()
            }
            .padding(LayoutMetrics.spacingSmall)
            
            if let attributedText = attributedText {
                AttributedTextView(attributedText: attributedText)
                    .padding(.horizontal, LayoutMetrics.spacingMedium)
                    .padding(.top, LayoutMetrics.spacingMedium)
            } else if let message = message {
                Text(message.text)
                    .font(.body)
                    .foregroundColor(Color(style.messageTextColor))
                    .padding(.horizontal, LayoutMetrics.spacingMedium)
                    .padding(.top, LayoutMetrics.spacingMedium)
            }
        }
        .onAppear {
            setupStyle()
        }
    }
    
    @discardableResult
    public func set(message: TextMessage) -> Self {
        var view = self
        view.message = message
        view.parseLinkPreviewForMessage(message: message)
        return view
    }
    
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        var view = self
        view.controller = controller
        return view
    }
    
    @discardableResult
    public func set(attributedText: NSAttributedString) -> Self {
        var view = self
        view.attributedText = attributedText
        return view
    }
    
    @discardableResult
    public func set(style: LinkPreviewBubbleStyle) -> Self {
        var view = self
        view.style = style
        return view
    }
    
    private func setupStyle() {
    }
    
    private func parseLinkPreviewForMessage(message: TextMessage) {
        if let metaData = message.metaData,
           let injected = metaData["@injected"] as? [String: Any],
           let cometChatExtension = injected["extensions"] as? [String: Any],
           let linkPreviewDictionary = cometChatExtension["link-preview"] as? [String: Any],
           let linkArray = linkPreviewDictionary["links"] as? [[String: Any]],
           let linkPreview = linkArray.first {
            
            if let linkTitle = linkPreview["title"] as? String {
                self.title = linkTitle
            }
            
            if let description = linkPreview["description"] as? String {
                self.subtitle = description
            }
            
            if let thumbnail = linkPreview["image"] as? String, let url = URL(string: thumbnail) {
                self.thumbnailURL = thumbnail
                self.showThumbnail = true
                self.showFavicon = false
                
                imageService.image(for: url, cacheType: .normal) { image in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.thumbnailImage = image
                        }
                    }
                }
            } else if let favIcon = linkPreview["favicon"] as? String, let url = URL(string: favIcon) {
                self.faviconURL = favIcon
                self.showThumbnail = false
                self.showFavicon = true
                
                imageService.image(for: url, cacheType: .normal) { image in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.faviconImage = image
                        }
                    }
                }
            }
            
            if let linkURL = linkPreview["url"] as? String {
                self.url = linkURL
            }
        }
    }
    
    private func onLinkPreviewClick() {
        if let url = url, let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
    
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct AttributedTextView: UIViewRepresentable {
    let attributedText: NSAttributedString
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
    }
}

struct CometChatLinkPreviewBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatLinkPreviewBubbleSwiftUI()
                .set(message: createMockMessage())
                .padding()
                .previewDisplayName("Link Preview Bubble (Light)")
                
            CometChatLinkPreviewBubbleSwiftUI()
                .set(message: createMockMessage())
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Link Preview Bubble (Dark)")
        }
    }
    
    static func createMockMessage() -> TextMessage {
        let message = TextMessage(receiverUid: "receiver123", text: "Check out this link: https://www.cometchat.com", receiverType: .user)
        
        let linkPreview: [String: Any] = [
            "title": "CometChat - Communication APIs",
            "description": "Add chat, voice and video to your app",
            "url": "https://www.cometchat.com",
            "image": "https://www.cometchat.com/images/logo.png"
        ]
        
        let links: [[String: Any]] = [linkPreview]
        let linkPreviewDict: [String: Any] = ["links": links]
        let extensions: [String: Any] = ["link-preview": linkPreviewDict]
        let injected: [String: Any] = ["extensions": extensions]
        message.metaData = ["@injected": injected]
        
        return message
    }
}
