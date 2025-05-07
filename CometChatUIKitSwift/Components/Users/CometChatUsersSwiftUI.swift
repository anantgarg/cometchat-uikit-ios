//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatUsersSwiftUI: View {
    public static var style = UsersStyle()
    public static var avatarStyle: AvatarStyle = CometChatAvatar.style
    public static var statusIndicatorStyle: StatusIndicatorStyle = CometChatStatusIndicator.style
    
    private var style: UsersStyle
    private var avatarStyle: AvatarStyle
    private var statusIndicatorStyle: StatusIndicatorStyle
    
    private var hideUserStatus: Bool = false
    private var hideSectionHeader: Bool = false
    
    private var selectionMode: SelectionMode = .none
    private var selectionLimit: Int?
    
    private var listItemView: ((User) -> AnyView)?
    private var leadingView: ((User) -> AnyView)?
    private var titleView: ((User) -> AnyView)?
    private var subtitleView: ((User) -> AnyView)?
    private var trailingView: ((User) -> AnyView)?
    private var emptyStateView: (() -> AnyView)?
    private var errorStateView: (() -> AnyView)?
    private var loadingStateView: (() -> AnyView)?
    private var sectionHeaderView: ((String) -> AnyView)?
    
    private var onItemClick: ((User, Int, Int) -> Void)?
    private var onItemLongClick: ((User, Int, Int) -> Void)?
    private var onSelection: (([User]) -> Void)?
    private var onError: ((CometChatException) -> Void)?
    
    @StateObject private var viewModel: UsersViewModelSwiftUI
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    
    public init(style: UsersStyle = CometChatUsersSwiftUI.style, 
                usersRequestBuilder: UsersRequest.UsersRequestBuilder = UsersBuilder.getDefaultRequestBuilder()) {
        self.style = style
        self.avatarStyle = CometChatUsersSwiftUI.avatarStyle
        self.statusIndicatorStyle = CometChatUsersSwiftUI.statusIndicatorStyle
        _viewModel = StateObject(wrappedValue: UsersViewModelSwiftUI(userRequestBuilder: usersRequestBuilder))
    }
    
    public var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.users.isEmpty {
                loadingView
            } else if viewModel.hasError && viewModel.users.isEmpty {
                errorView
            } else if viewModel.users.isEmpty {
                emptyView
            } else {
                userListView
            }
        }
        .background(Color(style.backgroundColor))
        .onAppear {
            viewModel.connect()
            viewModel.isRefresh = true
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
    
    private var userListView: some View {
        VStack(spacing: 0) {
            if !isSearching {
                searchBar
            }
            
            List {
                if viewModel.isSearching {
                    ForEach(viewModel.filteredUsers, id: \.uid) { user in
                        userItemView(for: user, section: 0, row: viewModel.filteredUsers.firstIndex(where: { $0.uid == user.uid }) ?? 0)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color(style.backgroundColor))
                    }
                } else {
                    ForEach(Array(viewModel.users.enumerated()), id: \.element.first?.uid) { section, usersInSection in
                        if !hideSectionHeader, let firstUser = usersInSection.first, let firstLetter = firstUser.name?.prefix(1).uppercased() {
                            Section(header: sectionHeaderView(for: String(firstLetter))) {
                                ForEach(Array(usersInSection.enumerated()), id: \.element.uid) { row, user in
                                    userItemView(for: user, section: section, row: row)
                                        .onAppear {
                                            if section == viewModel.users.count - 1 && row == usersInSection.count - 1 && !viewModel.isFetchedAll && !viewModel.isFetching {
                                                viewModel.isRefresh = false
                                                viewModel.fetchUsers()
                                            }
                                        }
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color(style.backgroundColor))
                        } else {
                            ForEach(Array(usersInSection.enumerated()), id: \.element.uid) { row, user in
                                userItemView(for: user, section: section, row: row)
                                    .onAppear {
                                        if section == viewModel.users.count - 1 && row == usersInSection.count - 1 && !viewModel.isFetchedAll && !viewModel.isFetching {
                                            viewModel.isRefresh = false
                                            viewModel.fetchUsers()
                                        }
                                    }
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color(style.backgroundColor))
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .refreshable {
                viewModel.isRefresh = true
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
                        viewModel.filterUsers(text: newValue)
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
    
    private func userItemView(for user: User, section: Int, row: Int) -> some View {
        if let customView = listItemView?(user) {
            return customView
                .onTapGesture {
                    handleItemClick(user, section: section, row: row)
                }
                .onLongPressGesture {
                    onItemLongClick?(user, section, row)
                }
                .eraseToAnyView()
        } else {
            return userDefaultView(for: user, section: section, row: row)
                .onTapGesture {
                    handleItemClick(user, section: section, row: row)
                }
                .onLongPressGesture {
                    onItemLongClick?(user, section, row)
                }
                .eraseToAnyView()
        }
    }
    
    private func userDefaultView(for user: User, section: Int, row: Int) -> some View {
        HStack(spacing: 16) {
            if let leadingCustomView = leadingView?(user) {
                leadingCustomView
            } else {
                leadingDefaultView(for: user)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let titleCustomView = titleView?(user) {
                    titleCustomView
                } else {
                    titleDefaultView(for: user)
                }
                
                if let subtitleCustomView = subtitleView?(user) {
                    subtitleCustomView
                }
            }
            
            Spacer()
            
            if let trailingCustomView = trailingView?(user) {
                trailingCustomView
            }
        }
        .padding(.vertical, 8)
        .background(
            viewModel.selectedUsers.contains(where: { $0.uid == user.uid }) ?
            Color(style.selectedBackgroundColor) :
            Color(style.backgroundColor)
        )
        .cornerRadius(style.cornerRadius)
        .contentShape(Rectangle())
    }
    
    private func leadingDefaultView(for user: User) -> some View {
        ZStack {
            CometChatAvatarSwiftUI(style: avatarStyle)
                .set(user: user)
                .set(width: 40)
                .set(height: 40)
                .set(cornerRadius: 20)
            
            if !hideUserStatus && user.status == .online && user.blockedByMe == false {
                CometChatStatusIndicatorSwiftUI(style: statusIndicatorStyle)
                    .set(status: .online)
                    .offset(x: 14, y: 14)
            }
        }
        .frame(width: 40, height: 40)
    }
    
    private func titleDefaultView(for user: User) -> some View {
        Text(user.name ?? "")
            .font(Font(style.titleFont))
            .foregroundColor(Color(style.titleColor))
            .lineLimit(1)
    }
    
    private func sectionHeaderView(for title: String) -> some View {
        if let customHeaderView = sectionHeaderView?(title) {
            return customHeaderView
        } else {
            return Text(title)
                .font(Font(style.headerTitleFont))
                .foregroundColor(Color(style.headerTitleColor))
                .padding(.leading, 4)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.clear)
                .eraseToAnyView()
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
                Image(uiImage: UIImage(named: "error-icon", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                
                Text("OOPS!".localize())
                    .font(Font(style.errorStateTextFont))
                    .foregroundColor(Color(style.errorStateTextColor))
                
                Text("LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize())
                    .font(Font(style.errorStateTextFont))
                    .foregroundColor(Color(style.errorStateTextColor))
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    viewModel.isRefresh = true
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
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color(style.emptyStateIconTint))
                
                Text("USERS_EMPTY_MESSAGE".localize())
                    .font(Font(style.emptyStateTextFont))
                    .foregroundColor(Color(style.emptyStateTextColor))
                
                Text("USERS_EMPTY_SUBTITLE_MESSAGE".localize())
                    .font(Font(style.emptyStateTextFont))
                    .foregroundColor(Color(style.emptyStateTextColor))
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(style.backgroundColor))
            .eraseToAnyView()
        }
    }
    
    private func handleItemClick(_ user: User, section: Int, row: Int) {
        if selectionMode == .none {
            onItemClick?(user, section, row)
        } else {
            if selectionMode == .single {
                viewModel.clearSelection()
                viewModel.selectUser(user)
            } else {
                if viewModel.selectedUsers.contains(where: { $0.uid == user.uid }) {
                    viewModel.deselectUser(user)
                } else if selectionLimit == nil || viewModel.selectedUsers.count < selectionLimit! {
                    viewModel.selectUser(user)
                }
            }
            onSelection?(viewModel.selectedUsers)
        }
    }
    
    public func set(style: UsersStyle) -> CometChatUsersSwiftUI {
        var view = self
        view.style = style
        return view
    }
    
    public func set(avatarStyle: AvatarStyle) -> CometChatUsersSwiftUI {
        var view = self
        view.avatarStyle = avatarStyle
        return view
    }
    
    public func set(statusIndicatorStyle: StatusIndicatorStyle) -> CometChatUsersSwiftUI {
        var view = self
        view.statusIndicatorStyle = statusIndicatorStyle
        return view
    }
    
    public func hide(userStatus: Bool) -> CometChatUsersSwiftUI {
        var view = self
        view.hideUserStatus = userStatus
        return view
    }
    
    public func hide(sectionHeader: Bool) -> CometChatUsersSwiftUI {
        var view = self
        view.hideSectionHeader = sectionHeader
        return view
    }
    
    public func set(selectionMode: SelectionMode) -> CometChatUsersSwiftUI {
        var view = self
        view.selectionMode = selectionMode
        return view
    }
    
    public func set(selectionLimit: Int) -> CometChatUsersSwiftUI {
        var view = self
        view.selectionLimit = selectionLimit
        return view
    }
    
    public func set<T: View>(listItemView: @escaping (User) -> T) -> CometChatUsersSwiftUI {
        var view = self
        view.listItemView = { user in
            AnyView(listItemView(user))
        }
        return view
    }
    
    public func set<T: View>(leadingView: @escaping (User) -> T) -> CometChatUsersSwiftUI {
        var view = self
        view.leadingView = { user in
            AnyView(leadingView(user))
        }
        return view
    }
    
    public func set<T: View>(titleView: @escaping (User) -> T) -> CometChatUsersSwiftUI {
        var view = self
        view.titleView = { user in
            AnyView(titleView(user))
        }
        return view
    }
    
    public func set<T: View>(subtitleView: @escaping (User) -> T) -> CometChatUsersSwiftUI {
        var view = self
        view.subtitleView = { user in
            AnyView(subtitleView(user))
        }
        return view
    }
    
    public func set<T: View>(trailingView: @escaping (User) -> T) -> CometChatUsersSwiftUI {
        var view = self
        view.trailingView = { user in
            AnyView(trailingView(user))
        }
        return view
    }
    
    public func set<T: View>(emptyStateView: @escaping () -> T) -> CometChatUsersSwiftUI {
        var view = self
        view.emptyStateView = {
            AnyView(emptyStateView())
        }
        return view
    }
    
    public func set<T: View>(errorStateView: @escaping () -> T) -> CometChatUsersSwiftUI {
        var view = self
        view.errorStateView = {
            AnyView(errorStateView())
        }
        return view
    }
    
    public func set<T: View>(loadingStateView: @escaping () -> T) -> CometChatUsersSwiftUI {
        var view = self
        view.loadingStateView = {
            AnyView(loadingStateView())
        }
        return view
    }
    
    public func set<T: View>(sectionHeaderView: @escaping (String) -> T) -> CometChatUsersSwiftUI {
        var view = self
        view.sectionHeaderView = { title in
            AnyView(sectionHeaderView(title))
        }
        return view
    }
    
    public func set(onItemClick: @escaping (User, Int, Int) -> Void) -> CometChatUsersSwiftUI {
        var view = self
        view.onItemClick = onItemClick
        return view
    }
    
    public func set(onItemLongClick: @escaping (User, Int, Int) -> Void) -> CometChatUsersSwiftUI {
        var view = self
        view.onItemLongClick = onItemLongClick
        return view
    }
    
    public func set(onSelection: @escaping ([User]) -> Void) -> CometChatUsersSwiftUI {
        var view = self
        view.onSelection = onSelection
        return view
    }
    
    public func set(onError: @escaping (CometChatException) -> Void) -> CometChatUsersSwiftUI {
        var view = self
        view.onError = onError
        return view
    }
    
    public func add(user: User) -> CometChatUsersSwiftUI {
        viewModel.add(user: user)
        return self
    }
    
    public func update(user: User) -> CometChatUsersSwiftUI {
        viewModel.update(user: user)
        return self
    }
    
    public func remove(user: User) -> CometChatUsersSwiftUI {
        viewModel.remove(user: user)
        return self
    }
    
    public func getSelectedUsers() -> [User] {
        return viewModel.selectedUsers
    }
}

extension CometChatUsersSwiftUI {
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

struct CometChatUsersSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatUsersSwiftUI()
                .padding()
                .previewDisplayName("Default (Light)")
            
            CometChatUsersSwiftUI()
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Default (Dark)")
            
            CometChatUsersSwiftUI()
                .set(selectionMode: .single)
                .padding()
                .previewDisplayName("Single Selection Mode (Light)")
            
            CometChatUsersSwiftUI()
                .set(selectionMode: .single)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Single Selection Mode (Dark)")
            
            CometChatUsersSwiftUI()
                .set(selectionMode: .multiple)
                .padding()
                .previewDisplayName("Multiple Selection Mode (Light)")
            
            CometChatUsersSwiftUI()
                .set(selectionMode: .multiple)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Multiple Selection Mode (Dark)")
        }
    }
}
