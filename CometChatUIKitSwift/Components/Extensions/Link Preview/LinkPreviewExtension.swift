//
//  LinkPreviewExtension.swift
//
//
//  Created by Pushpsen Airekar on 19/02/23.
//

import Foundation

public class CometChatLinkPreviewExtension: ExtensionDataSource {
    override public init() {}

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            LinkPreviewViewModel(dataSource: dataSource)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.linkPreview
    }
}
