//
//
//

import Foundation
import SwiftUI

public class CollaborativeWhiteboardExtensionSwiftUI: ExtensionDataSource {
    override public init() {}

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            CollaborativeWhiteboardViewModelSwiftUI(dataSource: dataSource)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.whiteboard
    }
}
