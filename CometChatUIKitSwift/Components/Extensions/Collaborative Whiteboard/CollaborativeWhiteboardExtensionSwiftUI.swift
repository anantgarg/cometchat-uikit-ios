//
//
//

import Foundation
import SwiftUI

public class CollaborativeWhiteboardExtensionSwiftUI: ExtensionDataSource {
    
    public override init() {}
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return CollaborativeWhiteboardViewModelSwiftUI(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.whiteboard
    }
}
