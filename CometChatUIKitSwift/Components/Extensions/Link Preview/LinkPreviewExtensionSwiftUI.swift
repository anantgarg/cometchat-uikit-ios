//
//
//

import Foundation
import SwiftUI

public class LinkPreviewExtensionSwiftUI: ExtensionDataSource {
    override public init() {}

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            LinkPreviewViewModelSwiftUI(dataSource: dataSource)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.linkPreview
    }
}
