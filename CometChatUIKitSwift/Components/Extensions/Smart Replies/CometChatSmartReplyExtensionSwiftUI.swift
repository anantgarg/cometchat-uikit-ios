//
//
//

import Foundation
import SwiftUI

public class CometChatSmartReplyExtensionSwiftUI: ExtensionDataSource {
    override public init() {}

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            SmartReplyExtensionDecoratorSwiftUI(dataSource: dataSource)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.smartReply
    }
}
