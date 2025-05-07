//
//
//

import Foundation
import CometChatSDK
import SwiftUI
import Combine

class ThumbnailGenerationConfigurationSwiftUI {}

public class ThumbnailGenerationViewModelSwiftUI: DataSourceDecorator {
    
    var thumbnailGenerationTypeConstant = ExtensionConstants.thumbnailGeneration
    var configuration: ThumbnailGenerationConfigurationSwiftUI?
    var loggedInUser = CometChat.getLoggedInUser()
    private var cancellables = Set<AnyCancellable>()
    
    public override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }
    
    public override func getId() -> String {
        return "thumbnail-generator"
    }
    
    public override func getImageMessageBubble(imageUrl: String?, caption: String?, message: MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        guard let message = message else { return UIView() }
        if let thumbnailURL = checkForThumbnail(message: message) {
            return super.getImageMessageBubble(imageUrl: thumbnailURL, caption: caption, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
        } else {
            return super.getImageMessageBubble(imageUrl: message.attachment?.fileUrl, caption: caption, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
        }
    }
    
    public override func getVideoMessageBubble(videoUrl: String?, thumbnailUrl: String?, message: MediaMessage?, controller: UIViewController?, style: VideoBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        guard let message = message else { return UIView() }
        if let thumbnailURL = checkForThumbnail(message: message) {
            return super.getVideoMessageBubble(videoUrl: videoUrl, thumbnailUrl: thumbnailURL, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
        } else {
            return super.getVideoMessageBubble(videoUrl: videoUrl, thumbnailUrl: thumbnailUrl, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
        }
    }
    
    
    public func getImageMessageBubblePublisher(imageUrl: String?, caption: String?, message: MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> AnyPublisher<UIView?, Never> {
        guard let message = message else { return Just(UIView()).eraseToAnyPublisher() }
        if let thumbnailURL = checkForThumbnail(message: message) {
            return super.getImageMessageBubblePublisher(imageUrl: thumbnailURL, caption: caption, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration) ?? Just(UIView()).eraseToAnyPublisher()
        } else {
            return super.getImageMessageBubblePublisher(imageUrl: message.attachment?.fileUrl, caption: caption, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration) ?? Just(UIView()).eraseToAnyPublisher()
        }
    }
    
    public func getVideoMessageBubblePublisher(videoUrl: String?, thumbnailUrl: String?, message: MediaMessage?, controller: UIViewController?, style: VideoBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> AnyPublisher<UIView?, Never> {
        guard let message = message else { return Just(UIView()).eraseToAnyPublisher() }
        if let thumbnailURL = checkForThumbnail(message: message) {
            return super.getVideoMessageBubblePublisher(videoUrl: videoUrl, thumbnailUrl: thumbnailURL, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration) ?? Just(UIView()).eraseToAnyPublisher()
        } else {
            return super.getVideoMessageBubblePublisher(videoUrl: videoUrl, thumbnailUrl: thumbnailUrl, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration) ?? Just(UIView()).eraseToAnyPublisher()
        }
    }
    
    public func getThumbnailGeneration(message: MediaMessage) -> String? {
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), !map.isEmpty && map.containsKey(ExtensionConstants.thumbnailGeneration),
           let thumbnailGeneration = map[ExtensionConstants.thumbnailGeneration], let url = thumbnailGeneration["url_medium"] as? String {
            return url
        } else {
            return nil
        }
    }
    
    public func checkForThumbnail(message: MediaMessage) -> String? {
        if let mediumURL = getThumbnailGeneration(message: message) {
            return mediumURL
        } else {
            return message.attachment?.fileUrl
        }
    }
    
    public func getThumbnailURLPublisher(for message: MediaMessage) -> AnyPublisher<String?, Never> {
        return Just(checkForThumbnail(message: message)).eraseToAnyPublisher()
    }
}
