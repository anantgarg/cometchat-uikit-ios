//
//  ProfanityDataMaskingExtension.swift
//
//
//  Created by Pushpsen Airekar on 21/02/23.
//
import CometChatSDK
import Foundation

public class ProfanityDataMaskingExtension: ExtensionDataSource {
    override public init() {}

    var addedExtension = true

    override public func addExtension() {
        if addedExtension {
            ChatConfigurator.enable { dataSource in
                ProfanityDataMaskingExtensionDecorator(dataSource: dataSource)
            }
            addedExtension = false
        }
    }

    override public func enable() {
        CometChat.isExtensionEnabled(extensionId: ExtensionConstants.profanityFilter, onSuccess: { success in
            if success {
                self.addExtension()
            }
        }, onError: {
            _ in
        })

        CometChat.isExtensionEnabled(extensionId: getExtensionId(), onSuccess: { success in
            if success {
                self.addExtension()
            }
        }, onError: {
            _ in
        })
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.dataMasking
    }
}
