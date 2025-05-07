//
//  File.swift
//
//
//  Created by Pushpsen Airekar on 18/02/23.
//
import Foundation

class CollaborativeDocumentConfiguration {}

public class CollaborativeDocumentExtension: ExtensionDataSource {
    override public init() {}

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            CollaborativeDocumentViewModel(dataSource: dataSource)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.document
    }
}
