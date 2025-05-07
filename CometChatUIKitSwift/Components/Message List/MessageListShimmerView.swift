//
//  MessageListShimmerView.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 28/09/24.
//

import Foundation
import UIKit

open class CometChatMessageShimmerView: CometChatShimmerView {
    public var dataSource: [(alignment: MessageBubbleAlignment, size: CGSize)] = [
        (alignment: .left, size: .init(width: 276, height: 53)),
        (alignment: .right, size: .init(width: 286, height: 53)),
        (alignment: .left, size: .init(width: 273, height: 53)),
        (alignment: .right, size: .init(width: 160, height: 53)),
        (alignment: .right, size: .init(width: 222, height: 69)),
        (alignment: .left, size: .init(width: 198, height: 53)),
        (alignment: .left, size: .init(width: 267, height: 53)),
        (alignment: .left, size: .init(width: 172, height: 53)),
        (alignment: .left, size: .init(width: 276, height: 53)),
        (alignment: .right, size: .init(width: 286, height: 53)),
        (alignment: .left, size: .init(width: 273, height: 53)),
        (alignment: .right, size: .init(width: 160, height: 53)),
        (alignment: .right, size: .init(width: 222, height: 69)),
        (alignment: .left, size: .init(width: 198, height: 53)),
        (alignment: .left, size: .init(width: 267, height: 53)),
        (alignment: .left, size: .init(width: 172, height: 53)),
    ]
    public var isGroupMode = false
    var isAnimation = false

    override public init() {
        super.init()
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.separatorColor = .clear
        tableView.register(CometChatMessageBubble.self, forCellReuseIdentifier: CometChatMessageBubble.identifier)
    }

    override open func startShimmer() {
        isAnimation = true
        tableView.reloadData()
    }

    override open func stopShimmer() {
        isAnimation = false
        tableView.reloadData()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        isAnimation == true ? dataSource.count : 0
    }

    override open func numberOfSections(in _: UITableView) -> Int {
        isAnimation == true ? 1 : 0
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CometChatMessageBubble.identifier, for: indexPath) as? CometChatMessageBubble {
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            let simmerData = dataSource[indexPath.row]
            cell.set(bubbleAlignment: simmerData.alignment)

            let messageContainerView = UIView().withoutAutoresizingMaskConstraints()
            messageContainerView.roundViewCorners(corner: .init(cornerRadius: 8))
            messageContainerView.pin(anchors: [.height], to: simmerData.size.height)
            messageContainerView.pin(anchors: [.width], to: simmerData.size.width)
            addShimmer(view: messageContainerView, size: simmerData.size)

            if isGroupMode, simmerData.alignment == .left {
                let headerView = UIView().withoutAutoresizingMaskConstraints()
                headerView.pin(anchors: [.height], to: 12)
                headerView.pin(anchors: [.width], to: 120)
                headerView.roundViewCorners(corner: .init(cornerRadius: CometChatSpacing.Radius.r1))
                addShimmer(view: headerView, size: CGSize(width: 120, height: 12))
                cell.set(headerView: headerView)

                addShimmer(view: cell.avatar, size: simmerData.size)
                cell.hide(avatar: false)

            } else {
                cell.hide(avatar: true)
            }

            cell.set(contentView: messageContainerView)

            return cell
        }
        return UITableViewCell()
    }
}
