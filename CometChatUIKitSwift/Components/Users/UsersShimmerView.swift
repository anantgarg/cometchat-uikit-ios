//
//  UsersShimmerView.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 15/10/24.
//

import Foundation
import UIKit

open class UsersShimmerView: CometChatShimmerView {
    public var cellCount = 20
    var cellCountManager = 0 // for managing cell count internally

    override open func buildUI() {
        super.buildUI()
        tableView.register(CometChatListItem.self, forCellReuseIdentifier: CometChatListItem.identifier)
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
        if let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem {
            listItem.statusIndicator.isHidden = true
            listItem.titleStack.alignment = .leading
            listItem.titleLabel.pin(anchors: [.width], to: 160)
            listItem.titleLabel.pin(anchors: [.height], to: 22)
            listItem.titleLabel.roundViewCorners(corner: .init(cornerRadius: 11))

            listItem.avatarHeightConstraint.constant = 40
            listItem.avatarWidthConstraint.constant = 40

            addShimmer(view: listItem.avatar, size: CGSize(width: 48, height: 48))
            addShimmer(view: listItem.titleLabel, size: CGSize(width: 160, height: 22))

            return listItem
        }
        return UITableViewCell()
    }
}
