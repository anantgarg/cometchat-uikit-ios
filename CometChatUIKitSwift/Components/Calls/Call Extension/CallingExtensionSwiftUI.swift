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
    
    public override func enable() {
        ChatConfigurator.enable { dataSource in
            return CallingExtensionDecoratorSwiftUI(dataSource: dataSource, configuration: configuration)
        }
    }
    
    public override func getExtensionId() -> String {
        return "Calling-Extension-SwiftUI"
    }
}

#endif
