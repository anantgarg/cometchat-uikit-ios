//
//
//

import SwiftUI
import CometChatSDK
import MessageUI

public struct CometChatTextBubbleSwiftUI: View {
    private var style: TextBubbleStyle
    private var text: String?
    private var attributedText: NSAttributedString?
    @State private var showMailView = false
    @State private var emailRecipient: String?
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    public init(style: TextBubbleStyle = TextBubbleStyle()) {
        self.style = style
    }
    
    public var body: some View {
        VStack {
            if let attributedText = attributedText {
                AttributedText(attributedText: attributedText)
                    .frame(maxWidth: UIScreen.main.bounds.width/1.2)
                    .padding(CometChatSpacing.Padding.p3)
            } else if let text = text {
                if text.containsOnlyEmojis() {
                    Text(text)
                        .font(applyLargeSizeEmoji())
                        .foregroundColor(Color(style.textColor))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: UIScreen.main.bounds.width/1.2)
                        .padding(CometChatSpacing.Padding.p3)
                } else {
                    HyperlinkTextView(text: text, style: style)
                        .frame(maxWidth: UIScreen.main.bounds.width/1.2)
                        .padding(CometChatSpacing.Padding.p3)
                }
            }
        }
        .sheet(isPresented: $showMailView) {
            if let recipient = emailRecipient {
                MailView(recipient: recipient, isShowing: $showMailView)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK".localize()))
            )
        }
    }
    
    private func applyLargeSizeEmoji() -> Font {
        let normalFont = style.textFont
        if let text = self.text, text.containsOnlyEmojis() {
            let count = text.count
            if count == 1 {
                return Font.system(size: (normalFont.pointSize * 3.8))
            } else if count == 2 {
                return Font.system(size: (normalFont.pointSize * 2.4))
            } else if count == 3 {
                return Font.system(size: (normalFont.pointSize * 1.7))
            } else {
                return Font.system(size: normalFont.pointSize)
            }
        } else {
            return Font.system(size: normalFont.pointSize)
        }
    }
    
    public func set(text: String) -> CometChatTextBubbleSwiftUI {
        var view = self
        view.text = text
        return view
    }
    
    public func set(attributedText: NSAttributedString) -> CometChatTextBubbleSwiftUI {
        var view = self
        view.attributedText = attributedText
        return view
    }
}

struct HyperlinkTextView: UIViewRepresentable {
    let text: String
    let style: TextBubbleStyle
    
    func makeUIView(context: Context) -> HyperlinkLabel {
        let label = HyperlinkLabel()
        label.numberOfLines = 0
        label.text = text
        
        label.textColor = style.textColor
        label.font = style.textFont
        
        let phoneParser1 = HyperlinkType.custom(pattern: RegexParser.phonePattern1)
        let phoneParser2 = HyperlinkType.custom(pattern: RegexParser.phonePattern2)
        let emailParser = HyperlinkType.custom(pattern: RegexParser.emailPattern)
        
        label.enabledTypes.append(phoneParser1)
        label.enabledTypes.append(phoneParser2)
        label.enabledTypes.append(emailParser)
        
        label.customize { label in
            label.URLColor = style.textHighlightColor
            label.URLSelectedColor = style.textHighlightColor
            label.customColor[phoneParser1] = style.textHighlightColor
            label.customSelectedColor[phoneParser1] = style.textHighlightColor
            label.customColor[phoneParser2] = style.textHighlightColor
            label.customSelectedColor[phoneParser2] = style.textHighlightColor
            label.customColor[emailParser] = style.textHighlightColor
            label.customSelectedColor[emailParser] = style.textHighlightColor
            
            label.addUnderline[phoneParser1] = true
            label.addUnderline[phoneParser2] = true
            label.addUnderline[emailParser] = true
        }
        
        label.handleURLTap { link in
            UIApplication.shared.open(link)
        }
        
        label.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern1)) { (number) in
            let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let url = URL(string: "tel://\(number)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        label.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern2)) { (number) in
            let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
            if let url = URL(string: "tel://\(number)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        label.handleCustomTap(for: .custom(pattern: RegexParser.emailPattern)) { (emailID) in
            if MFMailComposeViewController.canSendMail() {
                NotificationCenter.default.post(name: NSNotification.Name("OpenMailComposer"), object: nil, userInfo: ["email": emailID])
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("ShowMailAlert"), object: nil)
            }
        }
        
        return label
    }
    
    func updateUIView(_ uiView: HyperlinkLabel, context: Context) {
        uiView.text = text
    }
}

struct AttributedText: UIViewRepresentable {
    let attributedText: NSAttributedString
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedText
    }
}

struct MailView: UIViewControllerRepresentable {
    let recipient: String
    @Binding var isShowing: Bool
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([recipient])
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.isShowing = false
        }
    }
}

extension CometChatTextBubbleSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        
        NotificationCenter.default.addObserver(
            hostingController,
            selector: #selector(UIHostingController.openMailComposer(_:)),
            name: NSNotification.Name("OpenMailComposer"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            hostingController,
            selector: #selector(UIHostingController.showMailAlert),
            name: NSNotification.Name("ShowMailAlert"),
            object: nil
        )
        
        return hostingController.view
    }
}

extension UIHostingController {
    @objc func openMailComposer(_ notification: Notification) {
        if let email = notification.userInfo?["email"] as? String,
           MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            mail.setToRecipients([email])
            self.present(mail, animated: true)
        }
    }
    
    @objc func showMailAlert() {
        let confirmDialog = CometChatDialog()
        confirmDialog.set(confirmButtonText: "OK".localize())
        confirmDialog.set(cancelButtonText: "CANCEL".localize())
        confirmDialog.set(title: "WARNING".localize())
        confirmDialog.set(messageText: "MAIL_APP_NOT_FOUND_MESSAGE".localize())
        confirmDialog.open(onConfirm: {})
    }
}

struct CometChatTextBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatTextBubbleSwiftUI()
                .set(text: "This is a sample text with a link: https://www.cometchat.com and email: support@cometchat.com")
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Text with Links")
            
            CometChatTextBubbleSwiftUI()
                .set(text: "😀😁😂")
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Emoji Text")
            
            CometChatTextBubbleSwiftUI()
                .set(text: "Call me at +1 (123) 456-7890")
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Phone Number")
        }
    }
}
