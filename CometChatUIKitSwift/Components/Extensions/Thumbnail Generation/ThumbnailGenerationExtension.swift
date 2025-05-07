//
//  ThumbnailGenerationExtension.swift
//  Created by Pushpsen Airekar on 20/02/23.

import Foundation

public class ThumbnailGenerationExtension: ExtensionDataSource {
    override public init() {}

    override public func addExtension() {
        ChatConfigurator.enable { dataSource in
            ThumbnailGenerationViewModel(dataSource: dataSource)
        }
    }

    override public func getExtensionId() -> String {
        ExtensionConstants.thumbnailGeneration
    }
}
