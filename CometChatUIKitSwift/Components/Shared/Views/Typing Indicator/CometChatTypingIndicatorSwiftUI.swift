//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatTypingIndicatorSwiftUI: View {
    public static var style = TypingIndicatorStyle()
    private var style: TypingIndicatorStyle
    private var text: String?
    
    public init(style: TypingIndicatorStyle = CometChatTypingIndicatorSwiftUI.style) {
        self.style = style
    }
    
    public var body: some View {
        if let text = text {
            HStack(spacing: 4) {
                Text(text)
                    .font(Font(style.textFont))
                    .foregroundColor(Color(style.textColor))
                
                HStack(spacing: 2) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color(style.textColor))
                            .frame(width: 4, height: 4)
                            .opacity(0.4)
                            .animation(
                                Animation.easeInOut(duration: 0.5)
                                    .repeatForever()
                                    .delay(0.2 * Double(index)),
                                value: UUID()
                            )
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
        } else {
            EmptyView()
        }
    }
    
    public func set(text: String) -> CometChatTypingIndicatorSwiftUI {
        var view = self
        view.text = text
        return view
    }
}

extension CometChatTypingIndicatorSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatTypingIndicatorSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatTypingIndicatorSwiftUI()
                .set(text: "John is typing")
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            CometChatTypingIndicatorSwiftUI()
                .set(text: "John is typing")
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
