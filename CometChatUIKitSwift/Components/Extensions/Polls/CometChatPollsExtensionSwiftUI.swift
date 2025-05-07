//
//
//

import Foundation
import SwiftUI

public class CometChatPollsExtensionSwiftUI: ExtensionDataSource {
    
    public override init() {}
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return CometChatPollsViewModelSwiftUI(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.polls
    }
}
