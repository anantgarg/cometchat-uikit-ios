//
//
//

import Foundation
import SwiftUI

public class CollaborativeDocumentExtensionSwiftUI: ExtensionDataSource {
    override public init() {}

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            CollaborativeDocumentViewModelSwiftUI(dataSource: dataSource)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.document
    }
}
