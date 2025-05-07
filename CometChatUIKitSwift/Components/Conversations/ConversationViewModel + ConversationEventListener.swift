//
//  ConversationViewModel + ConversationEventListener.swift
//
//
//  Created by Abdullah Ansari on 03/02/23.
//

import CometChatSDK
import Foundation

extension ConversationsViewModel: CometChatConversationEventListener {
    func ccConversationDeleted(conversation _: Conversation) {}
}
