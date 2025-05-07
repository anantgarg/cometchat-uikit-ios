//
//
//

import Foundation
import SwiftUI

public class MessageTranslationExtensionSwiftUI: ExtensionDataSource {
    
    public override init() {}
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return MessageTranslationViewModelSwiftUI(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.messageTranslation
    }
}
