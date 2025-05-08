//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatEmojiKeyboardSwiftUI: View {
    
    private var style: EmojiKeyboardStyle
    private var onClick: ((_ emoji: CometChatEmoji) -> Void)?
    private var onCancel: (() -> Void)?
    @State private var emojiCategories: [CometChatEmojiCategory] = []
    @State private var selectedCategoryIndex: Int = 0
    @State private var hideHeader: Bool = false
    
    public init(style: EmojiKeyboardStyle = EmojiKeyboardStyle()) {
        self.style = style
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if !hideHeader {
                HStack {
                    Button(action: {
                        onCancel?()
                    }) {
                        Text("CANCEL".localize())
                            .foregroundColor(Color(style.cancelButtonTint))
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Text("EMOJI_KEYBOARD".localize())
                        .font(Font(style.titleFont))
                        .foregroundColor(Color(style.titleColor))
                    
                    Spacer()
                    
                    Text("")
                        .padding(.trailing)
                }
                .padding(.vertical, 8)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<emojiCategories.count, id: \.self) { index in
                        Button(action: {
                            selectedCategoryIndex = index
                        }) {
                            if let symbolImage = UIImage(named: emojiCategories[index].symbol, in: CometChatUIKit.bundle, compatibleWith: nil) {
                                Image(uiImage: symbolImage)
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(selectedCategoryIndex == index ? 
                                                    Color(style.selectedCategoryIconTint) : 
                                                    Color(style.categoryIconTint))
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                .frame(height: 50)
            }
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(0..<emojiCategories.count, id: \.self) { categoryIndex in
                        VStack(alignment: .leading) {
                            Text(emojiCategories[categoryIndex].name)
                                .font(Font(style.sectionHeaderFont))
                                .foregroundColor(Color(style.sectionHeaderColor))
                                .padding(.horizontal, 15)
                                .padding(.top, 5)
                                .id("category_\(categoryIndex)")
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 8), spacing: 10) {
                                ForEach(0..<emojiCategories[categoryIndex].emojis.count, id: \.self) { emojiIndex in
                                    Button(action: {
                                        onClick?(emojiCategories[categoryIndex].emojis[emojiIndex])
                                    }) {
                                        if let emojiImage = emojiCategories[categoryIndex].emojis[emojiIndex].emoji.textToImage() {
                                            Image(uiImage: emojiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                            .padding(.bottom, 5)
                        }
                    }
                }
            }
            .onChange(of: selectedCategoryIndex) { newValue in
                withAnimation {
                }
            }
        }
        .background(Color(style.background))
        .onAppear {
            fetchEmojis()
        }
    }
    
    private func fetchEmojis() {
        CometChatEmojiCategoryJSON.getEmojis { data in
            do {
                self.emojiCategories = try JSONDecoder().decode(CometChatEmojiCategories.self, from: data).emojiCategory
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    public func setOnClick(onClick: @escaping ((_ emoji: CometChatEmoji) -> Void)) -> CometChatEmojiKeyboardSwiftUI {
        var view = self
        view.onClick = onClick
        return view
    }
    
    public func set(onCancel: @escaping (() -> Void)) -> CometChatEmojiKeyboardSwiftUI {
        var view = self
        view.onCancel = onCancel
        return view
    }
    
    public func hide(headerView: Bool) -> CometChatEmojiKeyboardSwiftUI {
        var view = self
        view.hideHeader = headerView
        return view
    }
}

extension String {
    func textToImage() -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: 30)
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        UIColor.clear.set()
        
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize))
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension CometChatEmojiKeyboardSwiftUI {
    public func toUIKit() -> UIViewController {
        let hostingController = UIHostingController(rootView: self)
        return hostingController
    }
}

struct CometChatEmojiKeyboardSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatEmojiKeyboardSwiftUI()
                .previewLayout(.sizeThatFits)
                .frame(height: 400)
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            CometChatEmojiKeyboardSwiftUI()
                .previewLayout(.sizeThatFits)
                .frame(height: 400)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
