//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatCardBubbleSwiftUI: View {
    
    private var style: CardBubbleStyle = CardBubbleStyle()
    @State private var cardMessage: CardMessage?
    @State private var elementEntities: [ElementEntity]?
    @State private var image: UIImage?
    @State private var isLoading: [String: Bool] = [:]
    @State private var interactedElements: [String] = []
    private var onActionClick: ((CometChatCardBubble.Button) -> Void)?
    @State private var controller: UIViewController?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 5) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            } else if cardMessage?.getImageUrl() != nil {
                Color.gray.opacity(0.3)
                    .aspectRatio(16/9, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .onAppear {
                        loadImage()
                    }
            }
            
            if let text = cardMessage?.getText() {
                Text(text)
                    .font(Font(style.getTextFont()))
                    .foregroundColor(Color(style.getTextColor()))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ForEach(elementEntities ?? [], id: \.elementId) { entity in
                if entity.elementType == .button, let buttonElement = entity as? ButtonElement {
                    VStack(spacing: 0) {
                        Divider()
                            .frame(height: 1)
                            .background(Color(style.getButtonSeparatorColor()))
                            .padding(.top, 8)
                        
                        buttonView(buttonElement)
                    }
                }
            }
        }
        .padding(11)
        .background(Color(style.background))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
        )
    }
    
    private func buttonView(_ buttonElement: ButtonElement) -> some View {
        ZStack {
            Button(action: {
                onButtonClickAction(buttonElement)
            }) {
                Text(buttonElement.buttonText)
                    .font(Font(style.getButtonTextFont()))
                    .foregroundColor(Color(style.getButtonTextColor()))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .disabled(isLoading[buttonElement.elementId] == true || 
                     (buttonElement.disableAfterInteracted && interactedElements.contains(buttonElement.elementId)))
            .opacity(isLoading[buttonElement.elementId] == true ? 0 : 1)
            
            if isLoading[buttonElement.elementId] == true {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(style.getButtonTextColor())))
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color(style.getButtonBackgroundColor()))
        .cornerRadius(style.cornerRadius.cornerRadius)
    }
    
    private func loadImage() {
        guard let urlString = cardMessage?.getImageUrl(), let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let loadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
        }.resume()
    }
    
    private func onButtonClickAction(_ buttonElement: ButtonElement) {
        let uiButton = CometChatCardBubble.Button()
        uiButton.buttonElement = buttonElement
        
        if let onActionClick = onActionClick {
            onActionClick(uiButton)
            return
        }
        
        interactedElements.append(buttonElement.elementId)
        
        if buttonElement.action.actionType == "apiAction", let url = URL(string: buttonElement.action.url) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = buttonElement.action.method.value
            
            isLoading[buttonElement.elementId] = true
            
            do {
                var data = [String: Any]()
                data.append(with: buttonElement.action.payLoad)
                let jsonAsData = try JSONSerialization.data(withJSONObject: data, options: [])
                
                urlRequest.httpBody = jsonAsData
                if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                }
                urlRequest.allHTTPHeaderFields?.append(with: buttonElement.action.headers)
            } catch {
                print("Error preparing request: \(error)")
            }
            
            URLSession.shared.dataTask(with: urlRequest) { _, response, _ in
                DispatchQueue.main.async {
                    self.isLoading[buttonElement.elementId] = false
                }
            }.resume()
        }
        else if buttonElement.navigationAction.actionType == "urlNavigation", 
                !buttonElement.navigationAction.url.isEmpty,
                let controller = controller {
            let cometChatWebView = CometChatWebView()
            cometChatWebView.set(webViewType: .none)
                .set(url: buttonElement.navigationAction.url)
                .set(title: buttonElement.buttonText)
            controller.navigationController?.navigationBar.isHidden = false
            controller.navigationController?.isNavigationBarHidden = false
            controller.navigationController?.pushViewController(cometChatWebView, animated: true)
        }
    }
    
    public func set(cardMessage: CardMessage) -> CometChatCardBubbleSwiftUI {
        var view = self
        view._cardMessage = State(initialValue: cardMessage)
        view._elementEntities = State(initialValue: cardMessage.getCardActions())
        return view
    }
    
    public func set(style: CardBubbleStyle) -> CometChatCardBubbleSwiftUI {
        var view = self
        view.style = style
        return view
    }
    
    public func set(onActionClick: @escaping ((CometChatCardBubble.Button) -> Void)) -> CometChatCardBubbleSwiftUI {
        var view = self
        view.onActionClick = onActionClick
        return view
    }
    
    public func set(controller: UIViewController) -> CometChatCardBubbleSwiftUI {
        var view = self
        view._controller = State(initialValue: controller)
        return view
    }
}

extension CometChatCardBubbleSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatCardBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatCardBubbleSwiftUI()
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            CometChatCardBubbleSwiftUI()
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
