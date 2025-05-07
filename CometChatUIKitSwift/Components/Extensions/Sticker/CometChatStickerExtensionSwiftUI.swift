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
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return StickersExtensionDecoratorSwiftUI(dataSource: dataSource, configuration: configuration)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.stickers
    }
}
