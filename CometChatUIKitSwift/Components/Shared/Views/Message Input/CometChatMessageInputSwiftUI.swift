//
//
//

import SwiftUI
import CometChatSDK

public enum AuxilaryButtonAlignment {
    case left
    case right
}

public struct CometChatMessageInputSwiftUI: View {
    
    @State private var text: String = ""
    @State private var maxLines: Int = 5
    @State private var auxilaryButtonAlignment: AuxilaryButtonAlignment = .left
    @State private var placeholderText: String = "TYPE_A_MESSAGE".localize()
    
    private var style: MessageInputStyle = MessageInputStyle()
    private var onChange: ((String) -> Void)?
    private var shouldBeginEditing: ((Bool) -> Void)?
    private var shouldEndEditing: ((Bool) -> Void)?
    private var didChangeSelection: (() -> Void)?
    private var shouldChangeTextInRange: ((NSRange, String) -> Bool)?
    
    @State private var primaryButtonView: AnyView?
    @State private var secondaryButtonView: AnyView?
    @State private var auxilaryButtonView: AnyView?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholderText)
                            .font(Font(style.placeHolderTextFont))
                            .foregroundColor(Color(style.placeHolderTextColor))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                    }
                    
                    TextEditor(text: $text)
                        .font(Font(style.textFont))
                        .foregroundColor(Color(style.textColor))
                        .frame(minHeight: 40, maxHeight: CGFloat(maxLines) * 24) // Approximate line height
                        .padding(.horizontal, 4)
                        .onChange(of: text) { newValue in
                            onChange?(newValue)
                        }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(style.inputBackground))
                .cornerRadius(18, corners: [.topLeft, .topRight])
                
                Divider()
                    .frame(height: 1)
                    .background(Color(style.dividerColor))
                
                HStack(spacing: 8) {
                    if let secondaryButtonView = secondaryButtonView {
                        secondaryButtonView
                    }
                    
                    if auxilaryButtonAlignment == .left, let auxilaryButtonView = auxilaryButtonView {
                        auxilaryButtonView
                    }
                    
                    Spacer()
                    
                    if auxilaryButtonAlignment == .right, let auxilaryButtonView = auxilaryButtonView {
                        auxilaryButtonView
                    }
                    
                    if let primaryButtonView = primaryButtonView {
                        primaryButtonView
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(style.inputBackground))
                .cornerRadius(18, corners: [.bottomLeft, .bottomRight])
            }
            .background(Color(style.background))
            .cornerRadius(18)
        }
    }
    
    public func set(messageInputStyle: MessageInputStyle) -> CometChatMessageInputSwiftUI {
        var view = self
        view.style = messageInputStyle
        return view
    }
    
    public func set(maxLines: Int) -> CometChatMessageInputSwiftUI {
        var view = self
        view._maxLines = State(initialValue: maxLines)
        return view
    }
    
    public func set(text: String) -> CometChatMessageInputSwiftUI {
        var view = self
        view._text = State(initialValue: text)
        return view
    }
    
    public func set(attributedText: NSAttributedString) -> CometChatMessageInputSwiftUI {
        var view = self
        view._text = State(initialValue: attributedText.string)
        return view
    }
    
    public func append(text: String) -> CometChatMessageInputSwiftUI {
        var view = self
        view._text = State(initialValue: self.text + text)
        return view
    }
    
    public func set<V: View>(primaryButtonView: V) -> CometChatMessageInputSwiftUI {
        var view = self
        view._primaryButtonView = State(initialValue: AnyView(primaryButtonView))
        return view
    }
    
    public func set<V: View>(secondaryButtonView: V) -> CometChatMessageInputSwiftUI {
        var view = self
        view._secondaryButtonView = State(initialValue: AnyView(secondaryButtonView))
        return view
    }
    
    public func set<V: View>(auxilaryButtonView: V) -> CometChatMessageInputSwiftUI {
        var view = self
        view._auxilaryButtonView = State(initialValue: AnyView(auxilaryButtonView))
        return view
    }
    
    public func set(auxilaryButtonAlignment: AuxilaryButtonAlignment) -> CometChatMessageInputSwiftUI {
        var view = self
        view._auxilaryButtonAlignment = State(initialValue: auxilaryButtonAlignment)
        return view
    }
    
    public func set(placeholderText: String) -> CometChatMessageInputSwiftUI {
        var view = self
        view._placeholderText = State(initialValue: placeholderText)
        return view
    }
    
    public func set(onChange: @escaping ((String) -> Void)) -> CometChatMessageInputSwiftUI {
        var view = self
        view.onChange = onChange
        return view
    }
    
    public func set(shouldBeginEditing: @escaping ((Bool) -> Void)) -> CometChatMessageInputSwiftUI {
        var view = self
        view.shouldBeginEditing = shouldBeginEditing
        return view
    }
    
    public func set(shouldEndEditing: @escaping ((Bool) -> Void)) -> CometChatMessageInputSwiftUI {
        var view = self
        view.shouldEndEditing = shouldEndEditing
        return view
    }
    
    public func set(didChangeSelection: @escaping (() -> Void)) -> CometChatMessageInputSwiftUI {
        var view = self
        view.didChangeSelection = didChangeSelection
        return view
    }
    
    public func set(shouldChangeTextInRange: @escaping ((NSRange, String) -> Bool)) -> CometChatMessageInputSwiftUI {
        var view = self
        view.shouldChangeTextInRange = shouldChangeTextInRange
        return view
    }
}

extension CometChatMessageInputSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
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

struct CometChatMessageInputSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                CometChatMessageInputSwiftUI()
                    .set(placeholderText: "Type a message...")
                    .set(primaryButtonView: 
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                    )
                    .set(secondaryButtonView:
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray)
                    )
                    .previewDisplayName("Default")
                
                CometChatMessageInputSwiftUI()
                    .set(text: "Hello, this is a sample message")
                    .set(auxilaryButtonView:
                        Image(systemName: "mic.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    )
                    .set(auxilaryButtonAlignment: .right)
                    .previewDisplayName("With Text")
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            
            VStack(spacing: 20) {
                CometChatMessageInputSwiftUI()
                    .set(placeholderText: "Type a message...")
                    .set(primaryButtonView: 
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                    )
                
                CometChatMessageInputSwiftUI()
                    .set(text: "Hello, this is a sample message")
                    .set(auxilaryButtonView:
                        Image(systemName: "mic.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    )
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        }
    }
}
