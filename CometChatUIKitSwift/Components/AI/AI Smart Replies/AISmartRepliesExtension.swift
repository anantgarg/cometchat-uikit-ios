//
//  AISmartRepliesExtension.swift
//
//
//  Created by SuryanshBisen on 12/09/23.
//

import CometChatSDK
import Foundation

public class AISmartRepliesExtension: ExtensionDataSource {
    private let configuration: AISmartRepliesConfiguration?

    public init(configuration: AISmartRepliesConfiguration? = nil) {
        self.configuration = configuration
        super.init()
    }

    override public func enable() {
        CometChat.isAIFeatureEnabled(feature: getExtensionId(), onSuccess: {
            success in
            if success {
                self.addExtension()
            }
        }, onError: {
            _ in
        })
    }

    override public func addExtension() {
//        ChatConfigurator.enable { dataSource in
//            return AISmartRepliesDecorator(dataSource: dataSource, configuration: configuration)
//        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.aiSmartReply
    }
}
