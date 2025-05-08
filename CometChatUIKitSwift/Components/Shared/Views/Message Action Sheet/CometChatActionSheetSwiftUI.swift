//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatActionSheetSwiftUI: View {
    
    private var style: ActionSheetStyle
    @State private var actionItems: [ActionItem] = []
    private var onActionItemClick: ((ActionItem) -> Void)?
    @State private var isPresented: Bool = false
    
    public init(style: ActionSheetStyle = ActionSheetStyle()) {
        self.style = style
    }
    
    public var body: some View {
        VStack {
            List {
                ForEach(0..<actionItems.count, id: \.self) { index in
                    if let actionItem = actionItems[safe: index] {
                        ActionItemRow(actionItem: actionItem)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                onActionItemClick?(actionItem)
                                isPresented = false
                            }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color(style.backgroundColor))
        }
        .background(Color(style.backgroundColor))
        .cornerRadius(style.cornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r4)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r4)
                .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
        )
    }
    
    public func set(actionItems: [ActionItem]) -> CometChatActionSheetSwiftUI {
        var view = self
        view._actionItems = State(initialValue: actionItems)
        return view
    }
    
    public func setOnActionItemClick(onClick: @escaping ((ActionItem) -> Void)) -> CometChatActionSheetSwiftUI {
        var view = self
        view.onActionItemClick = onClick
        return view
    }
    
    public func show() {
        self.isPresented = true
    }
    
    public func dismiss() {
        self.isPresented = false
    }
}

struct ActionItemRow: View {
    let actionItem: ActionItem
    
    var body: some View {
        HStack(spacing: 16) {
            if let icon = actionItem.leadingIcon {
                Image(uiImage: icon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color(CometChatTheme.iconColorHighlight))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
            
            Text(actionItem.text ?? "")
                .font(Font(CometChatTypography.Heading4.regular))
                .foregroundColor(Color(CometChatTheme.textColorPrimary))
            
            Spacer()
            
            if let trailingIcon = actionItem.trailingIcon {
                Image(uiImage: trailingIcon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color(CometChatTheme.iconColorHighlight))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.vertical, 8)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension CometChatActionSheetSwiftUI {
    public func toUIKit() -> UIViewController {
        let hostingController = UIHostingController(rootView: self)
        return hostingController
    }
    
    public func presentAsActionSheet(from viewController: UIViewController) {
        let hostingController = UIHostingController(rootView: self)
        hostingController.modalPresentationStyle = .pageSheet
        
        if let sheet = hostingController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = style.cornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r4
        }
        
        viewController.present(hostingController, animated: true)
    }
}

struct CometChatActionSheetSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatActionSheetSwiftUI()
                .set(actionItems: [
                    ActionItem(id: "1", text: "Take a Photo", leadingIcon: UIImage(systemName: "camera.fill")),
                    ActionItem(id: "2", text: "Photo & Video Library", leadingIcon: UIImage(systemName: "photo.fill")),
                    ActionItem(id: "3", text: "Document", leadingIcon: UIImage(systemName: "doc.fill")),
                    ActionItem(id: "4", text: "Location", leadingIcon: UIImage(systemName: "location.fill"))
                ])
                .previewLayout(.sizeThatFits)
                .frame(height: 300)
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            CometChatActionSheetSwiftUI()
                .set(actionItems: [
                    ActionItem(id: "1", text: "Take a Photo", leadingIcon: UIImage(systemName: "camera.fill")),
                    ActionItem(id: "2", text: "Photo & Video Library", leadingIcon: UIImage(systemName: "photo.fill")),
                    ActionItem(id: "3", text: "Document", leadingIcon: UIImage(systemName: "doc.fill")),
                    ActionItem(id: "4", text: "Location", leadingIcon: UIImage(systemName: "location.fill"))
                ])
                .previewLayout(.sizeThatFits)
                .frame(height: 300)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
