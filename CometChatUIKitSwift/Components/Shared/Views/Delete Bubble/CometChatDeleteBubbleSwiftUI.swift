//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatDeleteBubbleSwiftUI: View {
    
    private var style: DeleteBubbleStyle
    
    private var messageText: String
    
    public init(style: DeleteBubbleStyle = DeleteBubbleStyle()) {
        self.style = style
        self.messageText = "MESSAGE_WAS_DELETED".localize()
    }
    
    public var body: some View {
        HStack(spacing: CometChatSpacing.Spacing.s1) {
            Image(uiImage: UIImage(named: "message-deleted", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color(style.deleteImageTintColor ?? CometChatTheme.neutralColor600))
                .frame(width: 16, height: 16)
            
            Text(messageText)
                .font(Font(style.textFont))
                .foregroundColor(Color(style.textColor ?? CometChatTheme.neutralColor600))
        }
        .padding(.horizontal, CometChatSpacing.Padding.p2)
        .padding(.top, CometChatSpacing.Padding.p2)
    }
    
    public func set(text: String) -> CometChatDeleteBubbleSwiftUI {
        var view = self
        view.messageText = text
        return view
    }
}

extension CometChatDeleteBubbleSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatDeleteBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatDeleteBubbleSwiftUI()
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            CometChatDeleteBubbleSwiftUI()
                .set(text: "Custom deleted message text")
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode - Custom Text")
        }
    }
}
