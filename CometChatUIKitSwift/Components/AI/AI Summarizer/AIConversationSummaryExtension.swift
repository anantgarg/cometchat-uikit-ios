//
//  AIConversationSummaryExtension.swift
//
//
//  Created by SuryanshBisen on 20/10/23.
//

import CometChatSDK
import Foundation

public class AIConversationSummaryExtension: ExtensionDataSource {
    private let configuration: AIConversationSummaryConfiguration?

    public init(configuration: AIConversationSummaryConfiguration? = nil) {
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
            AIConversationSummaryDecorator(dataSource: dataSource, configuration: configuration)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.aiConversationSummary
    }

    func getConfiguration() -> AIConversationSummaryConfiguration? {
        configuration
    }
}
