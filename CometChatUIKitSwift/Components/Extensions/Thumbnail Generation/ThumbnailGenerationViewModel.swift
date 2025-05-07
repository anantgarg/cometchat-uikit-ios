//
//  ThumbnailGenerationViewModel.swift
//
//
//  Created by Pushpsen Airekar on 18/02/23.
//

import CometChatSDK
import Foundation

class ThumbnailGenerationConfiguration {}

public class ThumbnailGenerationViewModel: DataSourceDecorator {
    var thumbnailGenerationTypeConstant = ExtensionConstants.thumbnailGeneration
    var configuration: ThumbnailGenerationConfiguration?
    var loggedInUser = CometChat.getLoggedInUser()

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
}
