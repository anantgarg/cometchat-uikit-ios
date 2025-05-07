//
//
//

import Foundation
import SwiftUI

public class ThumbnailGenerationExtensionSwiftUI: ExtensionDataSource {
    override public init() {}

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            ThumbnailGenerationViewModelSwiftUI(dataSource: dataSource)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.thumbnailGeneration
    }
}
