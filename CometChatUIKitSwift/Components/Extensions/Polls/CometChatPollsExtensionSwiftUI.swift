//
//
//

import Foundation
import SwiftUI

public class CometChatPollsExtensionSwiftUI: ExtensionDataSource {
    override public init() {}

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            CometChatPollsViewModelSwiftUI(dataSource: dataSource)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.polls
    }
}
