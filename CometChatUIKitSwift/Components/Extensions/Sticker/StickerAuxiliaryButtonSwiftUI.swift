//
//
//

import CometChatSDK
import SwiftUI

public struct StickerAuxiliaryButtonSwiftUI: View {
    @State private var isKeyboardMode: Bool = false
    @State private var stickerButtonIcon: UIImage = .init(named: "sticker-image", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    @State private var keyboardButtonIcon: UIImage = .init(named: "sticker-image-filled", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    @State private var onStickerTap: (() -> Void)?
    @State private var onKeyboardTap: (() -> Void)?

    public init() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            isKeyboardMode = false
        }
    }

    public var body: some View {
        Button(action: {
            if !isKeyboardMode {
                isKeyboardMode = true
                onStickerTap?()
            } else {
                isKeyboardMode = false
                onKeyboardTap?()
            }
        }) {
            Image(uiImage: isKeyboardMode ? keyboardButtonIcon : stickerButtonIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(isKeyboardMode ? Color(CometChatTheme.primaryColor) : Color(CometChatTheme.iconColorSecondary))
        }
        .frame(width: 44, height: 44)
    }

    @discardableResult
    public func setStickerButtonIcon(_ icon: UIImage) -> Self {
        var view = self
        view._stickerButtonIcon = State(initialValue: icon)
        return view
    }

    @discardableResult
    public func setKeyboardButtonIcon(_ icon: UIImage) -> Self {
        var view = self
        view._keyboardButtonIcon = State(initialValue: icon)
        return view
    }

    @discardableResult
    public func setOnStickerTap(_ callback: @escaping () -> Void) -> Self {
        var view = self
        view._onStickerTap = State(initialValue: callback)
        return view
    }

    @discardableResult
    public func setOnKeyboardTap(_ callback: @escaping () -> Void) -> Self {
        var view = self
        view._onKeyboardTap = State(initialValue: callback)
        return view
    }

    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        let view = hostingController.view
        view?.translatesAutoresizingMaskIntoConstraints = false
        view?.widthAnchor.constraint(equalToConstant: 44).isActive = true
        view?.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return view ?? UIView()
    }
}

struct StickerAuxiliaryButtonSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        StickerAuxiliaryButtonSwiftUI()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
