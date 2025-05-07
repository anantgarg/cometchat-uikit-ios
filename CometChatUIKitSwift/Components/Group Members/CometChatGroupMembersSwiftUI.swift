//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatGroupMembersSwiftUI: View {
    public static var style = GroupMembersStyle()
    public static var avatarStyle: AvatarStyle = CometChatAvatar.style
    public static var statusIndicatorStyle: StatusIndicatorStyle = {
        var statusIndicatorStyle = CometChatStatusIndicator.style
        statusIndicatorStyle.borderColor = CometChatGroupMembers.style.backgroundColor
        statusIndicatorStyle.borderWidth = 2
        return statusIndicatorStyle
    }()
    
    private var style: GroupMembersStyle
    private var avatarStyle: AvatarStyle
    private var statusIndicatorStyle: StatusIndicatorStyle
    
    private var hideUserStatus: Bool = false
    private var hideKickMemberOption: Bool = false
    private var hideBanMemberOption: Bool = false
    private var hideScopeChangeOption: Bool = false
    
    private var selectionMode: SelectionMode = .none
    private var selectionLimit: Int?
    
    private var listItemView: ((GroupMember) -> AnyView)?
    private var leadingView: ((GroupMember) -> AnyView)?
    private var titleView: ((GroupMember) -> AnyView)?
    private var subtitleView: ((GroupMember) -> AnyView)?
    private var trailingView: ((GroupMember) -> AnyView)?
    private var emptyStateView: (() -> AnyView)?
    private var errorStateView: (() -> AnyView)?
    private var loadingStateView: (() -> AnyView)?
    private var options: ((Group, GroupMember) -> [CometChatGroupMemberOption])?
    private var addOptions: ((Group, GroupMember) -> [CometChatGroupMemberOption])?
    
    private var onItemClick: ((GroupMember, Int, Int) -> Void)?
    private var onItemLongClick: ((GroupMember, IndexPath) -> Void)?
    private var onError: ((CometChatException) -> Void)?
    private var onEmpty: (() -> Void)?
    private var onLoad: (([GroupMember]) -> Void)?
    private var onSelectedItemProceed: (([GroupMember]) -> Void)?
    
    @StateObject private var viewModel = GroupMembersViewModelSwiftUI()
    @State private var searchText: String = ""
    @State private var showingActionSheet: Bool = false
    @State private var selectedMemberForAction: GroupMember?
    @State private var actionType: MemberActionType = .none
    @State private var showingScopeChangeSheet: Bool = false
    
    public init(style: GroupMembersStyle = CometChatGroupMembersSwiftUI.style) {
        self.style = style
        self.avatarStyle = CometChatGroupMembersSwiftUI.avatarStyle
        self.statusIndicatorStyle = CometChatGroupMembersSwiftUI.statusIndicatorStyle
    }
    
    public var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.groupMembers.isEmpty {
                loadingView
            } else if viewModel.hasError && viewModel.groupMembers.isEmpty {
                errorView
            } else if viewModel.groupMembers.isEmpty {
                emptyView
            } else {
                groupMembersListView
            }
        }
        .background(Color(style.backgroundColor))
        .navigationTitle("MEMBERS".localize())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if selectionMode != .none {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        onSelectedItemProceed?(viewModel.selectedGroupMembers)
                    }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(CometChatTheme.primaryColor))
                    }
                }
            }
        }
        .onAppear {
            viewModel.connect()
            viewModel.fetchGroupsMembers()
        }
        .onDisappear {
            viewModel.disconnect()
        }
        .actionSheet(isPresented: $showingActionSheet) {
            switch actionType {
            case .ban:
                return ActionSheet(
                    title: Text("Ban \(selectedMemberForAction?.name ?? "")"),
                    message: Text("Are you sure you want to ban \(selectedMemberForAction?.name ?? "") from this group ?"),
                    buttons: [
                        .destructive(Text("Yes")) {
                            if let member = selectedMemberForAction {
                                viewModel.banGroupMember(group: viewModel.group, member: member)
                            }
                        },
                        .cancel()
                    ]
                )
            case .kick:
                return ActionSheet(
                    title: Text("Kick \(selectedMemberForAction?.name ?? "")"),
                    message: Text("Are you sure you want to kick \(selectedMemberForAction?.name ?? "") from this group ?"),
                    buttons: [
                        .destructive(Text("Yes")) {
                            if let member = selectedMemberForAction {
                                viewModel.kickGroupMember(group: viewModel.group, member: member)
                            }
                        },
                        .cancel()
                    ]
                )
            case .none:
                return ActionSheet(title: Text(""))
            }
        }
    }
    
    private var groupMembersListView: some View {
        VStack(spacing: 0) {
            searchBar
            
            List {
                ForEach(viewModel.isSearching ? viewModel.filteredGroupMembers : viewModel.groupMembers, id: \.uid) { groupMember in
                    groupMemberItemView(for: groupMember, index: viewModel.groupMembers.firstIndex(of: groupMember) ?? 0)
                        .onAppear {
                            if groupMember == viewModel.groupMembers.last && !viewModel.isFetchedAll {
                                viewModel.fetchGroupsMembers()
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            swipeActionsView(for: groupMember)
                        }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color(style.backgroundColor))
            }
            .listStyle(PlainListStyle())
            .refreshable {
                viewModel.clearList()
                viewModel.fetchGroupsMembers()
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(style.searchIconTint))
            
            TextField("SEARCH".localize(), text: $searchText)
                .foregroundColor(Color(style.searchTextColor))
                .onChange(of: searchText) { newValue in
                    if newValue.isEmpty {
                        viewModel.isSearching = false
                    } else {
                        viewModel.isSearching = true
                        viewModel.filterGroupMembers(text: newValue)
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    viewModel.isSearching = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(style.searchIconTint))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(style.searchBackgroundColor))
        .cornerRadius(style.searchBorderRadius)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private func groupMemberItemView(for groupMember: GroupMember, index: Int) -> some View {
        if let customView = listItemView?(groupMember) {
            return customView
                .onTapGesture {
                    handleItemClick(groupMember, index: index)
                }
                .onLongPressGesture {
                    onItemLongClick?(groupMember, IndexPath(row: index, section: 0))
                }
                .eraseToAnyView()
        } else {
            return groupMemberDefaultView(for: groupMember, index: index)
                .onTapGesture {
                    handleItemClick(groupMember, index: index)
                }
                .onLongPressGesture {
                    onItemLongClick?(groupMember, IndexPath(row: index, section: 0))
                }
                .eraseToAnyView()
        }
    }
    
    private func groupMemberDefaultView(for groupMember: GroupMember, index: Int) -> some View {
        HStack(spacing: 16) {
            if let leadingCustomView = leadingView?(groupMember) {
                leadingCustomView
            } else {
                leadingDefaultView(for: groupMember)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let titleCustomView = titleView?(groupMember) {
                    titleCustomView
                } else {
                    titleDefaultView(for: groupMember)
                }
                
                if let subtitleCustomView = subtitleView?(groupMember) {
                    subtitleCustomView
                }
            }
            
            Spacer()
            
            if let trailingCustomView = trailingView?(groupMember) {
                trailingCustomView
            } else {
                trailingDefaultView(for: groupMember)
            }
        }
        .padding(.vertical, 8)
        .background(
            viewModel.selectedGroupMembers.contains(where: { $0.uid == groupMember.uid }) ?
            Color(style.selectedBackgroundColor) :
            Color(style.backgroundColor)
        )
        .cornerRadius(style.cornerRadius)
        .contentShape(Rectangle())
    }
    
    private func leadingDefaultView(for groupMember: GroupMember) -> some View {
        ZStack {
            CometChatAvatarSwiftUI(style: avatarStyle)
                .set(avatarURL: groupMember.avatar ?? "")
                .set(name: groupMember.name ?? "")
                .set(width: 40)
                .set(height: 40)
                .set(cornerRadius: 20)
            
            if !hideUserStatus && groupMember.status == .online && groupMember.blockedByMe == false {
                CometChatStatusIndicatorSwiftUI(style: statusIndicatorStyle)
                    .set(status: .online)
                    .offset(x: 14, y: 14)
            }
        }
        .frame(width: 40, height: 40)
    }
    
    private func titleDefaultView(for groupMember: GroupMember) -> some View {
        Text(groupMember.uid == CometChat.getLoggedInUser()?.uid ? "YOU".localize() : (groupMember.name ?? ""))
            .font(Font(style.titleFont))
            .foregroundColor(Color(style.titleColor))
            .lineLimit(1)
    }
    
    private func trailingDefaultView(for groupMember: GroupMember) -> some View {
        Group {
            switch groupMember.scope {
            case .admin:
                if viewModel.group.owner == groupMember.uid {
                    Text("OWNER".localize())
                        .font(Font(CometChatTypography.Caption1.regular))
                        .foregroundColor(Color(CometChatTheme.textColorWhite))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(CometChatTheme.primaryColor))
                        .cornerRadius(12)
                } else {
                    Text("ADMIN".localize())
                        .font(Font(CometChatTypography.Caption1.regular))
                        .foregroundColor(Color(CometChatTheme.primaryColor))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(CometChatTheme.extendedPrimaryColor100))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(CometChatTheme.primaryColor), lineWidth: 1)
                        )
                        .cornerRadius(12)
                }
            case .moderator:
                Text("MODERATOR".localize())
                    .font(Font(CometChatTypography.Caption1.regular))
                    .foregroundColor(Color(CometChatTheme.primaryColor))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(CometChatTheme.extendedPrimaryColor100))
                    .cornerRadius(12)
            case .participant:
                EmptyView()
            @unknown default:
                EmptyView()
            }
        }
    }
    
    private func swipeActionsView(for groupMember: GroupMember) -> some View {
        Group {
            if let customOptions = options?(viewModel.group, groupMember), !customOptions.isEmpty {
                ForEach(customOptions, id: \.id) { option in
                    Button {
                        if option.id == GroupMemberOptionConstants.ban {
                            selectedMemberForAction = groupMember
                            actionType = .ban
                            showingActionSheet = true
                        } else if option.id == GroupMemberOptionConstants.kick {
                            selectedMemberForAction = groupMember
                            actionType = .kick
                            showingActionSheet = true
                        } else {
                            option.onClick?(groupMember, viewModel.group, 0, option, nil)
                        }
                    } label: {
                        Label(option.title, image: option.icon?.pngData()?.base64EncodedString() ?? "")
                    }
                    .tint(Color(option.backgroundColor))
                }
            } else {
                if GroupMembersUtils.allowScopeChange(group: viewModel.group, groupMember: groupMember) && !hideScopeChangeOption {
                    Button {
                        selectedMemberForAction = groupMember
                        showingScopeChangeSheet = true
                    } label: {
                        Label("Scope", systemImage: "arrow.triangle.2.circlepath.circle")
                    }
                    .tint(Color(CometChatTheme.primaryColor))
                }
                
                if GroupMembersUtils.allowKickBanUnbanMember(group: viewModel.group, groupMember: groupMember) && !hideBanMemberOption {
                    Button {
                        selectedMemberForAction = groupMember
                        actionType = .ban
                        showingActionSheet = true
                    } label: {
                        Label("Ban", systemImage: "exclamationmark.octagon")
                    }
                    .tint(Color(CometChatTheme.warningColor))
                }
                
                if GroupMembersUtils.allowKickBanUnbanMember(group: viewModel.group, groupMember: groupMember) && !hideKickMemberOption {
                    Button {
                        selectedMemberForAction = groupMember
                        actionType = .kick
                        showingActionSheet = true
                    } label: {
                        Label("Kick", systemImage: "minus.circle")
                    }
                    .tint(Color(CometChatTheme.errorColor))
                }
            }
            
            if let additionalOptions = addOptions?(viewModel.group, groupMember) {
                ForEach(additionalOptions, id: \.id) { option in
                    Button {
                        option.onClick?(groupMember, viewModel.group, 0, option, nil)
                    } label: {
                        Label(option.title, image: option.icon?.pngData()?.base64EncodedString() ?? "")
                    }
                    .tint(Color(option.backgroundColor))
                }
            }
        }
    }
    
    private var loadingView: some View {
        if let customLoadingView = loadingStateView?() {
            return customLoadingView
        } else {
            return VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("LOADING".localize())
                    .font(Font(style.emptyStateTextFont))
                    .foregroundColor(Color(style.emptyStateTextColor))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(style.backgroundColor))
            .eraseToAnyView()
        }
    }
    
    private var errorView: some View {
        if let customErrorView = errorStateView?() {
            return customErrorView
        } else {
            return VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color(style.errorStateIconTint))
                
                Text("OOPS!".localize())
                    .font(Font(style.errorStateTextFont))
                    .foregroundColor(Color(style.errorStateTextColor))
                
                Text("LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize())
                    .font(Font(style.errorStateTextFont))
                    .foregroundColor(Color(style.errorStateTextColor))
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    viewModel.clearList()
                    viewModel.fetchGroupsMembers()
                }) {
                    Text("TRY_AGAIN".localize())
                        .font(Font(style.errorStateButtonFont))
                        .foregroundColor(Color(style.errorStateButtonTextColor))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(style.errorStateButtonBackgroundColor))
                        .cornerRadius(8)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(style.backgroundColor))
            .eraseToAnyView()
        }
    }
    
    private var emptyView: some View {
        if let customEmptyView = emptyStateView?() {
            return customEmptyView
        } else {
            return VStack(spacing: 16) {
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color(style.emptyStateIconTint))
                
                Text("NO_MEMBERS_AVAILABLE".localize())
                    .font(Font(style.emptyStateTextFont))
                    .foregroundColor(Color(style.emptyStateTextColor))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(style.backgroundColor))
            .eraseToAnyView()
        }
    }
    
    private func handleItemClick(_ groupMember: GroupMember, index: Int) {
        if selectionMode == .none {
            onItemClick?(groupMember, 0, index)
        } else {
            if selectionMode == .single {
                viewModel.clearSelection()
                viewModel.selectGroupMember(groupMember)
            } else {
                if viewModel.selectedGroupMembers.contains(where: { $0.uid == groupMember.uid }) {
                    viewModel.deselectGroupMember(groupMember)
                } else if selectionLimit == nil || viewModel.selectedGroupMembers.count < selectionLimit! {
                    viewModel.selectGroupMember(groupMember)
                }
            }
            onSelectedItemProceed?(viewModel.selectedGroupMembers)
        }
    }
    
    public func set(group: Group) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.viewModel.set(group: group)
        return view
    }
    
    public func set(style: GroupMembersStyle) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.style = style
        return view
    }
    
    public func set(avatarStyle: AvatarStyle) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.avatarStyle = avatarStyle
        return view
    }
    
    public func set(statusIndicatorStyle: StatusIndicatorStyle) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.statusIndicatorStyle = statusIndicatorStyle
        return view
    }
    
    public func hide(userStatus: Bool) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.hideUserStatus = userStatus
        return view
    }
    
    public func hide(kickMemberOption: Bool) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.hideKickMemberOption = kickMemberOption
        return view
    }
    
    public func hide(banMemberOption: Bool) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.hideBanMemberOption = banMemberOption
        return view
    }
    
    public func hide(scopeChangeOption: Bool) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.hideScopeChangeOption = scopeChangeOption
        return view
    }
    
    public func set(selectionMode: SelectionMode) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.selectionMode = selectionMode
        return view
    }
    
    public func set(selectionLimit: Int) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.selectionLimit = selectionLimit
        return view
    }
    
    public func set(groupMembersRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.viewModel.set(groupMembersRequestBuilder: groupMembersRequestBuilder)
        return view
    }
    
    public func set(searchGroupMembersRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.viewModel.set(searchGroupMembersRequestBuilder: searchGroupMembersRequestBuilder)
        return view
    }
    
    public func set<T: View>(listItemView: @escaping (GroupMember) -> T) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.listItemView = { groupMember in
            AnyView(listItemView(groupMember))
        }
        return view
    }
    
    public func set<T: View>(leadingView: @escaping (GroupMember) -> T) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.leadingView = { groupMember in
            AnyView(leadingView(groupMember))
        }
        return view
    }
    
    public func set<T: View>(titleView: @escaping (GroupMember) -> T) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.titleView = { groupMember in
            AnyView(titleView(groupMember))
        }
        return view
    }
    
    public func set<T: View>(subtitleView: @escaping (GroupMember) -> T) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.subtitleView = { groupMember in
            AnyView(subtitleView(groupMember))
        }
        return view
    }
    
    public func set<T: View>(trailingView: @escaping (GroupMember) -> T) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.trailingView = { groupMember in
            AnyView(trailingView(groupMember))
        }
        return view
    }
    
    public func set<T: View>(emptyStateView: @escaping () -> T) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.emptyStateView = {
            AnyView(emptyStateView())
        }
        return view
    }
    
    public func set<T: View>(errorStateView: @escaping () -> T) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.errorStateView = {
            AnyView(errorStateView())
        }
        return view
    }
    
    public func set<T: View>(loadingStateView: @escaping () -> T) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.loadingStateView = {
            AnyView(loadingStateView())
        }
        return view
    }
    
    public func set(options: @escaping (Group, GroupMember) -> [CometChatGroupMemberOption]) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.options = options
        return view
    }
    
    public func set(addOptions: @escaping (Group, GroupMember) -> [CometChatGroupMemberOption]) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.addOptions = addOptions
        return view
    }
    
    public func set(onItemClick: @escaping (GroupMember, Int, Int) -> Void) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.onItemClick = onItemClick
        return view
    }
    
    public func set(onItemLongClick: @escaping (GroupMember, IndexPath) -> Void) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.onItemLongClick = onItemLongClick
        return view
    }
    
    public func set(onError: @escaping (CometChatException) -> Void) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.onError = onError
        return view
    }
    
    public func set(onEmpty: @escaping () -> Void) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.onEmpty = onEmpty
        return view
    }
    
    public func set(onLoad: @escaping ([GroupMember]) -> Void) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.onLoad = onLoad
        return view
    }
    
    public func set(onSelectedItemProceed: @escaping ([GroupMember]) -> Void) -> CometChatGroupMembersSwiftUI {
        var view = self
        view.onSelectedItemProceed = onSelectedItemProceed
        return view
    }
}

extension CometChatGroupMembersSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}

enum MemberActionType {
    case ban
    case kick
    case none
}

struct CometChatGroupMembersSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatGroupMembersSwiftUI()
                .padding()
                .previewDisplayName("Default (Light)")
            
            CometChatGroupMembersSwiftUI()
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Default (Dark)")
            
            CometChatGroupMembersSwiftUI()
                .set(selectionMode: .single)
                .padding()
                .previewDisplayName("Single Selection Mode (Light)")
            
            CometChatGroupMembersSwiftUI()
                .set(selectionMode: .single)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Single Selection Mode (Dark)")
            
            CometChatGroupMembersSwiftUI()
                .set(selectionMode: .multiple)
                .padding()
                .previewDisplayName("Multiple Selection Mode (Light)")
            
            CometChatGroupMembersSwiftUI()
                .set(selectionMode: .multiple)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Multiple Selection Mode (Dark)")
        }
    }
}
