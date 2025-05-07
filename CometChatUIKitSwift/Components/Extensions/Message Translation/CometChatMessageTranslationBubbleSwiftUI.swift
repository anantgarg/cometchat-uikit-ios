//
//
//

import SwiftUI
import CometChatSDK
import MessageUI

public struct CometChatMessageTranslationBubbleSwiftUI: View {
    
    @State private var style: MessageTranslationBubbleStyle = MessageTranslationBubbleStyle()
    @State private var message: TextMessage?
    @State private var controller: UIViewController?
    @State private var originalMessage: NSAttributedString?
    @State private var translatedMessage: NSAttributedString?
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: CometChatSpacing.Padding.p2) {
            if let originalMessage = originalMessage {
                AttributedTextView(attributedText: originalMessage)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
                .background(Color(style.separatorBackgroundColor))
                .padding(.vertical, CometChatSpacing.Padding.p1)
            
            if let translatedMessage = translatedMessage {
                AttributedTextView(attributedText: translatedMessage)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Text("TRANSLATED_TEXT".localize())
                .font(Font(style.subtitleTextFont))
                .foregroundColor(Color(style.subtitleTextColor))
                .padding(.top, CometChatSpacing.Padding.p1)
        }
        .padding(CometChatSpacing.Padding.p2)
        .frame(maxWidth: UIScreen.main.bounds.width / 1.2)
    }
    
    @discardableResult
    public func set(message: TextMessage?) -> Self {
        var view = self
        view.message = message
        return view
    }
    
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        var view = self
        view.controller = controller
        return view
    }
    
    @discardableResult
    public func set(originalMessage: NSAttributedString, translatedMessage: NSAttributedString?) -> Self {
        var view = self
        view.originalMessage = originalMessage
        view.translatedMessage = translatedMessage
        return view
    }
    
    @discardableResult
    public func set(style: MessageTranslationBubbleStyle) -> Self {
        var view = self
        view.style = style
        return view
    }
    
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct AttributedTextView: UIViewRepresentable {
    let attributedText: NSAttributedString
    
    func makeUIView(context: Context) -> UITextView {
        let textView = HyperlinkLabel()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        let phoneParser1 = HyperlinkType.custom(pattern: RegexParser.phonePattern1)
        let phoneParser2 = HyperlinkType.custom(pattern: RegexParser.phonePattern2)
        let emailParser = HyperlinkType.custom(pattern: RegexParser.emailPattern)
        
        textView.enabledTypes.append(phoneParser1)
        textView.enabledTypes.append(phoneParser2)
        textView.enabledTypes.append(emailParser)
        textView.enabledTypes.append(.url)
        
        textView.customize { label in
            label.URLColor = .systemBlue
            label.URLSelectedColor = .systemBlue
            label.customColor[phoneParser1] = .systemBlue
            label.customSelectedColor[phoneParser1] = .systemBlue
            label.customColor[phoneParser2] = .systemBlue
            label.customSelectedColor[phoneParser2] = .systemBlue
            label.customColor[emailParser] = .systemBlue
            label.customSelectedColor[emailParser] = .systemBlue
        }
        
        textView.handleURLTap { url in
            UIApplication.shared.open(url)
        }
        
        textView.handleCustomTap(for: phoneParser1) { number in
            let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let url = URL(string: "tel://\(number)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        textView.handleCustomTap(for: phoneParser2) { number in
            let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
            if let url = URL(string: "tel://\(number)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        textView.handleCustomTap(for: emailParser) { emailID in
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.setToRecipients([emailID])
                
                if let topViewController = UIApplication.shared.windows.first?.rootViewController {
                    topViewController.present(mail, animated: true, completion: nil)
                }
            } else {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(confirmButtonText: "OK".localize())
                confirmDialog.set(cancelButtonText: "CANCEL".localize())
                confirmDialog.set(title: "WARNING".localize())
                confirmDialog.set(messageText: "MAIL_APP_NOT_FOUND_MESSAGE".localize())
                confirmDialog.open(onConfirm: {})
            }
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
    }
}

struct CometChatMessageTranslationBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CometChatMessageTranslationBubbleSwiftUI()
                .set(originalMessage: NSAttributedString(string: "Hello, how are you?"), 
                     translatedMessage: NSAttributedString(string: "Hola, ¿cómo estás?"))
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Message Translation Bubble")
        }
    }
}
