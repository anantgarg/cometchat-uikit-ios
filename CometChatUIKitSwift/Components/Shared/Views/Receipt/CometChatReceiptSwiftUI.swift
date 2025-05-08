//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatReceiptSwiftUI: View {
    public static var style = ReceiptStyle() // global styling
    private var style: ReceiptStyle
    private var disableReceipt: Bool = false
    private var receiptStatus: ReceiptStatus?
    
    public init(style: ReceiptStyle = CometChatReceiptSwiftUI.style) {
        self.style = style
    }
    
    public var body: some View {
        if !disableReceipt, let status = receiptStatus {
            Image(uiImage: getImageForStatus(status))
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color(getTintColorForStatus(status)))
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
        } else {
            EmptyView()
        }
    }
    
    private func getImageForStatus(_ status: ReceiptStatus) -> UIImage {
        switch status {
        case .failed:
            return style.errorImage
        case .delivered:
            return style.deliveredImage
        case .inProgress:
            return style.waitImage
        case .read:
            return style.readImage
        case .sent:
            return style.sentImage
        }
    }
    
    private func getTintColorForStatus(_ status: ReceiptStatus) -> UIColor {
        switch status {
        case .failed:
            return style.errorImageTintColor
        case .delivered:
            return style.deliveredImageTintColor
        case .inProgress:
            return style.waitImageTintColor
        case .read:
            return style.readImageTintColor
        case .sent:
            return style.sentImageTintColor
        }
    }
    
    public func disable(receipt: Bool) -> CometChatReceiptSwiftUI {
        var view = self
        view.disableReceipt = receipt
        return view
    }
    
    public func set(receipt status: ReceiptStatus) -> CometChatReceiptSwiftUI {
        var view = self
        view.receiptStatus = status
        return view
    }
}

extension CometChatReceiptSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatReceiptSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                CometChatReceiptSwiftUI()
                    .set(receipt: .sent)
                    .previewDisplayName("Sent")
                
                CometChatReceiptSwiftUI()
                    .set(receipt: .delivered)
                    .previewDisplayName("Delivered")
                
                CometChatReceiptSwiftUI()
                    .set(receipt: .read)
                    .previewDisplayName("Read")
                
                CometChatReceiptSwiftUI()
                    .set(receipt: .inProgress)
                    .previewDisplayName("In Progress")
                
                CometChatReceiptSwiftUI()
                    .set(receipt: .failed)
                    .previewDisplayName("Failed")
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            
            VStack(spacing: 20) {
                CometChatReceiptSwiftUI()
                    .set(receipt: .sent)
                
                CometChatReceiptSwiftUI()
                    .set(receipt: .delivered)
                
                CometChatReceiptSwiftUI()
                    .set(receipt: .read)
                
                CometChatReceiptSwiftUI()
                    .set(receipt: .inProgress)
                
                CometChatReceiptSwiftUI()
                    .set(receipt: .failed)
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        }
    }
}
