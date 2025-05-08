//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatNewMessageIndicatorSwiftUI: View {
    public static var style = NewMessageIndicatorStyle()
    private var style: NewMessageIndicatorStyle
    
    @State private var count: Int = 0
    private var onClick: (() -> Void)?
    
    public init(style: NewMessageIndicatorStyle = CometChatNewMessageIndicatorSwiftUI.style) {
        self.style = style
    }
    
    public var body: some View {
        Button(action: {
            onClick?()
        }) {
            VStack(spacing: 4) {
                if count > 0 {
                    Text("\(count)")
                        .font(Font(style.textFont))
                        .foregroundColor(Color(style.textColor))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color(style.textBackgroundColor))
                        .cornerRadius(9)
                }
                
                Image(uiImage: style.iconImage)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color(style.imageTint))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
            .padding(CometChatSpacing.Padding.p2)
            .background(Color(style.backgroundColor))
            .cornerRadius(16) // Half of default 32x32 size
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
            )
        }
        .frame(width: 32, height: 32)
    }
    
    public func set(count: Int) -> CometChatNewMessageIndicatorSwiftUI {
        var view = self
        view._count = State(initialValue: count)
        return view
    }
    
    public func incrementCount() -> CometChatNewMessageIndicatorSwiftUI {
        var view = self
        view._count = State(initialValue: count + 1)
        return view
    }
    
    public func reset() -> CometChatNewMessageIndicatorSwiftUI {
        var view = self
        view._count = State(initialValue: 0)
        return view
    }
    
    public func setOnClick(onClick: @escaping () -> Void) -> CometChatNewMessageIndicatorSwiftUI {
        var view = self
        view.onClick = onClick
        return view
    }
}

extension CometChatNewMessageIndicatorSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatNewMessageIndicatorSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                CometChatNewMessageIndicatorSwiftUI()
                    .previewDisplayName("Default State")
                
                CometChatNewMessageIndicatorSwiftUI()
                    .set(count: 5)
                    .previewDisplayName("With Count")
                
                CometChatNewMessageIndicatorSwiftUI()
                    .set(count: 10)
                    .previewDisplayName("With Higher Count")
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            
            VStack(spacing: 20) {
                CometChatNewMessageIndicatorSwiftUI()
                
                CometChatNewMessageIndicatorSwiftUI()
                    .set(count: 5)
                
                CometChatNewMessageIndicatorSwiftUI()
                    .set(count: 10)
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        }
    }
}
