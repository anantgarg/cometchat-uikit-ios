//
//
//

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class MessageInformationViewModelSwiftUI: ObservableObject {
    @Published var receipts: [MessageReceipt] = []
    @Published var message: BaseMessage?
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    @Published var errorMessage: String = ""
    
    var onError: ((CometChatException?) -> Void)?
    
    public init() {}
    
    deinit {
        disconnect()
    }
    
    public func connect() {
        CometChatMessageEvents.addListener("message-information-messages-listener", self as? CometChatMessageEventListener)
    }
    
    public func disconnect() {
        CometChatMessageEvents.removeListener("message-information-messages-listener")
    }
    
    public func getMessageReceipt(information forMessage: BaseMessage) {
        self.message = forMessage
        receipts.removeAll()
        isLoading = true
        
        if forMessage.receiverType == .user { // If user, we are getting the receipt from the Base Message
            if let receiptSender = forMessage.receiver as? User {
                let readReceipt = MessageReceipt(
                    messageId: "\(forMessage.id)",
                    sender: receiptSender,
                    receiverId: CometChatUIKit.getLoggedInUser()?.uid ?? "",
                    receiverType: .user,
                    receiptType: .read,
                    timeStamp: Int(forMessage.readAt)
                )
                
                readReceipt.deliveredAt = forMessage.deliveredAt
                readReceipt.readAt = forMessage.readAt
                
                let deliveredReceipt = MessageReceipt(
                    messageId: "\(forMessage.id)",
                    sender: receiptSender,
                    receiverId: CometChatUIKit.getLoggedInUser()?.uid ?? "",
                    receiverType: .user,
                    receiptType: .delivered,
                    timeStamp: Int(forMessage.deliveredAt)
                )
                
                deliveredReceipt.deliveredAt = forMessage.deliveredAt
                deliveredReceipt.readAt = forMessage.readAt
                
                DispatchQueue.main.async {
                    self.receipts.append(readReceipt)
                    self.receipts.append(deliveredReceipt)
                    self.isLoading = false
                }
            }
        } else { // For groups, fetch receipts from the API
            CometChat.getMessageReceipts(forMessage.id, onSuccess: { [weak self] (fetchedReceipts) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.receipts = fetchedReceipts
                    self.isLoading = false
                }
            }) { [weak self] (error) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.hasError = true
                    if let error = error {
                        self.errorMessage = error.errorDescription
                        self.onError?(error)
                    }
                }
            }
        }
    }
    
    public func update(receipt: MessageReceipt) {
        if receipt.messageId == String(message?.id ?? 0) {
            if let index = self.receipts.firstIndex(where: {
                $0.sender?.uid == receipt.sender?.uid
            }) {
                var updatedReceipt = self.receipts[index]
                
                switch receipt.receiptType {
                case .delivered:
                    if updatedReceipt.deliveredAt == 0.0 {
                        updatedReceipt.deliveredAt = receipt.deliveredAt
                    }
                case .read:
                    if updatedReceipt.readAt == 0.0 {
                        updatedReceipt.readAt = receipt.readAt
                    }
                case .deliveredToAll, .readByAll, .unread, .unknown:
                    break
                @unknown default:
                    break
                }
                
                DispatchQueue.main.async {
                    self.receipts[index] = updatedReceipt
                }
            } else {
                DispatchQueue.main.async {
                    self.receipts.append(receipt)
                }
            }
        }
    }
}

extension MessageInformationViewModelSwiftUI: CometChatMessageEventListener {
    public func onMessagesRead(receipt: MessageReceipt) {
        update(receipt: receipt)
    }
    
    public func onMessagesDelivered(receipt: MessageReceipt) {
        update(receipt: receipt)
    }
}
