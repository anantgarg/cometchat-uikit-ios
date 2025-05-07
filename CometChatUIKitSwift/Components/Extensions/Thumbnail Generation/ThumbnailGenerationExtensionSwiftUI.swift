//
//
//

import Foundation
import SwiftUI

public class ThumbnailGenerationExtensionSwiftUI: ExtensionDataSource {
    
    public override init() {}
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return ThumbnailGenerationViewModelSwiftUI(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.thumbnailGeneration
    }
}
