//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatGradientViewSwiftUI: View {
    
    @State private var backgroundColor: Color = Color.clear
    @State private var gradientColors: [Color] = []
    
    public init() {}
    
    public var body: some View {
        if gradientColors.count > 1 {
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            backgroundColor
        }
    }
    
    public func set(backgroundColor: UIColor) -> CometChatGradientViewSwiftUI {
        var view = self
        view._backgroundColor = State(initialValue: Color(backgroundColor))
        return view
    }
    
    public func set(backgroundColorWithGradient: [UIColor]) -> CometChatGradientViewSwiftUI {
        var view = self
        let colors = backgroundColorWithGradient.map { Color($0) }
        view._gradientColors = State(initialValue: colors)
        return view
    }
    
    public func set(backgroundColorWithGradient: [CGColor]) -> CometChatGradientViewSwiftUI {
        var view = self
        let colors = backgroundColorWithGradient.map { Color(cgColor: $0) }
        view._gradientColors = State(initialValue: colors)
        return view
    }
}

extension CometChatGradientViewSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatGradientViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                CometChatGradientViewSwiftUI()
                    .set(backgroundColor: UIColor.blue)
                    .frame(height: 50)
                    .previewDisplayName("Solid Color")
                
                CometChatGradientViewSwiftUI()
                    .set(backgroundColorWithGradient: [UIColor.blue, UIColor.purple])
                    .frame(height: 50)
                    .previewDisplayName("Gradient Colors")
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            
            VStack(spacing: 20) {
                CometChatGradientViewSwiftUI()
                    .set(backgroundColor: UIColor.blue)
                    .frame(height: 50)
                
                CometChatGradientViewSwiftUI()
                    .set(backgroundColorWithGradient: [UIColor.blue, UIColor.purple])
                    .frame(height: 50)
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        }
    }
}
