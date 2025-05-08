//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatButtonSwiftUI: View {
    private var text: String?
    private var icon: UIImage?
    private var backgroundColor: Color = .clear
    private var cornerRadius: CometChatCornerStyle?
    private var isEnabled: Bool = true
    private var onClick: (() -> Void)?
    private var style: ButtonStyle
    
    public init(style: ButtonStyle = ButtonStyle()) {
        self.style = style
    }
    
    public var body: some View {
        Button(action: {
            onClick?()
        }) {
            VStack(spacing: 6) {
                if let icon = icon {
                    Image(uiImage: icon)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(style.iconTint))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .background(
                            style.iconBackground.map { Color($0) }
                        )
                        .cornerRadius(style.iconCornerRadius ?? 0)
                        .overlay(
                            RoundedRectangle(cornerRadius: style.iconCornerRadius ?? 0)
                                .stroke(Color.clear, lineWidth: style.iconBorder ?? 0)
                        )
                }
                
                if let text = text {
                    Text(text)
                        .font(Font(style.textFont))
                        .foregroundColor(Color(style.textColor))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .cornerRadius(cornerRadius?.cornerRadius ?? 0)
        }
        .disabled(!isEnabled)
    }
    
    public func set(text: String) -> CometChatButtonSwiftUI {
        var view = self
        view.text = text
        return view
    }
    
    public func set(icon: UIImage) -> CometChatButtonSwiftUI {
        var view = self
        view.icon = icon
        return view
    }
    
    public func setOnClick(onClick: @escaping (() -> Void)) -> CometChatButtonSwiftUI {
        var view = self
        view.onClick = onClick
        return view
    }
    
    public func set(backgroundColor: UIColor) -> CometChatButtonSwiftUI {
        var view = self
        view.backgroundColor = Color(backgroundColor)
        return view
    }
    
    public func set(cornerRadius: CometChatCornerStyle) -> CometChatButtonSwiftUI {
        var view = self
        view.cornerRadius = cornerRadius
        return view
    }
    
    public func disable(button: Bool) -> CometChatButtonSwiftUI {
        var view = self
        view.isEnabled = !button
        return view
    }
}

extension CometChatButtonSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatButtonSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                CometChatButtonSwiftUI()
                    .set(text: "Button Text")
                    .set(backgroundColor: CometChatTheme.palatte.primary)
                    .set(cornerRadius: CometChatCornerStyle(cornerRadius: 8))
                
                CometChatButtonSwiftUI()
                    .set(icon: UIImage(systemName: "plus")!)
                    .set(text: "Add Item")
                    .set(backgroundColor: CometChatTheme.palatte.accent)
                    .set(cornerRadius: CometChatCornerStyle(cornerRadius: 8))
                
                CometChatButtonSwiftUI()
                    .set(icon: UIImage(systemName: "trash")!)
                    .set(backgroundColor: CometChatTheme.palatte.error)
                    .set(cornerRadius: CometChatCornerStyle(cornerRadius: 20))
                
                CometChatButtonSwiftUI()
                    .set(text: "Disabled Button")
                    .set(backgroundColor: CometChatTheme.palatte.primary)
                    .set(cornerRadius: CometChatCornerStyle(cornerRadius: 8))
                    .disable(button: true)
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            VStack(spacing: 20) {
                CometChatButtonSwiftUI()
                    .set(text: "Button Text")
                    .set(backgroundColor: CometChatTheme.palatte.primary)
                    .set(cornerRadius: CometChatCornerStyle(cornerRadius: 8))
                
                CometChatButtonSwiftUI()
                    .set(icon: UIImage(systemName: "plus")!)
                    .set(text: "Add Item")
                    .set(backgroundColor: CometChatTheme.palatte.accent)
                    .set(cornerRadius: CometChatCornerStyle(cornerRadius: 8))
                
                CometChatButtonSwiftUI()
                    .set(icon: UIImage(systemName: "trash")!)
                    .set(backgroundColor: CometChatTheme.palatte.error)
                    .set(cornerRadius: CometChatCornerStyle(cornerRadius: 20))
                
                CometChatButtonSwiftUI()
                    .set(text: "Disabled Button")
                    .set(backgroundColor: CometChatTheme.palatte.primary)
                    .set(cornerRadius: CometChatCornerStyle(cornerRadius: 8))
                    .disable(button: true)
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
