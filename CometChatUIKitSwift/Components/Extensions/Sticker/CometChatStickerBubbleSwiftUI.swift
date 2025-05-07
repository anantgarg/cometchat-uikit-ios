//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatStickerBubbleSwiftUI: View {
    
    @State private var imageURL: String?
    @State private var style: StickerBubbleStyle = StickerBubbleStyle()
    @State private var controller: UIViewController?
    @State private var onClick: (() -> Void)?
    @State private var image: UIImage?
    @State private var isLoading: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 10) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 160, height: 160)
                    .onTapGesture {
                        onClick?()
                    }
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 160, height: 160)
                    
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
            top: CometChatSpacing.Padding.p1,
            leading: CometChatSpacing.Padding.p1,
            bottom: CometChatSpacing.Padding.p2,
            trailing: CometChatSpacing.Padding.p1
        ))
        .background(Color(style.backgroundColor ?? .clear))
    }
    
    private func loadImage() {
        guard let imageURL = imageURL, let url = URL(string: imageURL) else { return }
        
        isLoading = true
        
        ImageService().image(for: url, cacheType: .normal) { loadedImage in
            if let loadedImage = loadedImage {
                DispatchQueue.main.async {
                    self.image = loadedImage
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
        view._image = State(initialValue: image)
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
        view?.widthAnchor.constraint(equalToConstant: 160).isActive = true
        view?.heightAnchor.constraint(equalToConstant: 160).isActive = true
        return view ?? UIView()
    }
}

struct CometChatStickerBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatStickerBubbleSwiftUI()
                .set(imageUrl: "https://data-us.cometchat.io/assets/stickers/happy.png")
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Default Sticker Bubble")
            
            CometChatStickerBubbleSwiftUI()
                .set(imageUrl: "https://data-us.cometchat.io/assets/stickers/thumbsup.png")
                .set(style: StickerBubbleStyle())
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Custom Style Sticker Bubble")
        }
    }
}
