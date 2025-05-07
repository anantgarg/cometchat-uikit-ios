//
//
//

import Combine
import CometChatSDK
import Foundation
import SwiftUI

class ThumbnailGenerationConfigurationSwiftUI {}

public class ThumbnailGenerationViewModelSwiftUI: DataSourceDecorator {
    var thumbnailGenerationTypeConstant = ExtensionConstants.thumbnailGeneration
    var configuration: ThumbnailGenerationConfigurationSwiftUI?
    var loggedInUser = CometChat.getLoggedInUser()
    private var cancellables = Set<AnyCancellable>()

    override public init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }

    override public func getId() -> String {
        "thumbnail-generator"
    }

    override public func getImageMessageBubble(imageUrl _: String?, caption: String?, message: MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        guard let message else { return UIView() }
        if let thumbnailURL = checkForThumbnail(message: message) {
            return super.getImageMessageBubble(imageUrl: thumbnailURL, caption: caption, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
        } else {
            return super.getImageMessageBubble(imageUrl: message.attachment?.fileUrl, caption: caption, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
        }
    }

    override public func getVideoMessageBubble(videoUrl: String?, thumbnailUrl: String?, message: MediaMessage?, controller: UIViewController?, style: VideoBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        guard let message else { return UIView() }
        if let thumbnailURL = checkForThumbnail(message: message) {
            return super.getVideoMessageBubble(videoUrl: videoUrl, thumbnailUrl: thumbnailURL, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
        } else {
            return super.getVideoMessageBubble(videoUrl: videoUrl, thumbnailUrl: thumbnailUrl, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
        }
    }

    public func getImageMessageBubblePublisher(imageUrl _: String?, caption: String?, message: MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> AnyPublisher<UIView?, Never> {
        guard let message else { return Just(UIView()).eraseToAnyPublisher() }
        if let thumbnailURL = checkForThumbnail(message: message) {
            return super.getImageMessageBubblePublisher(imageUrl: thumbnailURL, caption: caption, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration) ?? Just(UIView()).eraseToAnyPublisher()
        } else {
            return super.getImageMessageBubblePublisher(imageUrl: message.attachment?.fileUrl, caption: caption, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration) ?? Just(UIView()).eraseToAnyPublisher()
        }
    }

    public func getVideoMessageBubblePublisher(videoUrl: String?, thumbnailUrl: String?, message: MediaMessage?, controller: UIViewController?, style: VideoBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> AnyPublisher<UIView?, Never> {
        guard let message else { return Just(UIView()).eraseToAnyPublisher() }
        if let thumbnailURL = checkForThumbnail(message: message) {
            return super.getVideoMessageBubblePublisher(videoUrl: videoUrl, thumbnailUrl: thumbnailURL, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration) ?? Just(UIView()).eraseToAnyPublisher()
        } else {
            return super.getVideoMessageBubblePublisher(videoUrl: videoUrl, thumbnailUrl: thumbnailUrl, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration) ?? Just(UIView()).eraseToAnyPublisher()
        }
    }

    public func getThumbnailGeneration(message: MediaMessage) -> String? {
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), !map.isEmpty, map.containsKey(ExtensionConstants.thumbnailGeneration),
           let thumbnailGeneration = map[ExtensionConstants.thumbnailGeneration], let url = thumbnailGeneration["url_medium"] as? String
        {
            url
        } else {
            nil
        }
    }

    public func checkForThumbnail(message: MediaMessage) -> String? {
        if let mediumURL = getThumbnailGeneration(message: message) {
            mediumURL
        } else {
            message.attachment?.fileUrl
        }
    }

    public func getThumbnailURLPublisher(for message: MediaMessage) -> AnyPublisher<String?, Never> {
        Just(checkForThumbnail(message: message)).eraseToAnyPublisher()
    }
}
