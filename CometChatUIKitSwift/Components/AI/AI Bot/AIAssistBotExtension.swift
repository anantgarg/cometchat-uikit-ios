//
//  AIAssistBotExtension.swift
//
//
//  Created by SuryanshBisen on 31/10/23.
//

import CometChatSDK
import Foundation

public class AIAssistBotExtension: ExtensionDataSource {
    private let configuration: AIAssistBotConfiguration?

    public init(configuration: AIAssistBotConfiguration? = nil) {
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
        ChatConfigurator.enable { dataSource in
            AIAssistBotDecorator(dataSource: dataSource, configuration: configuration)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.aiAssistBot
    }
}
