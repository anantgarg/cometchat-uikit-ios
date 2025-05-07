//
//
//

import Foundation
import SwiftUI

public class CometChatStickerExtensionSwiftUI: ExtensionDataSource {
    var configuration: StickerConfiguration?

    public init(configuration: StickerConfiguration? = nil) {
        super.init()
        self.configuration = configuration
    }

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            StickersExtensionDecoratorSwiftUI(dataSource: dataSource, configuration: configuration)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.stickers
    }
}
