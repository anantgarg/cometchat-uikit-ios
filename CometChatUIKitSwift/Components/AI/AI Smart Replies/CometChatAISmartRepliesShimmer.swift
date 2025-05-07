//
//  CometChatAISmartRepliesShimmer.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 08/11/24.
//

import Foundation
import UIKit

open class CometChatAISmartRepliesShimmer: CometChatShimmerView {
    public var cellCount = 3
    var cellCountManager = 0 // for managing cell count internally

    override open func buildUI() {
        super.buildUI()
        backgroundColor = .clear
        tableView.register(AIRepliesCell.self, forCellReuseIdentifier: "AIRepliesCell")
    }

    override open func startShimmer() {
        cellCountManager = cellCount
        tableView.reloadData()
    }

    override open func stopShimmer() {
        cellCountManager = 0
        tableView.reloadData()
    }

    override open func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        cellCountManager
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listItem = tableView.dequeueReusableCell(withIdentifier: "AIRepliesCell", for: indexPath) as? AIRepliesCell {
            listItem.backgroundColor = .clear
            listItem.containerView.pin(anchors: [.width], to: tableView.bounds.width - CometChatSpacing.Padding.p6)
            listItem.containerView.pin(anchors: [.height], to: 63)
            listItem.containerView.roundViewCorners(corner: .init(cornerRadius: 8))

            addShimmer(view: listItem.containerView, size: CGSize(width: tableView.bounds.width - CometChatSpacing.Padding.p6, height: 63))

            return listItem
        }

        return UITableViewCell()
    }
}
