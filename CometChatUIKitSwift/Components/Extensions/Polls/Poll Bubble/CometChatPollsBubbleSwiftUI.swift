//
//
//

import SwiftUI
import CometChatSDK
import CometChatUIKitSwift.Components.Shared.Constants

public struct CometChatPollsBubbleSwiftUI: View {
    
    @State private var style: PollBubbleStyle = PollBubbleStyle()
    @State private var message: CustomMessage?
    @State private var controller: UIViewController?
    @State private var pollsData: PollsData = PollsData()
    @State private var optionCheckIconName: String = "checkmark.circle.fill"
    @State private var optionUncheckIconName: String = "circle"
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: LayoutMetrics.spacingSmall) {
            Text(pollsData.question)
                .font(.body)
                .foregroundColor(Color(style.pollTextColor))
                .multilineTextAlignment(.leading)
                .padding(.horizontal, LayoutMetrics.spacingMedium)
                .padding(.top, LayoutMetrics.spacingMedium)
            
            VStack(alignment: .leading, spacing: LayoutMetrics.spacingMedium) {
                ForEach(pollsData.options, id: \.id) { option in
                    PollsOptionViewSwiftUI(pollOption: option, total: pollsData.total)
                        .set(style: style)
                        .set(optionCheckIconName: optionCheckIconName)
                        .set(optionUncheckIconName: optionUncheckIconName)
                        .set(onClicked: { pollOption in
                            onSelected(pollOptions: pollOption)
                        })
                }
            }
            .padding(.horizontal, LayoutMetrics.spacingMedium)
            .padding(.bottom, LayoutMetrics.spacingMedium)
        }
        .frame(maxWidth: LayoutMetrics.loadingContentWidth + LayoutMetrics.spacingExtraLarge)
        .background(Color(style.backgroundColor ?? .clear))
        .cornerRadius(style.cornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusMedium)
                .stroke(Color(style.borderColor ?? .clear), lineWidth: style.borderWidth ?? 0)
        )
    }
    
    @discardableResult
    public func set(pollMessage: CustomMessage) -> Self {
        var view = self
        view.message = pollMessage
        view.pollsData = PollUtils().parsePolls(forMessage: pollMessage)
        return view
    }
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        var view = self
        view.controller = controller
        return view
    }
    
    @discardableResult
    public func set(style: PollBubbleStyle) -> Self {
        var view = self
        view.style = style
        return view
    }
    
    @discardableResult
    public func set(optionCheckIcon: UIImage?) -> Self {
        var view = self
        view._optionCheckIconName = State(initialValue: "checkmark.circle.fill")
        return view
    }
    
    @discardableResult
    public func set(optionUncheckIcon: UIImage?) -> Self {
        var view = self
        view._optionUncheckIconName = State(initialValue: "circle")
        return view
    }
    
    private func onSelected(pollOptions: PollOptions) {
        let body = [
            "vote": pollOptions.index,
            "id": pollsData.id,
        ]
        
        CometChat.callExtension(slug: "polls", type: .post, endPoint: "v2/vote", body: body as [String : Any]) { extensionResponseData in
            print("Success")
        } onError: { error in
            print("Error")
        }
    }
    
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatPollsBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            let pollData = createMockPollData(isOutgoing: false)
            CometChatPollsBubbleSwiftUI()
                .set(pollMessage: pollData)
                .set(style: PollBubbleStyle(styleType: .incoming))
                .padding()
                .previewDisplayName("Incoming Poll (Light)")
            
            let outgoingPollData = createMockPollData(isOutgoing: true)
            CometChatPollsBubbleSwiftUI()
                .set(pollMessage: outgoingPollData)
                .set(style: PollBubbleStyle(styleType: .outgoing))
                .padding()
                .previewDisplayName("Outgoing Poll (Light)")
                
            CometChatPollsBubbleSwiftUI()
                .set(pollMessage: pollData)
                .set(style: PollBubbleStyle(styleType: .incoming))
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Incoming Poll (Dark)")
        }
    }
    
    static func createMockPollData(isOutgoing: Bool) -> CustomMessage {
        let sender = User(uid: isOutgoing ? "user1" : "user2", name: isOutgoing ? "You" : "John Doe")
        
        let customMessage = CustomMessage(receiverUid: isOutgoing ? "user2" : "user1", messageType: MessageTypeConstants.poll, receiverType: .user)
        customMessage.sender = sender
        customMessage.senderUid = sender.uid
        
        let pollData: [String: Any] = [
            "id": "poll123",
            "question": "What's your favorite programming language?",
            "options": [
                ["id": "opt1", "text": "Swift", "count": 5, "voters": [["name": "User 1", "id": "user1", "avatar": ""]]],
                ["id": "opt2", "text": "Objective-C", "count": 2, "voters": [["name": "User 2", "id": "user2", "avatar": ""]]],
                ["id": "opt3", "text": "Python", "count": 3, "voters": [["name": "User 3", "id": "user3", "avatar": ""]]],
                ["id": "opt4", "text": "JavaScript", "count": 1, "voters": [["name": "User 4", "id": "user4", "avatar": ""]]]
            ],
            "results": [
                ["id": "opt1", "count": 5, "voters": [["name": "User 1", "id": "user1", "avatar": ""]]],
                ["id": "opt2", "count": 2, "voters": [["name": "User 2", "id": "user2", "avatar": ""]]],
                ["id": "opt3", "count": 3, "voters": [["name": "User 3", "id": "user3", "avatar": ""]]],
                ["id": "opt4", "count": 1, "voters": [["name": "User 4", "id": "user4", "avatar": ""]]]
            ]
        ]
        
        customMessage.metaData = ["@injected": ["extensions": ["polls": pollData]]]
        
        return customMessage
    }
}
