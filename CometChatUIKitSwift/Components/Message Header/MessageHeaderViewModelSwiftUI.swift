//
//
//

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class MessageHeaderViewModelSwiftUI: ObservableObject {
    @Published var user: User?
    @Published var group: Group?
    @Published var name: String?
    @Published var isOnline: Bool = false
    @Published var isTyping: Bool = false
    @Published var typingUser: User?
    @Published var hasError: Bool = false
    @Published var errorMessage: String = ""
    
    public var listenerRandomId = Date().timeIntervalSince1970
    
    var onUpdateGroupCount: ((Group) -> Void)?
    var onUpdateTypingStatus: ((User?, Bool) -> Void)?
    var onUpdateUserStatus: ((Bool) -> Void)?
    var onHideUserStatus: (() -> Void)?
    var onUnHideUserStatus: (() -> Void)?
    var onError: ((CometChatException) -> Void)?
    
    public init() {}
    
    deinit {
        disconnect()
    }
    
    public func set(user: User) {
        DispatchQueue.main.async {
            self.user = user
            self.isOnline = user.status == .online
        }
    }
    
    public func set(group: Group) {
        DispatchQueue.main.async {
            self.group = group
        }
    }
    
    public func connect() {
        CometChat.addUserListener("messages-header-user-listener-\(listenerRandomId)", self as? CometChatUserDelegate)
        CometChatMessageEvents.addListener("messages-header-message-listener-\(listenerRandomId)", self as? CometChatMessageEventListener)
        CometChat.addGroupListener("messages-header-groups-sdk-listener-\(listenerRandomId)", self as? CometChatGroupDelegate)
        CometChatGroupEvents.addListener("messages-header-group-event-listener-\(listenerRandomId)", self as? CometChatGroupEventListener)
        CometChatUserEvents.addListener("messages-header-user-event-listener-\(listenerRandomId)", self as? CometChatUserEventListener)
    }
    
    public func disconnect() {
        CometChat.removeUserListener("messages-header-user-listener-\(listenerRandomId)")
        CometChatMessageEvents.removeListener("messages-header-message-listener-\(listenerRandomId)")
        CometChat.removeGroupListener("messages-header-groups-sdk-listener-\(listenerRandomId)")
        CometChatGroupEvents.removeListener("messages-header-group-event-listener-\(listenerRandomId)")
        CometChatUserEvents.removeListener("messages-header-user-event-listener-\(listenerRandomId)")
    }
    
    public func checkBlockedStatus() -> Bool {
        var status = false
        if let user = user {
            status = user.hasBlockedMe || user.blockedByMe
        }
        return status
    }
    
    public func updateUserStatus(_ isOnline: Bool) {
        DispatchQueue.main.async {
            self.isOnline = isOnline
            if let user = self.user {
                self.user?.status = isOnline ? .online : .offline
            }
            self.onUpdateUserStatus?(isOnline)
        }
    }
    
    public func updateTypingStatus(user: User?, isTyping: Bool) {
        DispatchQueue.main.async {
            self.isTyping = isTyping
            self.typingUser = user
            self.onUpdateTypingStatus?(user, isTyping)
        }
    }
    
    public func updateGroupCount(_ group: Group) {
        DispatchQueue.main.async {
            self.group = group
            self.onUpdateGroupCount?(group)
        }
    }
    
    public func hideUserStatus() {
        DispatchQueue.main.async {
            self.onHideUserStatus?()
        }
    }
    
    public func unHideUserStatus() {
        DispatchQueue.main.async {
            self.onUnHideUserStatus?()
        }
    }
}

extension MessageHeaderViewModelSwiftUI: CometChatUserDelegate {
    public func onUserOnline(user: User) {
        if self.user?.uid == user.uid {
            updateUserStatus(true)
        }
    }
    
    public func onUserOffline(user: User) {
        if self.user?.uid == user.uid {
            updateUserStatus(false)
        }
    }
}

extension MessageHeaderViewModelSwiftUI: CometChatMessageEventListener {
    public func onTypingStarted(_ typingDetails: TypingIndicator) {
        if let user = self.user, typingDetails.sender?.uid == user.uid {
            updateTypingStatus(user: typingDetails.sender, isTyping: true)
        } else if let group = self.group, typingDetails.receiverID == group.guid {
            updateTypingStatus(user: typingDetails.sender, isTyping: true)
        }
    }
    
    public func onTypingEnded(_ typingDetails: TypingIndicator) {
        if let user = self.user, typingDetails.sender?.uid == user.uid {
            updateTypingStatus(user: typingDetails.sender, isTyping: false)
        } else if let group = self.group, typingDetails.receiverID == group.guid {
            updateTypingStatus(user: typingDetails.sender, isTyping: false)
        }
    }
}

extension MessageHeaderViewModelSwiftUI: CometChatGroupDelegate {
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        if group?.guid == joinedGroup.guid {
            updateGroupCount(joinedGroup)
        }
    }
    
    public func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if group?.guid == leftGroup.guid {
            updateGroupCount(leftGroup)
        }
    }
    
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if group?.guid == kickedFrom.guid {
            updateGroupCount(kickedFrom)
        }
    }
    
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if group?.guid == bannedFrom.guid {
            updateGroupCount(bannedFrom)
        }
    }
    
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if group?.guid == unbannedFrom.guid {
            updateGroupCount(unbannedFrom)
        }
    }
    
    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if self.group?.guid == group.guid {
            updateGroupCount(group)
        }
    }
    
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        if self.group?.guid == addedTo.guid {
            updateGroupCount(addedTo)
        }
    }
}

extension MessageHeaderViewModelSwiftUI: CometChatGroupEventListener {
    public func ccGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        if group?.guid == joinedGroup.guid {
            updateGroupCount(joinedGroup)
        }
    }
    
    public func ccGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if group?.guid == leftGroup.guid {
            updateGroupCount(leftGroup)
        }
    }
    
    public func ccGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if group?.guid == kickedFrom.guid {
            updateGroupCount(kickedFrom)
        }
    }
    
    public func ccGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if group?.guid == bannedFrom.guid {
            updateGroupCount(bannedFrom)
        }
    }
    
    public func ccGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if group?.guid == unbannedFrom.guid {
            updateGroupCount(unbannedFrom)
        }
    }
    
    public func ccGroupMemberScopeChanged(action: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if self.group?.guid == group.guid {
            updateGroupCount(group)
        }
    }
    
    public func ccGroupMemberAdded(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        if self.group?.guid == addedTo.guid {
            updateGroupCount(addedTo)
        }
    }
}

extension MessageHeaderViewModelSwiftUI: CometChatUserEventListener {
    public func ccUserBlocked(user: User) {
        if self.user?.uid == user.uid {
            DispatchQueue.main.async {
                self.user = user
            }
        }
    }
    
    public func ccUserUnblocked(user: User) {
        if self.user?.uid == user.uid {
            DispatchQueue.main.async {
                self.user = user
            }
        }
    }
}

extension MessageHeaderViewModelSwiftUI: CometChatConnectionDelegate {
    public func connected() {
        if let group = group {
            CometChat.getGroup(GUID: group.guid) { [weak self] group in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.group = group
                    self.updateTypingStatus(user: nil, isTyping: false)
                }
            } onError: { [weak self] error in
                guard let self = self, let error = error else { return }
                DispatchQueue.main.async {
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        } else if let user = user {
            CometChat.getUser(UID: user.uid) { [weak self] user in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.user = user
                    self.updateUserStatus(user.status == .online)
                }
            } onError: { [weak self] error in
                guard let self = self, let error = error else { return }
                DispatchQueue.main.async {
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        }
    }
    
    public func connecting() {}
    
    public func disconnected() {}
}
