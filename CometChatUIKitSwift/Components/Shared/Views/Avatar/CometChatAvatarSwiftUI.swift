//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatAvatarSwiftUI: View {
    private var style: AvatarStyle
    private var user: User?
    private var group: Group?
    private var name: String?
    private var avatarURL: String?
    private var backgroundColor: UIColor?
    private var outerViewWidth: CGFloat = 36
    private var outerViewHeight: CGFloat = 36
    private var cornerRadius: CGFloat?
    
    public init(style: AvatarStyle = CometChatAvatar.style) {
        self.style = style
    }
    
    public var body: some View {
        ZStack {
            if let user = user {
                avatarView(name: user.name, avatarURL: user.avatar, uid: user.uid)
            } else if let group = group {
                avatarView(name: group.name, avatarURL: group.icon, uid: group.guid)
            } else if let name = name {
                avatarView(name: name, avatarURL: avatarURL, uid: nil)
            } else {
                Circle()
                    .fill(Color(style.backgroundColor))
                    .frame(width: outerViewWidth, height: outerViewHeight)
            }
        }
        .frame(width: outerViewWidth, height: outerViewHeight)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius ?? outerViewWidth / 2)
                .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
        )
    }
    
    private func avatarView(name: String?, avatarURL: String?, uid: String?) -> some View {
        ZStack {
            if let avatarURL = avatarURL, !avatarURL.isEmpty, let url = URL(string: avatarURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderView(name: name, uid: uid)
                    @unknown default:
                        placeholderView(name: name, uid: uid)
                    }
                }
                .clipShape(Circle())
            } else {
                placeholderView(name: name, uid: uid)
            }
        }
        .frame(width: outerViewWidth, height: outerViewHeight)
        .clipShape(Circle())
    }
    
    private func placeholderView(name: String?, uid: String?) -> some View {
        ZStack {
            Circle()
                .fill(Color(backgroundColor ?? generateColor(for: uid ?? "")))
            
            if let name = name, !name.isEmpty {
                Text(getInitials(from: name))
                    .font(Font(style.textFont))
                    .foregroundColor(Color(style.textColor))
            }
        }
    }
    
    private func getInitials(from name: String) -> String {
        let words = name.components(separatedBy: .whitespacesAndNewlines)
        let letters = CharacterSet.alphanumerics
        var firstChar: String = ""
        var secondChar: String = ""
        var firstCharFoundIndex: Int = -1
        var firstCharFound: Bool = false
        var secondCharFound: Bool = false
        
        for (index, item) in words.enumerated() {
            if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            for (_, char) in item.unicodeScalars.enumerated() {
                if letters.contains(char) {
                    if !firstCharFound {
                        firstChar = String(char)
                        firstCharFound = true
                        firstCharFoundIndex = index
                    } else if !secondCharFound {
                        secondChar = String(char)
                        if firstCharFoundIndex != index {
                            secondCharFound = true
                        }
                        break
                    } else {
                        break
                    }
                }
            }
        }
        
        if firstChar.isEmpty && secondChar.isEmpty {
            firstChar = "\(name.first ?? "?")"
        }
        
        return firstChar + secondChar
    }
    
    private func generateColor(for identifier: String) -> UIColor {
        let colors = [
            CometChatTheme.extendedPrimaryColor500,
            CometChatTheme.extendedPrimaryColor600,
            CometChatTheme.extendedPrimaryColor700,
            CometChatTheme.extendedPrimaryColor800,
            CometChatTheme.extendedPrimaryColor900
        ]
        
        var total: Int = 0
        for character in identifier {
            if let value = character.asciiValue {
                total += Int(value)
            }
        }
        
        return colors[total % colors.count]
    }
    
    public func set(user: User?) -> CometChatAvatarSwiftUI {
        var view = self
        view.user = user
        return view
    }
    
    public func set(group: Group?) -> CometChatAvatarSwiftUI {
        var view = self
        view.group = group
        return view
    }
    
    public func set(name: String?) -> CometChatAvatarSwiftUI {
        var view = self
        view.name = name
        return view
    }
    
    public func set(avatarURL: String?) -> CometChatAvatarSwiftUI {
        var view = self
        view.avatarURL = avatarURL
        return view
    }
    
    public func set(backgroundColor: UIColor?) -> CometChatAvatarSwiftUI {
        var view = self
        view.backgroundColor = backgroundColor
        return view
    }
    
    public func set(width: CGFloat) -> CometChatAvatarSwiftUI {
        var view = self
        view.outerViewWidth = width
        return view
    }
    
    public func set(height: CGFloat) -> CometChatAvatarSwiftUI {
        var view = self
        view.outerViewHeight = height
        return view
    }
    
    public func set(cornerRadius: CGFloat) -> CometChatAvatarSwiftUI {
        var view = self
        view.cornerRadius = cornerRadius
        return view
    }
}

extension CometChatAvatarSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatAvatarSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatAvatarSwiftUI()
                .previewLayout(.fixed(width: 100, height: 100))
            
            CometChatAvatarSwiftUI()
                .set(name: "John Doe")
                .previewLayout(.fixed(width: 100, height: 100))
        }
    }
}
