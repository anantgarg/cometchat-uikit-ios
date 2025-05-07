//
//  MessageTranslationExtension.swift
//
//
//  Created by Ajay Verma on 24/02/23.
//

import Foundation

public class MessageTranslationExtension: ExtensionDataSource {
    override public init() {}

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            MessageTranslationViewModel(dataSource: dataSource)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.messageTranslation
    }
}
