//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatMessageBubbleSwiftUI: View {
    private var style: MessageBubbleStyle
    private var alignment: MessageBubbleAlignment = .right
    private var avatarName: String?
    private var avatarURL: String?
    private var baseMessage: BaseMessage?
    private var onLongPress: (() -> Void)?
    
    @State private var isLongPressed = false
    
    public init(style: MessageBubbleStyle = MessageBubbleStyle()) {
        self.style = style
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if alignment == .left {
                avatarView
                    .padding(.trailing, 8)
            } else if alignment == .right {
                Spacer()
            }
            
            VStack(alignment: alignment == .right ? .trailing : .leading, spacing: 0) {
                headerViewPlaceholder
                
                VStack(alignment: .leading, spacing: 0) {
                    replyViewPlaceholder
                    
                    messageContentViewPlaceholder
                    
                    statusInfoViewPlaceholder
                    
                    bottomViewPlaceholder
                }
                .background(Color(style.backgroundColor))
                .cornerRadius(style.cornerRadius.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: style.cornerRadius.cornerRadius)
                        .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
                )
                .scaleEffect(isLongPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isLongPressed)
                .onLongPressGesture(minimumDuration: 0.3, pressing: { pressing in
                    self.isLongPressed = pressing
                }, perform: {
                    onLongPress?()
                })
                
                footerViewPlaceholder
                
                viewReplyViewPlaceholder
            }
            
            if alignment == .right {
                avatarView
                    .padding(.leading, 8)
                    .opacity(0) // Hidden for right alignment but maintains spacing
            } else if alignment == .left {
                Spacer()
            }
        }
        .padding(.horizontal, CometChatSpacing.Padding.p4)
        .padding(.vertical, CometChatSpacing.Padding.p2)
    }
    
    private var avatarView: some View {
        CometChatAvatarSwiftUI(style: style.avatarStyle)
            .set(avatarURL: avatarURL)
            .set(name: avatarName)
            .set(width: 32)
            .set(height: 32)
    }
    
    private var headerViewPlaceholder: some View {
        EmptyView() // Will be replaced with actual content
    }
    
    private var replyViewPlaceholder: some View {
        EmptyView() // Will be replaced with actual content
    }
    
    private var messageContentViewPlaceholder: some View {
        EmptyView() // Will be replaced with actual content
    }
    
    private var statusInfoViewPlaceholder: some View {
        EmptyView() // Will be replaced with actual content
    }
    
    private var bottomViewPlaceholder: some View {
        EmptyView() // Will be replaced with actual content
    }
    
    private var footerViewPlaceholder: some View {
        EmptyView() // Will be replaced with actual content
    }
    
    private var viewReplyViewPlaceholder: some View {
        EmptyView() // Will be replaced with actual content
    }
    
    public func set(bubbleAlignment: MessageBubbleAlignment) -> CometChatMessageBubbleSwiftUI {
        var view = self
        view.alignment = bubbleAlignment
        return view
    }
    
    public func set(avatarURL: String?, avatarName: String?) -> CometChatMessageBubbleSwiftUI {
        var view = self
        view.avatarURL = avatarURL
        view.avatarName = avatarName
        return view
    }
    
    public func set(message: BaseMessage) -> CometChatMessageBubbleSwiftUI {
        var view = self
        view.baseMessage = message
        return view
    }
    
    public func onLongPress(action: @escaping () -> Void) -> CometChatMessageBubbleSwiftUI {
        var view = self
        view.onLongPress = action
        return view
    }
    
    public func set(style: MessageBubbleStyle, specificMessageTypeStyle: BaseMessageBubbleStyle? = nil) -> CometChatMessageBubbleSwiftUI {
        var view = self
        var newStyle = style
        
        if let specificStyle = specificMessageTypeStyle {
            if let avatarStyle = specificStyle.avatarStyle {
                newStyle.avatarStyle = avatarStyle
            }
            if let borderColor = specificStyle.borderColor {
                newStyle.borderColor = borderColor
            }
            if let borderWidth = specificStyle.borderWidth {
                newStyle.borderWidth = borderWidth
            }
            if let backgroundColor = specificStyle.backgroundColor {
                newStyle.backgroundColor = backgroundColor
            }
            if let cornerRadius = specificStyle.cornerRadius {
                newStyle.cornerRadius = cornerRadius
            }
        }
        
        view.style = newStyle
        return view
    }
}

extension CometChatMessageBubbleSwiftUI {
    public func set(headerView: some View) -> some View {
        VStack(alignment: alignment == .right ? .trailing : .leading, spacing: 0) {
            self
            headerView
                .padding(.bottom, CometChatSpacing.Padding.p1)
        }
    }
    
    public func set(contentView: some View) -> some View {
        overlay(
            contentView
                .padding(CometChatSpacing.Padding.p3),
            alignment: .center
        )
    }
    
    public func set(statusInfoView: some View) -> some View {
        overlay(
            statusInfoView,
            alignment: .bottomTrailing
        )
    }
    
    public func set(bottomView: some View) -> some View {
        VStack(alignment: alignment == .right ? .trailing : .leading, spacing: 0) {
            self
            bottomView
        }
    }
    
    public func set(footerView: some View) -> some View {
        VStack(alignment: alignment == .right ? .trailing : .leading, spacing: 0) {
            self
            footerView
        }
    }
    
    public func set(viewReply: some View) -> some View {
        VStack(alignment: alignment == .right ? .trailing : .leading, spacing: 0) {
            self
            viewReply
        }
    }
}

extension CometChatMessageBubbleSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatMessageBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatMessageBubbleSwiftUI()
                .set(bubbleAlignment: .right)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Right Alignment")
            
            CometChatMessageBubbleSwiftUI()
                .set(bubbleAlignment: .left)
                .set(avatarURL: nil, avatarName: "John Doe")
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Left Alignment with Avatar")
            
            CometChatMessageBubbleSwiftUI()
                .set(bubbleAlignment: .center)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Center Alignment")
        }
    }
}
