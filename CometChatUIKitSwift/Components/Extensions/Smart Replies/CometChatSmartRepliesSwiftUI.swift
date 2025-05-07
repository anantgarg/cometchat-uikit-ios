//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatSmartRepliesSwiftUI: View {
    
    @State private var titles: [String] = []
    @State private var style: SmartRepliesStyle = SmartRepliesStyle()
    @State private var user: User?
    @State private var group: Group?
    @State private var onReplySelectedCallback: ((String) -> Void)?
    
    public init() {}
    
    public init(titles: [String]) {
        self._titles = State(initialValue: titles)
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(titles, id: \.self) { title in
                    if !title.isEmpty {
                        Button(action: {
                            onReplySelectedCallback?(title)
                        }) {
                            Text(title)
                                .font(Font(style.textFont))
                                .foregroundColor(Color(style.textColor))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(style.textBackground))
                                .clipShape(RoundedRectangle(cornerRadius: style.borderRadius.cornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: style.borderRadius.cornerRadius)
                                        .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
                                )
                                .shadow(color: Color(style.shadowColor).opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                    } else {
                        Button(action: {
                            onReplySelectedCallback?("")
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(style.textColor))
                                .padding(8)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .background(Color(style.background))
        .cornerRadius(style.cornerRadius.cornerRadius)
    }
    
    @discardableResult
    public func set(titles: [String]) -> Self {
        var view = self
        view._titles = State(initialValue: titles)
        return view
    }
    
    @discardableResult
    public func set(user: User) -> Self {
        var view = self
        view._user = State(initialValue: user)
        return view
    }
    
    @discardableResult
    public func set(group: Group) -> Self {
        var view = self
        view._group = State(initialValue: group)
        return view
    }
    
    @discardableResult
    public func set(message: BaseMessage) -> Self {
        var view = self
        
        var replies: [String] = []
        if message.sender?.uid != CometChat.getLoggedInUser()?.uid {
            if let metaData = message.metaData,
               let injected = metaData["@injected"] as? [String: Any],
               let cometChatExtension = injected[ExtensionConstants.extensions] as? [String: Any],
               let smartReply = cometChatExtension[ExtensionConstants.smartReply] as? [String: Any] {
                
                if let positive = smartReply["reply_positive"] as? String {
                    replies.append(positive)
                }
                if let neutral = smartReply["reply_neutral"] as? String {
                    replies.append(neutral)
                }
                if let negative = smartReply["reply_negative"] as? String {
                    replies.append(negative)
                }
                
                if !replies.isEmpty {
                    replies.append("")
                }
            }
        }
        
        view._titles = State(initialValue: replies)
        return view
    }
    
    @discardableResult
    public func set(style: SmartRepliesStyle) -> Self {
        var view = self
        view._style = State(initialValue: style)
        return view
    }
    
    @discardableResult
    public func onReplySelected(_ callback: @escaping (String) -> Void) -> Self {
        var view = self
        view._onReplySelectedCallback = State(initialValue: callback)
        return view
    }
    
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        let view = hostingController.view
        view?.translatesAutoresizingMaskIntoConstraints = false
        return view ?? UIView()
    }
}

struct CometChatSmartRepliesSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatSmartRepliesSwiftUI()
                .set(titles: ["Thanks!", "I'll check it out", "Not interested", ""])
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Default Smart Replies")
            
            CometChatSmartRepliesSwiftUI()
                .set(titles: ["Yes, I agree", "Maybe later", "No, thanks", ""])
                .set(style: SmartRepliesStyle().set(textColor: .blue).set(textBackground: .yellow))
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Custom Style Smart Replies")
        }
    }
}
