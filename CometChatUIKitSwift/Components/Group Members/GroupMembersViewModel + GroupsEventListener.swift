//
//  GroupMembersViewModel + GroupsEventListener.swift
//
//
//  Created by Abdullah Ansari on 05/02/23.
//

import CometChatSDK
import Foundation

extension GroupMembersViewModel: CometChatGroupEventListener {
    public func ccOwnershipChanged(group: Group, newOwner: GroupMember) {
        if group.guid == self.group.guid {
            update(groupMember: newOwner)
        }
    }

    public func ccGroupMemberAdded(messages _: [ActionMessage], usersAdded: [User], groupAddedIn: Group, addedBy _: User) {
        if groupAddedIn.guid == group.guid {
            for member in usersAdded {
                if let groupMember = member as? GroupMember {
                    add(groupMember: groupMember)
                }
            }
        }
    }

    public func ccGroupMemberJoined(joinedUser: User, joinedGroup: Group) {
        if joinedGroup.guid == group.guid {
            if let groupMember = joinedUser as? GroupMember {
                add(groupMember: groupMember)
            }
        }
    }

    public func ccGroupMemberScopeChanged(action _: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom _: String, group: Group) {
        if group.guid == self.group.guid {
            let groupMember = updatedUser.toGroupMember(scope: CometChat.GroupMemberScopeType.from(string: scopeChangedTo) ?? .participant)
            update(groupMember: groupMember)

            if updatedUser.uid == CometChat.getLoggedInUser()?.uid {
                self.group.scope = CometChat.GroupMemberScopeType.from(string: scopeChangedTo) ?? group.scope // updating group scope
                reload?()
            }
        }
    }
}

extension GroupMembersViewModel: CometChatGroupDelegate {
    public func onGroupMemberJoined(action _: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        if joinedGroup.guid == group.guid {
            let groupMember = joinedUser.toGroupMember()
            add(groupMember: groupMember)
        }
    }

    public func onGroupMemberLeft(action _: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        if leftGroup.guid == group.guid {
            let groupMember = leftUser.toGroupMember()
            remove(groupMember: groupMember)
        }
    }

    public func onGroupMemberKicked(action _: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy _: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        if kickedFrom.guid == group.guid {
            let groupMember = kickedUser.toGroupMember()
            remove(groupMember: groupMember)
        }
    }

    public func onGroupMemberBanned(action _: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy _: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        if bannedFrom.guid == group.guid {
            let groupMember = bannedUser.toGroupMember()
            remove(groupMember: groupMember)
        }
    }

    public func onGroupMemberScopeChanged(action _: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy _: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom _: String, group: CometChatSDK.Group) {
        if group.guid == self.group.guid {
            let groupMember = scopeChangeduser.toGroupMember(scope: CometChat.GroupMemberScopeType.from(string: scopeChangedTo) ?? .participant)
            update(groupMember: groupMember)

            if scopeChangeduser.uid == CometChat.getLoggedInUser()?.uid {
                self.group.scope = CometChat.GroupMemberScopeType.from(string: scopeChangedTo) ?? group.scope // updating group scope
                reload?()
            }
        }
    }

    public func onMemberAddedToGroup(action _: CometChatSDK.ActionMessage, addedBy _: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        if addedTo.guid == group.guid {
            let groupMember = addedUser.toGroupMember(scope: .participant)
            add(groupMember: groupMember)
        }
    }
}
