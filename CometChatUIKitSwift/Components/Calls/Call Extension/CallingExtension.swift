//
//  CallingExtension.swift
//
//
//  Created by Pushpsen Airekar on 14/03/23.
//

import UIKit

#if canImport(CometChatCallsSDK)
    public class CallingExtension: ExtensionDataSource {
        private let configuration: CallingConfiguration?

        public init(configuration: CallingConfiguration? = nil) {
            self.configuration = configuration
            super.init()
        }

        override public func enable() {
            ChatConfigurator.enable { dataSource in
                CallingExtensionDecoratorSwiftUI(dataSource: dataSource, configuration: configuration)
            }
        }

        override public func getExtensionId() -> String {
            "Calling-Extension"
        }
    }
#endif
