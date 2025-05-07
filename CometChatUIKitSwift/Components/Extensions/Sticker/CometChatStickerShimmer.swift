//
//  CometChatStickerShimmer.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 11/10/24.
//

import Foundation
import UIKit

open class CometChatStickerShimmer: CometChatShimmerView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public var cellCount = 12
    var cellCountManager = 0 // for managing cell count internally
    let spacing = CometChatSpacing.Spacing.s4 // Space between cells
    let numberOfCellsPerRow = 4.0

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).withoutAutoresizingMaskConstraints()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(StickerCell.self, forCellWithReuseIdentifier: "StickerCell")
        return collectionView
    }()

    override open func buildUI() {
        super.buildUI()
        withoutAutoresizingMaskConstraints()
        embed(collectionView)
        collectionView.pin(anchors: [.height], to: 250)
    }

    override open func startShimmer() {
        cellCountManager = cellCount
        collectionView.reloadData()
    }

    override open func stopShimmer() {
        cellCountManager = 0
        collectionView.reloadData()
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        cellCountManager
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! StickerCell
        cell.stickerIcon.layer.cornerRadius = 8
        let totalSpacing = (numberOfCellsPerRow - 1) * spacing
        let availableWidth = collectionView.frame.width - totalSpacing
        let cellWidth = availableWidth / numberOfCellsPerRow
        addShimmer(view: cell.stickerIcon, size: CGSize(width: cellWidth, height: cellWidth))
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let totalSpacing = (numberOfCellsPerRow - 1) * spacing
        let availableWidth = collectionView.frame.width - totalSpacing
        let cellWidth = availableWidth / numberOfCellsPerRow
        return CGSize(width: cellWidth, height: cellWidth)
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        // This is the spacing between rows
        CometChatSpacing.Spacing.s5
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        // This is the spacing between items in the same row
        CometChatSpacing.Spacing.s4
    }
}
