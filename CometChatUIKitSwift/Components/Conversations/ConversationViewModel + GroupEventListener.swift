//
//  ConversationViewModel + GroupEventListener.swift
//
//
//  Created by Abdullah Ansari on 03/02/23.
//

import CometChatSDK
import Foundation

extension ConversationsViewModel: CometChatGroupEventListener {
    func ccOwnershipChanged(group: Group, newOwner _: GroupMember) {
        update(group: group)
    }

    func ccGroupLeft(action _: ActionMessage, leftUser _: User, leftGroup: Group) {
        removerConversation(for: leftGroup)
    }

    func ccGroupDeleted(group: Group) {
        removerConversation(for: group)
    }

    func ccGroupMemberAdded(messages: [ActionMessage], usersAdded _: [User], groupAddedIn: Group, addedBy _: User) {
        if checkForConversationUpdate() {
            if let lastActionMessage = messages.last {
                update(group: groupAddedIn)
                update(lastMessage: lastActionMessage, updateCount: false)
            }
        }
    }

    func ccGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy _: User, kickedFrom: Group) {
        if checkForConversationUpdate(action: action) {
            if CometChat.getLoggedInUser()?.uid == kickedUser.uid {
                removerConversation(for: kickedFrom)
            } else {
                newMessageReceived?(action)
                update(lastMessage: action, updateCount: false)
            }
        }
    }

    func ccGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy _: User, bannedFrom: Group) {
        if checkForConversationUpdate(action: action) {
            if CometChat.getLoggedInUser()?.uid == bannedUser.uid {
                removerConversation(for: bannedFrom)
            } else {
                newMessageReceived?(action)
                update(lastMessage: action, updateCount: false)
            }
        }
    }

    func ccGroupMemberScopeChanged(action: ActionMessage, updatedUser _: User, scopeChangedTo _: String, scopeChangedFrom _: String, group _: Group) {
        if checkForConversationUpdate(action: action) {
            update(lastMessage: action, updateCount: false)
        }
    }

    func ccGroupCreated(group: Group) {
        /// creating new group's conversation object
        let newGroupConversation = Conversation()
        newGroupConversation.updatedAt = Date().timeIntervalSince1970
        newGroupConversation.conversationWith = group
        newGroupConversation.conversationType = .group
        newGroupConversation.conversationId = "group_\(group.guid)"

        update(conversation: newGroupConversation)
    }
}

extension ConversationsViewModel: CometChatGroupDelegate {
    func onGroupMemberJoined(action: ActionMessage, joinedUser _: User, joinedGroup _: Group) {
        if checkForConversationUpdate(action: action) {
            newMessageReceived?(action)
            update(lastMessage: action, updateCount: false)
        }
    }

    func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if checkForConversationUpdate(action: action) {
            if CometChat.getLoggedInUser()?.uid == leftUser.uid {
                removerConversation(for: leftGroup)
            } else {
                update(lastMessage: action, updateCount: false)
            }
        }
    }

    func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy _: User, kickedFrom: Group) {
        if checkForConversationUpdate(action: action) {
            if CometChat.getLoggedInUser()?.uid == kickedUser.uid {
                removerConversation(for: kickedFrom)
            } else {
                newMessageReceived?(action)
                update(lastMessage: action, updateCount: false)
            }
        }
    }

    func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy _: User, bannedFrom: Group) {
        if checkForConversationUpdate(action: action) {
            if CometChat.getLoggedInUser()?.uid == bannedUser.uid {
                removerConversation(for: bannedFrom)
            } else {
                newMessageReceived?(action)
                update(lastMessage: action, updateCount: false)
            }
        }
    }

    func onGroupMemberUnbanned(action: ActionMessage, unbannedUser _: User, unbannedBy _: User, unbannedFrom _: Group) {
        if checkForConversationUpdate(action: action) {
            newMessageReceived?(action)
            update(lastMessage: action, updateCount: false)
        }
    }

    func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy _: User, scopeChangedTo: String, scopeChangedFrom _: String, group: Group) {
        /*
         update group object
         appned last message.
         */
        if checkForConversationUpdate(action: action) {
            newMessageReceived?(action)

            // THIS NEED TO BE FIXED FROM THE BACKEND
            if scopeChangeduser.uid == CometChat.getLoggedInUser()?.uid {
                group.scope = CometChat.GroupMemberScopeType.from(string: scopeChangedTo) ?? group.scope
                action.receiver = group
            }

            update(lastMessage: action, updateCount: false)
        }
    }

    func onMemberAddedToGroup(action: ActionMessage, addedBy _: User, addedUser _: User, addedTo _: Group) {
        newMessageReceived?(action)
        /*

         - updateGroup(group)
         - Append to last message.

         */
        if checkForConversationUpdate(action: action) {
            newMessageReceived?(action)
            update(lastMessage: action, updateCount: false)
        }
    }
}
