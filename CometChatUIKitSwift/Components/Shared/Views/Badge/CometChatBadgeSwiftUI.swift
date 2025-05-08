//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatBadgeSwiftUI: View {
    private var style: BadgeStyle
    private var count: Int = 0
    
    public init(style: BadgeStyle = CometChatBadge.style) {
        self.style = style
    }
    
    public var body: some View {
        if count > 0 {
            Text(getDisplayText())
                .font(Font(style.textFont))
                .foregroundColor(Color(style.textColor))
                .padding(.horizontal, CometChatSpacing.Padding.p1)
                .padding(.vertical, CometChatSpacing.Padding.p)
                .background(Color(style.backgroundColor))
                .cornerRadius(style.cornerRadius?.cornerRadius ?? 10)
                .overlay(
                    RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? 10)
                        .stroke(Color(cgColor: style.borderColor), lineWidth: style.borderWidth)
                )
                .fixedSize()
        }
    }
    
    private func getDisplayText() -> String {
        switch count {
        case 1..<999:
            return "\(count)"
        case 999...:
            return "999+"
        default:
            return ""
        }
    }
    
    public func set(count: Int) -> CometChatBadgeSwiftUI {
        var view = self
        view.count = count
        return view
    }
    
    public func incrementCount() -> CometChatBadgeSwiftUI {
        var view = self
        view.count += 1
        return view
    }
    
    public func removeCount() -> CometChatBadgeSwiftUI {
        var view = self
        view.count = 0
        return view
    }
}

extension CometChatBadgeSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatBadgeSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatBadgeSwiftUI()
                .set(count: 5)
                .previewLayout(.fixed(width: 100, height: 50))
                .preferredColorScheme(.light)
            
            CometChatBadgeSwiftUI()
                .set(count: 999)
                .previewLayout(.fixed(width: 100, height: 50))
                .preferredColorScheme(.dark)
        }
    }
}
