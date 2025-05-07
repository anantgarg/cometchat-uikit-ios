//
//  StickerExtension.swift
//
//
//  Created by Pushpsen Airekar on 15/02/23.
//

import Foundation

public class CometChatStickerExtension: ExtensionDataSource {
    var configuration: StickerConfiguration?

    public init(configuration: StickerConfiguration? = nil) {
        self.configuration = configuration
    }

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            StickersExtensionDecorator(dataSource: dataSource, configuration: configuration)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.stickers
    }
}
