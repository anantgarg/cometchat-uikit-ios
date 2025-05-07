//
//
//

import CometChatSDK
import Foundation
import SwiftUI

public class ProfanityDataMaskingExtensionSwiftUI: ExtensionDataSource {
    override public init() {}

    var addedExtension = true

    override public func addExtension() {
        if addedExtension {
            ChatConfigurator.enable { dataSource in
                ProfanityDataMaskingExtensionDecoratorSwiftUI(dataSource: dataSource)
            }
            addedExtension = false
        }
    }

    override public func enable() {
        CometChat.isExtensionEnabled(extensionId: ExtensionConstants.profanityFilter, onSuccess: { success in
            if success {
                self.addExtension()
            }
        }, onError: {
            _ in
        })

        CometChat.isExtensionEnabled(extensionId: getExtensionId(), onSuccess: { success in
            if success {
                self.addExtension()
            }
        }, onError: {
            _ in
        })
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.dataMasking
    }
}
