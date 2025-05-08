//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatListItemSwiftUI: View {
    
    private var style: ListItemStyle
    @State private var title: String?
    @State private var isSelected: Bool = false
    private var onItemLongClick: (() -> Void)?
    
    public init(style: ListItemStyle = ListItemStyleDefault()) {
        self.style = style
    }
    
    public var body: some View {
        HStack(spacing: CometChatSpacing.Spacing.s3) {
            if !isSelected {
                Image(uiImage: style.listItemDeSelectedImage)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color(style.listItemDeSelectedImageTint))
                    .frame(width: 24, height: 24)
                    .opacity(isSelected ? 1.0 : 0.0)
            } else {
                Image(uiImage: style.listItemSelectedImage)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color(style.listItemSelectionImageTint))
                    .frame(width: 24, height: 24)
            }
            
            AvatarWithStatusView()
            
            VStack(alignment: .leading, spacing: 5) {
                if let title = title {
                    Text(title)
                        .font(Font(style.listItemTitleFont))
                        .foregroundColor(Color(style.listItemTitleTextColor))
                }
                
                SubtitleView()
            }
            
            Spacer()
            
            TailView()
        }
        .padding(.vertical, CometChatSpacing.Spacing.s3)
        .padding(.horizontal, CometChatSpacing.Spacing.s4)
        .background(
            RoundedRectangle(cornerRadius: style.listItemCornerRadius.cornerRadius)
                .fill(Color(isSelected ? style.listItemSelectedBackground : style.listItemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: style.listItemCornerRadius.cornerRadius)
                        .stroke(Color(style.listItemBorderColor), lineWidth: style.listItemBorderWidth)
                )
        )
        .onLongPressGesture {
            onItemLongClick?()
        }
        .onTapGesture {
            isSelected.toggle()
        }
    }
    
    @ViewBuilder
    private func AvatarWithStatusView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            CometChatAvatarSwiftUI()
                .frame(width: 40, height: 40)
            
            Circle()
                .fill(Color.green)
                .frame(width: 14, height: 14)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
        }
    }
    
    @ViewBuilder
    private func SubtitleView() -> some View {
        EmptyView() // Placeholder for custom subtitle view
    }
    
    @ViewBuilder
    private func TailView() -> some View {
        EmptyView() // Placeholder for custom tail view
    }
    
    public func set(title: String) -> CometChatListItemSwiftUI {
        var view = self
        view._title = State(initialValue: title)
        return view
    }
    
    public func set(selected: Bool) -> CometChatListItemSwiftUI {
        var view = self
        view._isSelected = State(initialValue: selected)
        return view
    }
    
    public func setOnItemLongClick(onClick: @escaping (() -> Void)) -> CometChatListItemSwiftUI {
        var view = self
        view.onItemLongClick = onClick
        return view
    }
}

extension CometChatListItemSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatListItemSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatListItemSwiftUI()
                .set(title: "John Doe")
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            CometChatListItemSwiftUI()
                .set(title: "Jane Smith")
                .set(selected: true)
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode - Selected")
        }
    }
}
