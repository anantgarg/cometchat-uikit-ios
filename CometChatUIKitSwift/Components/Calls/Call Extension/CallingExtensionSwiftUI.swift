//
//
//
//

import SwiftUI

#if canImport(CometChatCallsSDK)

    public class CallingExtensionSwiftUI: ExtensionDataSource {
        private let configuration: CallingConfigurationSwiftUI?

        public init(configuration: CallingConfigurationSwiftUI? = nil) {
            self.configuration = configuration
            super.init()
        }

        override public func enable() {
            ChatConfigurator.enable { dataSource in
                CallingExtensionDecoratorSwiftUI(dataSource: dataSource, configuration: configuration)
            }
        }

        override public func getExtensionId() -> String {
            "Calling-Extension-SwiftUI"
        }
    }

#endif
