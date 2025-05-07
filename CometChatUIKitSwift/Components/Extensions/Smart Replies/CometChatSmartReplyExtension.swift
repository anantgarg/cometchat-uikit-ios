//
//  CometChatSmartReplyExtension.swift
//
//
//  Created by Pushpsen Airekar on 16/02/23.
//
import Foundation

public class CometChatSmartReplyExtension: ExtensionDataSource {
    override public init() {}

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            SmartReplyExtensionDecorator(dataSource: dataSource)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.smartReply
    }
}
