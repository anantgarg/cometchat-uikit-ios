//
//
//

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class GroupMembersViewModelSwiftUI: ObservableObject {
    @Published var groupMembers: [GroupMember] = []
    @Published var filteredGroupMembers: [GroupMember] = []
    @Published var selectedGroupMembers: [GroupMember] = []
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    @Published var errorMessage: String = ""
    
    public var group: Group!
    @Published var isSearching: Bool = false
    
    private var groupsMembersRequest: GroupMembersRequest?
    private var filterGroupMembersRequest: GroupMembersRequest?
    private var groupMembersRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder!
    private var filterGroupMembersRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder?
    private var listenerRandomID = Date().timeIntervalSince1970
    
    public var isFetchedAll = false
    
    var onError: ((CometChatException) -> Void)?
    
    public init() {}
    
    deinit {
        disconnect()
    }
    
    func connect() {
        CometChat.addGroupListener("group-members-groups-sdk-listner-\(listenerRandomID)", self as? CometChatGroupDelegate)
        CometChatGroupEvents.addListener("group-members-groups-event-listner-\(listenerRandomID)", self as? CometChatGroupEventListener)
    }
    
    func disconnect() {
        CometChat.removeGroupListener("group-members-groups-sdk-listner-\(listenerRandomID)")
        CometChatGroupEvents.removeListener("group-members-groups-event-listner-\(listenerRandomID)")
    }
    
    public func set(group: Group) {
        self.group = group
        if self.groupMembersRequestBuilder == nil {
            self.groupMembersRequestBuilder = GroupMembersBuilder.getSharedBuilder(for: group)
            self.groupsMembersRequest = groupMembersRequestBuilder.build()
        }
    }
    
    public func set(groupMembersRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder) {
        self.groupMembersRequestBuilder = groupMembersRequestBuilder
        self.groupsMembersRequest = self.groupMembersRequestBuilder.build()
    }
    
    public func set(searchGroupMembersRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder) {
        self.filterGroupMembersRequestBuilder = searchGroupMembersRequestBuilder
        self.filterGroupMembersRequest = self.filterGroupMembersRequestBuilder!.build()
    }
    
    public func fetchGroupsMembers() {
        guard let groupsMembersRequest = groupsMembersRequest else { return }
        
        isLoading = true
        
        GroupMembersBuilder.fetchGroupMembers(groupMemberRequest: groupsMembersRequest) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let fetchedGroupMembers):
                    if fetchedGroupMembers.isEmpty { 
                        self.isFetchedAll = true 
                    }
                    self.groupMembers.append(contentsOf: fetchedGroupMembers)
                    
                case .failure(let error):
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        }
    }
    
    public func filterGroupMembers(text: String) {
        self.filterGroupMembersRequest = (self.filterGroupMembersRequestBuilder ?? self.groupMembersRequestBuilder)?.set(searchKeyword: text).build()
        
        guard let filterGroupMembersRequest = filterGroupMembersRequest else { return }
        
        isLoading = true
        
        GroupMembersBuilder.getfilteredGroupMembers(filterGroupMemberRequest: filterGroupMembersRequest) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let filteredGroupMembers):
                    self.filteredGroupMembers = filteredGroupMembers
                case .failure(let error):
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        }
    }
    
    func changeScope(for member: GroupMember, scope: CometChat.MemberScope) {
        GroupMembersBuilder.changeScope(group: group, member: member, scope: scope) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let groupMember):
                    if let loggedInUser = CometChat.getLoggedInUser() {
                        let actionMessage = ActionMessage()
                        actionMessage.action = .scopeChanged
                        actionMessage.conversationId = "group_\(self.group.guid)"
                        actionMessage.message = "\(loggedInUser.name ?? "") made \(member.name ?? "") \(scope.toString())"
                        actionMessage.muid = "\(NSDate().timeIntervalSince1970)"
                        actionMessage.sender = loggedInUser
                        actionMessage.receiver = self.group
                        actionMessage.actionBy = loggedInUser
                        actionMessage.actionOn = member
                        actionMessage.receiverUid = self.group.guid
                        actionMessage.messageType = .groupMember
                        actionMessage.messageCategory = .action
                        actionMessage.receiverType = .group
                        actionMessage.newScope = groupMember.scope
                        actionMessage.sentAt = Int(Date().timeIntervalSince1970)
                        
                        CometChatGroupEvents.ccGroupMemberScopeChanged(action: actionMessage, updatedUser: groupMember, scopeChangedTo: scope.toString(), scopeChangedFrom: member.scope.toString(), group: self.group)
                    }
                    self.update(groupMember: groupMember)
                    
                case .failure(let error):
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        }
    }
    
    func banGroupMember(group: Group, member: GroupMember) {
        GroupMembersBuilder.banGroupMember(group: group, member: member) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let groupMember):
                    group.membersCount = group.membersCount - 1
                    self.remove(groupMember: groupMember)
                    
                    if let loggedInUser = LoggedInUserInformation.getUser() {
                        let actionMessage = ActionMessage()
                        actionMessage.action = .banned
                        actionMessage.conversationId = "group_\(self.group.guid)"
                        actionMessage.message = "\(loggedInUser.name ?? "") banned \(member.name ?? "")"
                        actionMessage.muid = "\(NSDate().timeIntervalSince1970)"
                        actionMessage.sender = loggedInUser
                        actionMessage.receiver = self.group
                        actionMessage.receiverUid = self.group.guid
                        actionMessage.messageType = .groupMember
                        actionMessage.actionBy = loggedInUser
                        actionMessage.actionOn = member
                        actionMessage.messageCategory = .action
                        actionMessage.receiverType = .group
                        actionMessage.sentAt = Int(Date().timeIntervalSince1970)
                        
                        CometChatGroupEvents.ccGroupMemberBanned(action: actionMessage, bannedUser: groupMember, bannedBy: loggedInUser, bannedFrom: group)
                    }
                    
                case .failure(let error):
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        }
    }
    
    func kickGroupMember(group: Group, member: GroupMember) {
        GroupMembersBuilder.kickGroupMember(group: group, member: member) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let groupMember):
                    group.membersCount = group.membersCount - 1
                    self.remove(groupMember: groupMember)
                    
                    if let loggedInUser = LoggedInUserInformation.getUser() {
                        let actionMessage = ActionMessage()
                        actionMessage.action = .kicked
                        actionMessage.conversationId = "group_\(self.group.guid)"
                        actionMessage.message = "\(loggedInUser.name ?? "") Kicked \(member.name ?? "")"
                        actionMessage.muid = "\(NSDate().timeIntervalSince1970)"
                        actionMessage.sender = loggedInUser
                        actionMessage.receiver = self.group
                        actionMessage.receiverUid = self.group.guid
                        actionMessage.messageType = .groupMember
                        actionMessage.messageCategory = .action
                        actionMessage.actionBy = loggedInUser
                        actionMessage.actionOn = member
                        actionMessage.receiverType = .group
                        actionMessage.sentAt = Int(Date().timeIntervalSince1970)
                        
                        CometChatGroupEvents.ccGroupMemberKicked(action: actionMessage, kickedUser: member, kickedBy: loggedInUser, kickedFrom: group)
                    }
                    
                case .failure(let error):
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        }
    }
    
    @discardableResult
    public func add(groupMember: GroupMember) -> Self {
        DispatchQueue.main.async {
            self.groupMembers.append(groupMember)
        }
        return self
    }
    
    @discardableResult
    public func update(groupMember: GroupMember) -> Self {
        if let row = self.groupMembers.firstIndex(where: {$0.uid == groupMember.uid}) {
            DispatchQueue.main.async {
                self.groupMembers[row] = groupMember
            }
        }
        return self
    }
    
    @discardableResult
    public func insert(groupMember: GroupMember, at: Int) -> Self {
        DispatchQueue.main.async {
            self.groupMembers.insert(groupMember, at: at)
        }
        return self
    }
    
    @discardableResult
    public func remove(groupMember: GroupMember) -> Self {
        if let index = groupMembers.firstIndex(of: groupMember) {
            DispatchQueue.main.async {
                self.groupMembers.remove(at: index)
            }
        }
        return self
    }
    
    @discardableResult
    public func clearList() -> Self {
        DispatchQueue.main.async {
            self.groupMembers.removeAll()
        }
        return self
    }
    
    public func size() -> Int {
        return self.groupMembers.count
    }
    
    func selectGroupMember(_ groupMember: GroupMember) {
        if !selectedGroupMembers.contains(where: { $0.uid == groupMember.uid }) {
            selectedGroupMembers.append(groupMember)
        }
    }
    
    func deselectGroupMember(_ groupMember: GroupMember) {
        if let index = selectedGroupMembers.firstIndex(where: { $0.uid == groupMember.uid }) {
            selectedGroupMembers.remove(at: index)
        }
    }
    
    func clearSelection() {
        selectedGroupMembers.removeAll()
    }
}
