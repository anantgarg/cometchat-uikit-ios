//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatQuickViewSwiftUI: View {
    
    private var style: QuickViewStyle = QuickViewStyle()
    @State private var title: String = "Interactive Message"
    @State private var subTitle: String = "Participant Information"
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color(style.leadingBarTint))
                .frame(width: style.leadingBarWidth)
                .cornerRadius(5, corners: [.topLeft, .bottomLeft])
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Font(style.titleFont))
                    .foregroundColor(Color(style.titleColor))
                    .frame(height: 30)
                
                Text(subTitle)
                    .font(Font(style.subtitleFont))
                    .foregroundColor(Color(style.subtitleColor))
                    .frame(height: 30)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color((UITraitCollection.current.userInterfaceStyle == .dark) ? .black : .white))
        .cornerRadius(5)
        .frame(height: 80)
    }
    
    public func set(title: String) -> CometChatQuickViewSwiftUI {
        var view = self
        view._title = State(initialValue: title)
        return view
    }
    
    public func set(titleFont: UIFont) -> CometChatQuickViewSwiftUI {
        var view = self
        view.style.set(titleFont: titleFont)
        return view
    }
    
    public func set(titleColor: UIColor) -> CometChatQuickViewSwiftUI {
        var view = self
        view.style.set(titleColor: titleColor)
        return view
    }
    
    public func set(subTitle: String) -> CometChatQuickViewSwiftUI {
        var view = self
        view._subTitle = State(initialValue: subTitle)
        return view
    }
    
    public func set(subTitleFont: UIFont) -> CometChatQuickViewSwiftUI {
        var view = self
        view.style.set(subtitleFont: subTitleFont)
        return view
    }
    
    public func set(subTitleColor: UIColor) -> CometChatQuickViewSwiftUI {
        var view = self
        view.style.set(subtitleColor: subTitleColor)
        return view
    }
    
    public func set(leadingBarTint: UIColor) -> CometChatQuickViewSwiftUI {
        var view = self
        view.style.set(leadingBarTint: leadingBarTint)
        return view
    }
    
    public func set(leadingBarWidth: CGFloat) -> CometChatQuickViewSwiftUI {
        var view = self
        view.style.set(leadingBarWidth: leadingBarWidth)
        return view
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension CometChatQuickViewSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatQuickViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatQuickViewSwiftUI()
                .previewLayout(.sizeThatFits)
                .frame(width: 300, height: 80)
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            CometChatQuickViewSwiftUI()
                .set(title: "Custom Title")
                .set(subTitle: "Custom Subtitle")
                .set(leadingBarTint: UIColor.red)
                .previewLayout(.sizeThatFits)
                .frame(width: 300, height: 80)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode - Custom")
        }
    }
}
