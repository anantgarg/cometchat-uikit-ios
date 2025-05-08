//
//
//

import SwiftUI
import CometChatSDK

public enum ActivityIndicatorStyleSwiftUI {
    case medium
    case gray
    case large
}

public struct ActivityIndicatorSwiftUI: View {
    
    @State private var isAnimating: Bool = false
    @State private var color: Color = Color(CometChatTheme_v4.palatte.accent600)
    @State private var style: UIActivityIndicatorView.Style = .medium
    
    public init() {}
    
    public var body: some View {
        if isAnimating {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: color))
                .scaleEffect(getScaleForStyle())
                .frame(maxWidth: .infinity, height: 44)
        } else {
            EmptyView()
        }
    }
    
    private func getScaleForStyle() -> CGFloat {
        switch style {
        case .large:
            return 1.5
        case .medium:
            return 1.0
        default:
            return 1.0
        }
    }
    
    public func show() -> ActivityIndicatorSwiftUI {
        var view = self
        view._isAnimating = State(initialValue: true)
        return view
    }
    
    public func hide() -> ActivityIndicatorSwiftUI {
        var view = self
        view._isAnimating = State(initialValue: false)
        return view
    }
    
    public func set(style: UIActivityIndicatorView.Style) -> ActivityIndicatorSwiftUI {
        var view = self
        view._style = State(initialValue: style)
        return view
    }
    
    public func set(tintColor: UIColor) -> ActivityIndicatorSwiftUI {
        var view = self
        view._color = State(initialValue: Color(tintColor))
        return view
    }
}

extension ActivityIndicatorSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct ActivityIndicatorSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                ActivityIndicatorSwiftUI()
                    .show()
                    .previewDisplayName("Default")
                
                ActivityIndicatorSwiftUI()
                    .show()
                    .set(style: .large)
                    .previewDisplayName("Large")
                
                ActivityIndicatorSwiftUI()
                    .show()
                    .set(tintColor: UIColor.red)
                    .previewDisplayName("Custom Color")
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            
            VStack(spacing: 20) {
                ActivityIndicatorSwiftUI()
                    .show()
                
                ActivityIndicatorSwiftUI()
                    .show()
                    .set(style: .large)
                
                ActivityIndicatorSwiftUI()
                    .show()
                    .set(tintColor: UIColor.red)
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        }
    }
}
