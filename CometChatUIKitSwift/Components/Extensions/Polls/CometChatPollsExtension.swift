//
//  CollaborativeWhiteboardExtension.swift
//
//
//  Created by Pushpsen Airekar on 18/02/23.
//
import Foundation

public class CometChatPollsExtension: ExtensionDataSource {
    override public init() {}

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            CometChatPollsViewModel(dataSource: dataSource)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.polls
    }
}
