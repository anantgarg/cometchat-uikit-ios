//
//
//

import SwiftUI
import CometChatSDK
import CometChatUIKitSwift.Components.Shared.Constants

public struct CometChatGroupsSwiftUI: View {
    @ObservedObject private var viewModel: GroupsViewModelSwiftUI
    private var style: GroupsStyle
    
    private var hideSearch: Bool = false
    private var hideError: Bool = false
    private var hideLoading: Bool = false
    private var selectionMode: SelectionMode = .none
    private var selectionLimit: Int?
    private var hideGroupType: Bool = false
    
    private var emptyStateView: AnyView?
    private var errorStateView: AnyView?
    private var loadingStateView: AnyView?
    private var listItemView: ((Group) -> AnyView)?
    private var subtitleView: ((Group) -> AnyView)?
    private var titleView: ((Group) -> AnyView)?
    private var trailingView: ((Group) -> AnyView)?
    private var leadingView: ((Group) -> AnyView)?
    
    private var onItemClick: ((Group) -> Void)?
    private var onItemLongClick: ((Group) -> Void)?
    private var onError: ((CometChatException) -> Void)?
    private var onSelection: (([Group]) -> Void)?
    private var onSelectedItemProceed: (([Group]) -> Void)?
    private var onDidSelect: ((Group) -> Void)?
    private var joinPasswordProtectedGroup: ((Group) -> Void)?
    private var onEmpty: (() -> Void)?
    private var onLoad: (([Group]) -> Void)?
    
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var showJoiningAlert: Bool = false
    @State private var joiningGroup: Group?
    
    public init(style: GroupsStyle = CometChatGroups.style) {
        self.style = style
        self._viewModel = ObservedObject(wrappedValue: GroupsViewModelSwiftUI())
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if !hideSearch {
                    searchBar
                }
                
                if viewModel.isLoading && !hideLoading {
                    loadingView
                } else if viewModel.hasError && !hideError {
                    errorView
                } else if (viewModel.isSearching ? viewModel.filteredGroups.isEmpty : viewModel.groups.isEmpty) {
                    emptyView
                } else {
                    groupsList
                }
            }
            .background(Color(style.backgroundColor))
            
            if showJoiningAlert {
                joiningGroupAlert
            }
        }
        .onAppear {
            viewModel.connect()
            viewModel.fetchGroups()
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(style.searchIconTint))
            
            TextField("SEARCH".localize(), text: $searchText)
                .foregroundColor(Color(style.searchTextColor))
                .font(Font(style.searchTextFont))
                .onChange(of: searchText) { newValue in
                    if newValue.isEmpty {
                        viewModel.isSearching = false
                    } else {
                        viewModel.isSearching = true
                        viewModel.filterGroups(text: newValue)
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
        .padding()
        .background(Color(style.searchBackgroundColor))
        .cornerRadius(style.searchBorderRadius)
        .padding(.horizontal)
        .padding(.vertical, LayoutMetrics.spacingStandard)
    }
    
    private var groupsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.isSearching ? viewModel.filteredGroups : viewModel.groups, id: \.guid) { group in
                    groupListItem(for: group)
                        .onAppear {
                            let groups = viewModel.isSearching ? viewModel.filteredGroups : viewModel.groups
                            if group.guid == groups.last?.guid && !viewModel.isFetchedAll && !viewModel.isFetching {
                                viewModel.isRefresh = false
                                viewModel.fetchGroups()
                            }
                        }
                }
            }
        }
        .refreshable {
            viewModel.isRefresh = true
        }
    }
    
    private func groupListItem(for group: Group) -> some View {
        Group {
            if let customView = listItemView?(group) {
                customView
                    .onTapGesture {
                        handleItemClick(group)
                    }
                    .onLongPressGesture {
                        onItemLongClick?(group)
                    }
            } else {
                defaultGroupListItem(for: group)
                    .onTapGesture {
                        handleItemClick(group)
                    }
                    .onLongPressGesture {
                        onItemLongClick?(group)
                    }
            }
        }
        .background(viewModel.selectedGroups.contains(group) ? Color(style.listItemSelectedBackground) : Color(style.listItemBackground))
    }
    
    private func defaultGroupListItem(for group: Group) -> some View {
        HStack(spacing: LayoutMetrics.spacingMedium) {
            if let leadingView = leadingView?(group) {
                leadingView
            } else {
                CometChatAvatarSwiftUI(style: style.avatarStyle)
                    .set(avatarURL: group.icon)
                    .set(name: group.name)
                    .set(width: LayoutMetrics.avatarMedium)
                    .set(height: LayoutMetrics.avatarMedium)
            }
            
            VStack(alignment: .leading, spacing: LayoutMetrics.spacingSmall) {
                if let titleView = titleView?(group) {
                    titleView
                } else {
                    Text(group.name ?? "")
                        .font(Font(style.listItemTitleFont))
                        .foregroundColor(Color(style.listItemTitleTextColor))
                }
                
                if let subtitleView = subtitleView?(group) {
                    subtitleView
                } else {
                    Text(group.membersCount <= 1 ? "\(group.membersCount) \("MEMBER".localize())" : "\(group.membersCount) \("MEMBERS".localize())")
                        .font(Font(style.listItemSubTitleFont))
                        .foregroundColor(Color(style.listItemSubTitleTextColor))
                }
            }
            
            Spacer()
            
            if !hideGroupType {
                groupTypeIndicator(for: group)
            }
            
            if let trailingView = trailingView?(group) {
                trailingView
            }
        }
        .padding()
        .background(viewModel.selectedGroups.contains(group) ? Color(style.listItemSelectedBackground) : Color(style.listItemBackground))
    }
    
    private func groupTypeIndicator(for group: Group) -> some View {
        Group {
            switch group.groupType {
            case .public:
                EmptyView()
            case .private:
                Image(systemName: "shield.fill")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color(style.privateGroupImageTintColor))
                    .frame(width: LayoutMetrics.mediumIconSize, height: LayoutMetrics.mediumIconSize)
                    .padding(LayoutMetrics.spacingSmall)
                    .background(Color(style.privateGroupImageBackgroundColor))
                    .clipShape(Circle())
            case .password:
                Image(systemName: "lock.fill")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: LayoutMetrics.mediumIconSize, height: LayoutMetrics.mediumIconSize)
                    .padding(LayoutMetrics.spacingSmall)
                    .background(Color(style.passwordGroupImageBackgroundColor))
                    .clipShape(Circle())
            @unknown default:
                EmptyView()
            }
        }
    }
    
    private var loadingView: some View {
        Group {
            if let loadingStateView = loadingStateView {
                loadingStateView
            } else {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("LOADING".localize())
                        .font(Font(style.loadingStateTextFont))
                        .foregroundColor(Color(style.loadingStateTextColor))
                        .padding(.top, LayoutMetrics.spacingStandard)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(style.backgroundColor))
            }
        }
    }
    
    private var errorView: some View {
        Group {
            if let errorStateView = errorStateView {
                errorStateView
            } else {
                VStack(spacing: LayoutMetrics.spacingMedium) {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: LayoutMetrics.largeIconSize * 2.5, height: LayoutMetrics.largeIconSize * 2.5)
                        .foregroundColor(Color(style.errorStateIconTint))
                    
                    Text("OOPS!".localize())
                        .font(Font(style.errorStateTitleFont))
                        .foregroundColor(Color(style.errorStateTitleTextColor))
                    
                    Text("LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize())
                        .font(Font(style.errorStateTextFont))
                        .foregroundColor(Color(style.errorStateTextColor))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.isRefresh = true
                    }) {
                        Text("RETRY".localize())
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, LayoutMetrics.spacingLarge)
                            .padding(.vertical, LayoutMetrics.spacingMedium)
                            .background(Color.blue)
                            .cornerRadius(LayoutMetrics.cornerRadiusStandard)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(style.backgroundColor))
            }
        }
    }
    
    private var emptyView: some View {
        Group {
            if let emptyStateView = emptyStateView {
                emptyStateView
            } else {
                VStack(spacing: LayoutMetrics.spacingMedium) {
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: LayoutMetrics.largeIconSize * 2.5, height: LayoutMetrics.largeIconSize * 2.5)
                        .foregroundColor(Color(style.emptyStateIconTint))
                    
                    Text("GROUPS_EMPTY_MESSAGE".localize())
                        .font(Font(style.emptyStateTitleFont))
                        .foregroundColor(Color(style.emptyStateTitleTextColor))
                    
                    Text("CREATE_GROUP_MESSAGE".localize())
                        .font(Font(style.emptyStateTextFont))
                        .foregroundColor(Color(style.emptyStateTextColor))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        onEmpty?()
                    }) {
                        Text("CREATE".localize())
                            .font(Font(style.emptyStateButtonFont))
                            .foregroundColor(Color(style.emptyStateButtonTextColor))
                            .padding(.horizontal, LayoutMetrics.spacingLarge)
                            .padding(.vertical, LayoutMetrics.spacingMedium)
                            .background(Color(style.emptyStateButtonBackgroundColor))
                            .cornerRadius(LayoutMetrics.cornerRadiusStandard)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(style.backgroundColor))
            }
        }
        .onAppear {
            onEmpty?()
        }
    }
    
    private var joiningGroupAlert: some View {
        ZStack {
            Color(style.overlayColor).opacity(LayoutMetrics.standardOpacity)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                
                Text("JOINING_GROUP".localize())
                    .font(Font(style.alertTitleFont))
                    .foregroundColor(Color(style.alertTitleColor))
            }
            .padding(LayoutMetrics.spacingLarge)
            .background(Color(style.alertBackgroundColor))
            .cornerRadius(LayoutMetrics.cornerRadiusMedium)
            .shadow(radius: LayoutMetrics.cornerRadiusMedium - 2)
        }
    }
    
    private func handleItemClick(_ group: Group) {
        if selectionMode == .none {
            if group.hasJoined {
                onItemClick?(group)
            } else {
                onDidSelect?(group)
                
                if !group.hasJoined, group.groupType == .public {
                    joiningGroup = group
                    showJoiningAlert = true
                    
                    viewModel.joinGroup(withGuid: group.guid, name: group.name ?? "", groupType: group.groupType, password: "") { joinedGroup in
                        showJoiningAlert = false
                        
                        if let joinedGroup = joinedGroup {
                            group.hasJoined = true
                            onItemClick?(joinedGroup)
                        }
                    }
                } else if !group.hasJoined, group.groupType == .password {
                    joinPasswordProtectedGroup?(group)
                } else {
                    if let user = CometChat.getLoggedInUser() {
                        CometChatGroupEvents.ccGroupMemberJoined(joinedUser: user, joinedGroup: group)
                    }
                }
            }
        } else {
            if viewModel.selectedGroups.contains(group) {
                viewModel.deselectGroup(group)
            } else {
                if selectionLimit == nil || viewModel.selectedGroups.count < selectionLimit! {
                    viewModel.selectGroup(group)
                }
            }
            onSelection?(viewModel.selectedGroups)
        }
    }
    
    public func set(groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder) -> Self {
        var view = self
        view.viewModel.isRefresh = true
        return view
    }
    
    public func hide(search: Bool) -> Self {
        var view = self
        view.hideSearch = search
        return view
    }
    
    public func hide(error: Bool) -> Self {
        var view = self
        view.hideError = error
        return view
    }
    
    public func hide(loading: Bool) -> Self {
        var view = self
        view.hideLoading = loading
        return view
    }
    
    public func set(selectionMode: SelectionMode) -> Self {
        var view = self
        view.selectionMode = selectionMode
        return view
    }
    
    public func set(selectionLimit: Int) -> Self {
        var view = self
        view.selectionLimit = selectionLimit
        return view
    }
    
    public func hide(groupType: Bool) -> Self {
        var view = self
        view.hideGroupType = groupType
        return view
    }
    
    public func set<T: View>(emptyStateView: T) -> Self {
        var view = self
        view.emptyStateView = AnyView(emptyStateView)
        return view
    }
    
    public func set<T: View>(errorStateView: T) -> Self {
        var view = self
        view.errorStateView = AnyView(errorStateView)
        return view
    }
    
    public func set<T: View>(loadingStateView: T) -> Self {
        var view = self
        view.loadingStateView = AnyView(loadingStateView)
        return view
    }
    
    public func set<T: View>(listItemView: @escaping (Group) -> T) -> Self {
        var view = self
        view.listItemView = { group in
            AnyView(listItemView(group))
        }
        return view
    }
    
    public func set<T: View>(subtitleView: @escaping (Group) -> T) -> Self {
        var view = self
        view.subtitleView = { group in
            AnyView(subtitleView(group))
        }
        return view
    }
    
    public func set<T: View>(titleView: @escaping (Group) -> T) -> Self {
        var view = self
        view.titleView = { group in
            AnyView(titleView(group))
        }
        return view
    }
    
    public func set<T: View>(trailingView: @escaping (Group) -> T) -> Self {
        var view = self
        view.trailingView = { group in
            AnyView(trailingView(group))
        }
        return view
    }
    
    public func set<T: View>(leadingView: @escaping (Group) -> T) -> Self {
        var view = self
        view.leadingView = { group in
            AnyView(leadingView(group))
        }
        return view
    }
    
    public func onItemClick(_ action: @escaping (Group) -> Void) -> Self {
        var view = self
        view.onItemClick = action
        return view
    }
    
    public func onItemLongClick(_ action: @escaping (Group) -> Void) -> Self {
        var view = self
        view.onItemLongClick = action
        return view
    }
    
    public func onError(_ action: @escaping (CometChatException) -> Void) -> Self {
        var view = self
        view.onError = action
        return view
    }
    
    public func onSelection(_ action: @escaping ([Group]) -> Void) -> Self {
        var view = self
        view.onSelection = action
        return view
    }
    
    public func onSelectedItemProceed(_ action: @escaping ([Group]) -> Void) -> Self {
        var view = self
        view.onSelectedItemProceed = action
        return view
    }
    
    public func onDidSelect(_ action: @escaping (Group) -> Void) -> Self {
        var view = self
        view.onDidSelect = action
        return view
    }
    
    public func joinPasswordProtectedGroup(_ action: @escaping (Group) -> Void) -> Self {
        var view = self
        view.joinPasswordProtectedGroup = action
        return view
    }
    
    public func onEmpty(_ action: @escaping () -> Void) -> Self {
        var view = self
        view.onEmpty = action
        return view
    }
    
    public func onLoad(_ action: @escaping ([Group]) -> Void) -> Self {
        var view = self
        view.onLoad = action
        return view
    }
}

extension CometChatGroupsSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatGroupsSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatGroupsSwiftUI()
                .previewDisplayName("Default (Light)")
            
            CometChatGroupsSwiftUI()
                .hide(search: true)
                .set(selectionMode: .multiple)
                .previewDisplayName("Multiple Selection (Light)")
            
            CometChatGroupsSwiftUI()
                .preferredColorScheme(.dark)
                .previewDisplayName("Default (Dark)")
        }
    }
}
