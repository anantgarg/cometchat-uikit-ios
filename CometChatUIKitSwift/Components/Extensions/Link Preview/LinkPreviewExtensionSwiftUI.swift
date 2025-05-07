//
//
//

import Foundation
import SwiftUI

public class LinkPreviewExtensionSwiftUI: ExtensionDataSource {
    
    public override init() {}
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return LinkPreviewViewModelSwiftUI(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.linkPreview
    }
}
