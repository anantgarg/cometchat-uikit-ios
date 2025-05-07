//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatStatusIndicatorSwiftUI: View {
    private var style: StatusIndicatorStyle
    private var status: CometChatSDK.UserStatus?
    private var icon: UIImage?
    private var tintColor: UIColor?
    private var isHidden: Bool = false
    
    public init(style: StatusIndicatorStyle = CometChatStatusIndicator.style) {
        self.style = style
    }
    
    public var body: some View {
        ZStack {
            if let icon = icon, let tintColor = tintColor {
                Image(uiImage: icon)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color(tintColor))
                    .frame(width: 12, height: 12) // Default size for icon
            } else {
                Circle()
                    .fill(Color(style.backgroundColor))
            }
        }
        .frame(width: 20, height: 20) // Default size
        .background(Color(style.backgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? 10)
                .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
        )
        .cornerRadius(style.cornerRadius?.cornerRadius ?? 10)
        .opacity(isHidden ? 0 : 1)
    }
    
    public func set(status: CometChatSDK.UserStatus, backgroundColor: UIColor? = nil) -> CometChatStatusIndicatorSwiftUI {
        var view = self
        view.status = status
        
        switch status {
        case .online, .available:
            view.isHidden = false
        case .offline:
            view.isHidden = true
        default:
            break
        }
        
        if let backgroundColor = backgroundColor {
            var newStyle = view.style
            newStyle.backgroundColor = backgroundColor
            view.style = newStyle
        }
        
        return view
    }
    
    public func set(icon: UIImage?, with tintColor: UIColor) -> CometChatStatusIndicatorSwiftUI {
        var view = self
        view.icon = icon
        view.tintColor = tintColor
        return view
    }
}

extension CometChatStatusIndicatorSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatStatusIndicatorSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatStatusIndicatorSwiftUI()
                .set(status: .online)
                .previewLayout(.fixed(width: 50, height: 50))
                .previewDisplayName("Online Status")
            
            CometChatStatusIndicatorSwiftUI()
                .set(status: .offline)
                .previewLayout(.fixed(width: 50, height: 50))
                .previewDisplayName("Offline Status")
            
            CometChatStatusIndicatorSwiftUI()
                .set(icon: UIImage(systemName: "checkmark"), with: .white)
                .previewLayout(.fixed(width: 50, height: 50))
                .previewDisplayName("With Icon")
        }
    }
}
