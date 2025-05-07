//
//  GroupsViewModel + GroupsEventListener.swift
//
//
//  Created by Abdullah Ansari on 03/02/23.
//

import CometChatSDK
import Foundation

extension GroupsViewModel: CometChatGroupDelegate {
    public func onGroupMemberJoined(action _: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        if joinedGroup.groupType == .private {
            if joinedUser.uid == CometChat.getLoggedInUser()?.uid {
                insert(group: joinedGroup, at: 0)
            }
        } else {
            update(group: joinedGroup)
        }
    }

    public func onGroupMemberLeft(action _: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        if leftGroup.groupType == .private {
            if leftUser.uid == CometChat.getLoggedInUser()?.uid {
                remove(group: leftGroup)
            }
        } else {
            update(group: leftGroup)
        }
    }

    public func onGroupMemberKicked(action _: CometChatSDK.ActionMessage, kickedUser _: CometChatSDK.User, kickedBy _: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        update(group: kickedFrom)
    }

    public func onGroupMemberBanned(action _: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy _: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        if bannedUser.uid == CometChat.getLoggedInUser()?.uid {
            remove(group: bannedFrom)
        } else {
            update(group: bannedFrom)
        }
    }

    public func onGroupMemberUnbanned(action _: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy _: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        if unbannedUser.uid == CometChat.getLoggedInUser()?.uid {
            add(group: unbannedFrom)
        } else {
            update(group: unbannedFrom)
        }
    }

    public func onGroupMemberScopeChanged(action _: CometChatSDK.ActionMessage, scopeChangeduser _: CometChatSDK.User, scopeChangedBy _: CometChatSDK.User, scopeChangedTo _: String, scopeChangedFrom _: String, group: CometChatSDK.Group) {
        update(group: group)
    }

    public func onMemberAddedToGroup(action _: CometChatSDK.ActionMessage, addedBy _: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        if addedTo.groupType == .private {
            if addedUser == CometChat.getLoggedInUser() {
                insert(group: addedTo, at: 0)
            }
        } else {
            update(group: addedTo)
        }
    }
}

// Local Group Event Listener
extension GroupsViewModel: CometChatGroupEventListener {
    public func ccGroupCreated(group: Group) {
        insert(group: group, at: 0)
    }

    public func ccGroupDeleted(group: Group) {
        remove(group: group)
    }

    public func ccGroupMemberJoined(joinedUser _: User, joinedGroup: Group) {
        update(group: joinedGroup)
    }

    public func onGroupMemberLeave(leftUser _: User, leftGroup: Group) {
        if leftGroup.groupType == .private {
            remove(group: leftGroup)
        } else {
            leftGroup.hasJoined = false
            update(group: leftGroup)
        }
    }

    public func ccOwnershipChanged(group: Group, newOwner _: GroupMember) {
        update(group: group)
    }

    public func ccGroupLeft(action _: ActionMessage, leftUser _: User, leftGroup: Group) {
        update(group: leftGroup)
    }

    public func ccGroupMemberBanned(action _: ActionMessage, bannedUser _: User, bannedBy _: User, bannedFrom: Group) {
        update(group: bannedFrom)
    }

    public func ccGroupMemberKicked(action _: ActionMessage, kickedUser _: User, kickedBy _: User, kickedFrom: Group) {
        update(group: kickedFrom)
    }
}
