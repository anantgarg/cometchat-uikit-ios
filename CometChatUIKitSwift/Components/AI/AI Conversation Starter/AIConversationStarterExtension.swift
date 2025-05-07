//
//  AIConversationStarterExtension.swift
//
//
//  Created by SuryanshBisen on 13/09/23.
//

import CometChatSDK
import Foundation

public class AIConversationStarterExtension: ExtensionDataSource {
    private let configuration: AIConversationStarterConfiguration?
    private let extensionName = "Conversation Starter"

    public init(configuration: AIConversationStarterConfiguration? = nil) {
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
//            return AIConversationStarterDecorator(dataSource: dataSource, configuration: configuration)
//        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.aiConversationStarter
    }

    func getConfiguration() -> AIConversationStarterConfiguration? {
        configuration
    }

    func getExtensionName() -> String {
        extensionName
    }
}
