//
//
//

import Foundation
import SwiftUI

public class CometChatSmartReplyExtensionSwiftUI: ExtensionDataSource {
    
    public override init() {}
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return SmartReplyExtensionDecoratorSwiftUI(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.smartReply
    }
}
