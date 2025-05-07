//
//
//
//

import SwiftUI
import CometChatSDK
import CometChatUIKitSwift

struct AddMembersSwiftUI: View {
    @StateObject private var addMembersViewModel: AddMembersViewModel
    @State private var selectedUsers: [User] = []
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Environment(\.dismiss) private var dismiss
    
    private let tryAgainText = "TRY_AGAIN".localize()
    private let cancelText = "CANCEL".localize()
    private let addMembersText = "ADD_MEMBERS".localize()
    
    public init(group: Group, userRequestBuilder: UsersRequest.UsersRequestBuilder? = nil) {
        let viewModel = AddMembersViewModel(group: group)
        _addMembersViewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(cancelText) {
                    dismiss()
                }
                .foregroundColor(Color(CometChatTheme.primaryColor))
                
                Spacer()
                
                Text(addMembersText)
                    .font(Font(CometChatTypography.Heading3.bold))
                    .foregroundColor(Color(CometChatTheme.textColorPrimary))
                
                Spacer()
                
                Button("") {}.opacity(0)
            }
            .padding()
            
            CometChatUsersSwiftUI()
                .set(selectionMode: .multiple)
                .set(onSelection: { users in
                    selectedUsers = users
                })
            
            if !selectedUsers.isEmpty {
                VStack(spacing: 0) {
                    Divider()
                        .background(Color(CometChatTheme.borderColorLight))
                    
                    Button(action: {
                        addMembers()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("ADD \(selectedUsers.count) MEMBERS")
                                .font(Font(CometChatTypography.Button.medium))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .background(Color(CometChatTheme.primaryColor))
                    .cornerRadius(8)
                    .padding()
                }
                .background(Color(CometChatTheme.backgroundColor01))
                .transition(.move(edge: .bottom))
            }
        }
        .alert("ERROR", isPresented: $showAlert) {
            Button("OK") {
                showAlert = false
            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            setupObservers()
        }
    }
    
    private func setupObservers() {
        addMembersViewModel.isMembersAdded = { actionMessages, members, group, loggedInUser in
            isLoading = false
            dismiss()
            CometChatGroupEvents.ccGroupMemberAdded(messages: actionMessages, usersAdded: members, groupAddedIn: group, addedBy: loggedInUser)
        }
        
        addMembersViewModel.unableToAddMember = { error in
            isLoading = false
            alertMessage = error
            showAlert = true
        }
        
        addMembersViewModel.failure = { _ in
            isLoading = false
        }
    }
    
    private func addMembers() {
        isLoading = true
        
        var groupMembers: [GroupMember] = []
        
        selectedUsers.forEach {
            if let uid = $0.uid {
                var member = GroupMember(UID: uid, groupMemberScope: .participant)
                member.name = $0.name ?? ""
                groupMembers.append(member)
            }
        }
        
        addMembersViewModel.addMembers(members: groupMembers)
    }
    
    public func toUIKit() -> UIViewController {
        let hostingController = UIHostingController(rootView: self)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }
}

struct AddMembersSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        let group = Group(guid: "testGroup", name: "Test Group", groupType: .public)
        AddMembersSwiftUI(group: group)
    }
}
