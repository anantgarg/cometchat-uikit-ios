//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatGroupActionBubbleSwiftUI: View {
    
    
    private var style: GroupActionBubbleStyle
    
    @State private var messageText: String = ""
    
    
    public init(style: GroupActionBubbleStyle = GroupActionBubbleStyle()) {
        self.style = style
    }
    
    
    public var body: some View {
        Text(messageText)
            .font(Font(style.bubbleTextFont))
            .foregroundColor(Color(style.bubbleTextColor))
            .padding(.horizontal, CometChatSpacing.Padding.p3)
            .padding(.vertical, CometChatSpacing.Padding.p1)
            .frame(height: 22)
            .background(
                style.backgroundDrawable != nil ?
                    Image(uiImage: style.backgroundDrawable!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    : Color(style.backgroundColor)
            )
            .cornerRadius(style.cornerRadius?.cornerRadius ?? 0)
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? 0)
                    .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
            )
            .multilineTextAlignment(.center)
    }
    
    
    public func set(messageObject: BaseMessage) -> CometChatGroupActionBubbleSwiftUI {
        var view = self
        
        if let actionMessage = messageObject as? ActionMessage {
            if let action = actionMessage.action {
                switch action {
                case .joined:
                    if let user = (actionMessage.actionBy as? User)?.name {
                        view._messageText = State(initialValue: user + " " + "JOINED".localize())
                    }
                case .left:
                    if let user = (actionMessage.actionBy as? User)?.name {
                        view._messageText = State(initialValue: user + " " + "LEFT".localize())
                    }
                case .kicked:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,
                       let actionOn = (actionMessage.actionOn as? User)?.name {
                        view._messageText = State(initialValue: actionBy + " " + "KICKED".localize() + " " + actionOn)
                    }
                case .banned:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,
                       let actionOn = (actionMessage.actionOn as? User)?.name {
                        view._messageText = State(initialValue: actionBy + " " + "BANNED".localize() + " " + actionOn)
                    }
                case .unbanned:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,
                       let actionOn = (actionMessage.actionOn as? User)?.name {
                        view._messageText = State(initialValue: actionBy + " " + "UNBANNED".localize() + " " + actionOn)
                    }
                case .scopeChanged:
                    view = handleScopeChanged(view: view, actionMessage: actionMessage)
                case .messageEdited, .messageDeleted:
                    view._messageText = State(initialValue: actionMessage.message)
                case .added:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,
                       let actionOn = (actionMessage.actionOn as? User)?.name {
                        view._messageText = State(initialValue: actionBy + " " + "ADDED".localize() + " " + actionOn)
                    }
                @unknown default:
                    view._messageText = State(initialValue: "ACTION_MESSAGE".localize())
                }
            }
        }
        return view
    }
    
    
    private func handleScopeChanged(view: CometChatGroupActionBubbleSwiftUI, actionMessage: ActionMessage) -> CometChatGroupActionBubbleSwiftUI {
        var updatedView = view
        
        if let actionBy = (actionMessage.actionBy as? User)?.name,
           let actionOn = (actionMessage.actionOn as? User)?.name {
            switch actionMessage.newScope {
            case .admin:
                let admin = "ADMIN".localize()
                updatedView._messageText = State(initialValue: actionBy + " " + "MADE".localize() + " \(actionOn) \(admin)")
            case .moderator:
                let moderator = "MODERATOR".localize()
                updatedView._messageText = State(initialValue: actionBy + " " + "MADE".localize() + " \(actionOn) \(moderator)")
            case .participant:
                let participant = "PARTICIPANT".localize()
                updatedView._messageText = State(initialValue: actionBy + " " + "MADE".localize() + " \(actionOn) \(participant)")
            @unknown default:
                break
            }
        }
        
        return updatedView
    }
}

extension CometChatGroupActionBubbleSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatGroupActionBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                let joinedMessage = createMockActionMessage(action: .joined)
                CometChatGroupActionBubbleSwiftUI()
                    .set(messageObject: joinedMessage)
                    .previewDisplayName("User Joined")
                
                let leftMessage = createMockActionMessage(action: .left)
                CometChatGroupActionBubbleSwiftUI()
                    .set(messageObject: leftMessage)
                    .previewDisplayName("User Left")
                
                let kickedMessage = createMockActionMessage(action: .kicked)
                CometChatGroupActionBubbleSwiftUI()
                    .set(messageObject: kickedMessage)
                    .previewDisplayName("User Kicked")
                
                let scopeChangedMessage = createMockActionMessage(action: .scopeChanged, newScope: .admin)
                CometChatGroupActionBubbleSwiftUI()
                    .set(messageObject: scopeChangedMessage)
                    .previewDisplayName("Scope Changed")
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            
            VStack(spacing: 20) {
                let joinedMessage = createMockActionMessage(action: .joined)
                CometChatGroupActionBubbleSwiftUI()
                    .set(messageObject: joinedMessage)
                
                let leftMessage = createMockActionMessage(action: .left)
                CometChatGroupActionBubbleSwiftUI()
                    .set(messageObject: leftMessage)
                
                let kickedMessage = createMockActionMessage(action: .kicked)
                CometChatGroupActionBubbleSwiftUI()
                    .set(messageObject: kickedMessage)
                
                let scopeChangedMessage = createMockActionMessage(action: .scopeChanged, newScope: .admin)
                CometChatGroupActionBubbleSwiftUI()
                    .set(messageObject: scopeChangedMessage)
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        }
    }
    
    private static func createMockActionMessage(action: CometChatSDK.ActionMessage.Action, newScope: CometChatSDK.GroupMemberScope = .participant) -> CometChatSDK.ActionMessage {
        let actionMessage = ActionMessage()
        actionMessage.action = action
        
        let actionByUser = User(uid: "user1", name: "John Doe")
        let actionOnUser = User(uid: "user2", name: "Jane Smith")
        
        actionMessage.actionBy = actionByUser
        actionMessage.actionOn = actionOnUser
        actionMessage.newScope = newScope
        
        return actionMessage
    }
}
