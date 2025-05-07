//
//  GroupsShimmerView.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 16/10/24.
//

import Foundation
import UIKit

open class GroupsShimmerView: CometChatShimmerView {
    public var cellCount = 20
    var cellCountManager = 0 // for managing cell count internally

    override open func buildUI() {
        super.buildUI()
        backgroundColor = CometChatTheme.backgroundColor01
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
            listItem.titleStack.spacing = 8
            listItem.titleStack.alignment = .leading
            listItem.titleLabel.pin(anchors: [.width], to: 160)
            listItem.titleLabel.pin(anchors: [.height], to: 22)
            listItem.titleLabel.roundViewCorners(corner: .init(cornerRadius: 11))

            listItem.avatarHeightConstraint.constant = 40
            listItem.avatarWidthConstraint.constant = 40

            addShimmer(view: listItem.avatar, size: CGSize(width: 48, height: 48))
            addShimmer(view: listItem.titleLabel, size: CGSize(width: 160, height: 22))

            // Subtitle View
            let subtitleView = UIView().withoutAutoresizingMaskConstraints()
            subtitleView.pin(anchors: [.height], to: 12)
            subtitleView.pin(anchors: [.width], to: 80)
            subtitleView.roundViewCorners(corner: .init(cornerRadius: 6))
            listItem.set(subtitle: subtitleView)

            addShimmer(view: subtitleView, size: CGSize(width: 80, height: 12))

            return listItem
        }

        return UITableViewCell()
    }
}
