//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatDialogSwiftUI {
    private var title: String = ""
    private var titleColor: Color = Color.gray
    private var titleFont: Font = Font(CometChatTheme_v4.typography.text1)
    private var messageText: String = ""
    private var messageTextColor: Color = Color.gray
    private var messageTextFont: Font = Font(CometChatTheme_v4.typography.subtitle2)
    private var confirmButtonText: String = ""
    private var confirmButtonTextColor: Color = Color(CometChatTheme_v4.palatte.primary)
    private var confirmButtonTextFont: Font = Font(CometChatTheme_v4.typography.text1)
    private var cancelButtonText: String = ""
    private var cancelButtonTextColor: Color = Color(CometChatTheme_v4.palatte.primary)
    private var cancelButtonTextFont: Font = Font(CometChatTheme_v4.typography.text1)
    
    @State private var isPresented: Bool = false
    
    public init() {}
    
    public func set(messageText: String) -> CometChatDialogSwiftUI {
        var dialog = self
        dialog.messageText = messageText
        return dialog
    }
    
    public func set(messageColor: UIColor) -> CometChatDialogSwiftUI {
        var dialog = self
        dialog.messageTextColor = Color(messageColor)
        return dialog
    }
    
    public func set(messageTextFont: UIFont) -> CometChatDialogSwiftUI {
        var dialog = self
        dialog.messageTextFont = Font(messageTextFont)
        return dialog
    }
    
    public func set(title: String) -> CometChatDialogSwiftUI {
        var dialog = self
        dialog.title = title
        return dialog
    }
    
    public func set(titleColor: UIColor) -> CometChatDialogSwiftUI {
        var dialog = self
        dialog.titleColor = Color(titleColor)
        return dialog
    }
    
    public func set(titleFont: UIFont) -> CometChatDialogSwiftUI {
        var dialog = self
        dialog.titleFont = Font(titleFont)
        return dialog
    }
    
    public func set(confirmButtonText: String) -> CometChatDialogSwiftUI {
        var dialog = self
        dialog.confirmButtonText = confirmButtonText
        return dialog
    }
    
    public func set(confirmButtonTextColor: UIColor) -> CometChatDialogSwiftUI {
        var dialog = self
        dialog.confirmButtonTextColor = Color(confirmButtonTextColor)
        return dialog
    }
    
    public func set(confirmButtonTextFont: UIFont) -> CometChatDialogSwiftUI {
        var dialog = self
        dialog.confirmButtonTextFont = Font(confirmButtonTextFont)
        return dialog
    }
    
    public func set(cancelButtonText: String) -> CometChatDialogSwiftUI {
        var dialog = self
        dialog.cancelButtonText = cancelButtonText
        return dialog
    }
    
    public func set(cancelButtonTextColor: UIColor) -> CometChatDialogSwiftUI {
        var dialog = self
        dialog.cancelButtonTextColor = Color(cancelButtonTextColor)
        return dialog
    }
    
    public func set(cancelButtonTextFont: UIFont) -> CometChatDialogSwiftUI {
        var dialog = self
        dialog.cancelButtonTextFont = Font(cancelButtonTextFont)
        return dialog
    }
    
    public func set(error: String) -> CometChatDialogSwiftUI {
        return set(messageText: error)
    }
    
    public func open(onConfirm: @escaping () -> Void, onCancel: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: messageText, preferredStyle: .alert)
        
        if !cancelButtonText.isEmpty {
            let cancelAction = UIAlertAction(title: cancelButtonText, style: .cancel) { _ in
                onCancel()
            }
            alertController.addAction(cancelAction)
        }
        
        if !confirmButtonText.isEmpty {
            let confirmAction = UIAlertAction(title: confirmButtonText, style: .default) { _ in
                onConfirm()
            }
            alertController.addAction(confirmAction)
        }
        
        if let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows }).first(where: { $0.isKeyWindow }) {
            DispatchQueue.main.async {
                if let presentedVC = window.rootViewController?.presentedViewController {
                    presentedVC.present(alertController, animated: true)
                } else {
                    window.rootViewController?.present(alertController, animated: true)
                }
            }
        }
    }
    
    public func open(onConfirm: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: messageText, preferredStyle: .alert)
        
        if !cancelButtonText.isEmpty {
            let cancelAction = UIAlertAction(title: cancelButtonText, style: .cancel) { _ in }
            alertController.addAction(cancelAction)
        }
        
        if !confirmButtonText.isEmpty {
            let confirmAction = UIAlertAction(title: confirmButtonText, style: .default) { _ in
                onConfirm()
            }
            alertController.addAction(confirmAction)
        }
        
        if let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows }).first(where: { $0.isKeyWindow }) {
            DispatchQueue.main.async {
                if let presentedVC = window.rootViewController?.presentedViewController {
                    presentedVC.present(alertController, animated: true)
                } else {
                    window.rootViewController?.present(alertController, animated: true)
                }
            }
        }
    }
    
    public func open() {
        let alertController = UIAlertController(title: title, message: messageText, preferredStyle: .alert)
        
        if !cancelButtonText.isEmpty {
            let cancelAction = UIAlertAction(title: cancelButtonText, style: .cancel) { _ in }
            alertController.addAction(cancelAction)
        }
        
        if !confirmButtonText.isEmpty {
            let confirmAction = UIAlertAction(title: confirmButtonText, style: .default) { _ in }
            alertController.addAction(confirmAction)
        }
        
        if let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows }).first(where: { $0.isKeyWindow }) {
            DispatchQueue.main.async {
                if let presentedVC = window.rootViewController?.presentedViewController {
                    presentedVC.present(alertController, animated: true)
                } else {
                    window.rootViewController?.present(alertController, animated: true)
                }
            }
        }
    }
}

struct CometChatDialogSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("CometChatDialogSwiftUI Preview")
                .font(.headline)
            
            Text("This component uses UIAlertController under the hood")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Configuration Example:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Title: 'Confirmation'")
                Text("Message: 'Are you sure you want to proceed?'")
                Text("Confirm Button: 'Yes'")
                Text("Cancel Button: 'No'")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Button("Show Dialog (Not functional in preview)") {
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
