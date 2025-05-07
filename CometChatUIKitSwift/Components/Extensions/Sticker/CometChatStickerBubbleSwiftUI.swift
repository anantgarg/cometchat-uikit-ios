//
//
//

import SwiftUI
import CometChatSDK
import CometChatUIKitSwift.Components.Shared.Constants

public struct CometChatStickerBubbleSwiftUI: View {
    
    @State private var imageURL: String?
    @State private var style: StickerBubbleStyle = StickerBubbleStyle()
    @State private var controller: UIViewController?
    @State private var onClick: (() -> Void)?
    @State private var uiImage: UIImage?
    @State private var isLoading: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: LayoutMetrics.spacingStandard) {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: LayoutMetrics.loadingContentWidth - LayoutMetrics.spacingExtraLarge, height: LayoutMetrics.loadingContentWidth - LayoutMetrics.spacingExtraLarge)
                    .onTapGesture {
                        onClick?()
                    }
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: LayoutMetrics.loadingContentWidth - LayoutMetrics.spacingExtraLarge, height: LayoutMetrics.loadingContentWidth - LayoutMetrics.spacingExtraLarge)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
                .onAppear {
                    loadImage()
                }
            }
        }
        .padding(EdgeInsets(
            top: LayoutMetrics.spacingSmall,
            leading: LayoutMetrics.spacingSmall,
            bottom: LayoutMetrics.spacingStandard,
            trailing: LayoutMetrics.spacingSmall
        ))
        .background(Color(style.backgroundColor ?? .clear))
    }
    
    private func loadImage() {
        guard let imageURL = imageURL, let url = URL(string: imageURL) else { return }
        
        isLoading = true
        
        ImageService().image(for: url, cacheType: .normal) { loadedImage in
            if let loadedImage = loadedImage {
                DispatchQueue.main.async {
                    self.uiImage = loadedImage
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    @discardableResult
    public func set(image: UIImage) -> Self {
        var view = self
        view._uiImage = State(initialValue: image)
        return view
    }
    
    @discardableResult
    public func set(imageUrl: String) -> Self {
        var view = self
        view._imageURL = State(initialValue: imageUrl)
        return view
    }
    
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        var view = self
        view._controller = State(initialValue: controller)
        return view
    }
    
    @discardableResult
    public func set(style: StickerBubbleStyle) -> Self {
        var view = self
        view._style = State(initialValue: style)
        return view
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping (() -> Void)) -> Self {
        var view = self
        view._onClick = State(initialValue: onClick)
        return view
    }
    
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        let view = hostingController.view
        view?.translatesAutoresizingMaskIntoConstraints = false
        view?.widthAnchor.constraint(equalToConstant: LayoutMetrics.loadingContentWidth - LayoutMetrics.spacingExtraLarge).isActive = true
        view?.heightAnchor.constraint(equalToConstant: LayoutMetrics.loadingContentWidth - LayoutMetrics.spacingExtraLarge).isActive = true
        return view ?? UIView()
    }
}

struct CometChatStickerBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatStickerBubbleSwiftUI()
                .set(imageUrl: "https://data-us.cometchat.io/assets/stickers/happy.png")
                .padding()
                .previewDisplayName("Default Sticker Bubble (Light)")
            
            CometChatStickerBubbleSwiftUI()
                .set(imageUrl: "https://data-us.cometchat.io/assets/stickers/happy.png")
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Default Sticker Bubble (Dark)")
            
            CometChatStickerBubbleSwiftUI()
                .set(imageUrl: "https://data-us.cometchat.io/assets/stickers/thumbsup.png")
                .set(style: StickerBubbleStyle())
                .padding()
                .previewDisplayName("Custom Style Sticker Bubble (Light)")
                
            CometChatStickerBubbleSwiftUI()
                .set(imageUrl: "https://data-us.cometchat.io/assets/stickers/thumbsup.png")
                .set(style: StickerBubbleStyle())
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Custom Style Sticker Bubble (Dark)")
        }
    }
}
