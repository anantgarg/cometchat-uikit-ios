//
//  CometChatAISmartReply.swift
//
//
//  Created by SuryanshBisen on 13/09/23.
//

import CometChatSDK
import Foundation
import UIKit

open class CometChatAISmartReply: UIView {
    // MARK: - Properties

    public let titleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.text = "SUGGEST_A_REPLY".localize()
        return label
    }()

    public let cancelButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.pin(anchors: [.height, .width], to: 20)
        return button
    }()

    public let errorView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()

    public let errorLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.text = "SOMETHING_WENT_WRONG_WITH_NEW_LINE".localize()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    public var tableView = SelfSizingTableView().withoutAutoresizingMaskConstraints()
    public var aiMessagesList = [String]()
    public var onAiMessageClicked: ((_ selectedReply: String) -> Void)?
    public var onAiCloseButtonClicked: (() -> Void)?
    public var id: [String: Any]?
    public var loadingView: UIView!
    public var disableLoadingState: Bool = false
    public var isLoadingViewVisible = false

    public static var style = AISmartRepliesStyle()
    public lazy var style = CometChatAISmartReply.style

    // MARK: - Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInit() {
        setupDelegate()
        buildUI()
    }

    override public func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
        }
    }

    // MARK: - UI Setup

    public func setupDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AIRepliesCell.self, forCellReuseIdentifier: "AIRepliesCell")
    }

    open func buildUI() {
        loadingView = CometChatAISmartRepliesShimmer()

        // Setting up the title label and table view
        addSubview(titleLabel)
        addSubview(cancelButton)
        addSubview(tableView)

        // Configure table view properties
        backgroundColor = CometChatTheme.backgroundColor01
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        tableView.estimatedRowHeight = CGFloat(50)
        // Apply constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: CometChatSpacing.Padding.p3),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CometChatSpacing.Padding.p3),
            titleLabel.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -CometChatSpacing.Padding.p3),
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: CometChatSpacing.Padding.p3),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CometChatSpacing.Padding.p3),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CometChatSpacing.Padding.p2),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CometChatSpacing.Padding.p3),
        ])

        cancelButton.addTarget(self, action: #selector(onCloseButtonClicked), for: .touchUpInside)
    }

    open func setupStyle() {
        backgroundColor = style.backgroundColor
        borderWith(width: style.borderWidth)
        borderColor(color: style.borderColor)
        roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r4))
        applyCornerRadiusAndShadow(cornerRadius: style.cornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r4)

        titleLabel.textColor = style.titleTextColor
        titleLabel.font = style.titleTextFont
        cancelButton.setImage(style.cancelButtonImage, for: .normal)
        cancelButton.imageView?.tintColor = style.cancelButtonImageTintColor
        errorLabel.textColor = style.errorViewTextColor
        errorLabel.font = style.errorViewTextFont
    }

    public func showLoadingView() {
        if disableLoadingState { return }
        (loadingView as? CometChatShimmerView)?.startShimmer()

        isLoadingViewVisible = true

        addSubview(loadingView)

        loadingView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CometChatSpacing.Padding.p2).isActive = true
        loadingView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        loadingView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(CometChatSpacing.Padding.p)).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 217).isActive = true
        loadingView.roundViewCorners(corner: .init(cornerRadius: 16))
    }

    public func hideLoadingView() {
        (loadingView as? CometChatShimmerView)?.stopShimmer()

        isLoadingViewVisible = false

        loadingView.removeFromSuperview()
    }

    @objc func onCloseButtonClicked() {
        onAiCloseButtonClicked?()
    }

    private func updateTableViewHeight() {
        tableView.invalidateIntrinsicContentSize()
        tableView.layoutIfNeeded()
    }

    // MARK: - Public API

    @discardableResult
    @objc public func set(aiMessageOptions: [String]) -> Self {
        hideLoadingView()
        aiMessagesList = aiMessageOptions
        tableView.reloadData()
        updateTableViewHeight()
        return self
    }

    @discardableResult
    @objc public func onMessageClicked(onAiMessageClicked: @escaping ((_ selectedReply: String) -> Void)) -> Self {
        self.onAiMessageClicked = onAiMessageClicked
        return self
    }

    @discardableResult
    @objc public func set(tableViewStyle: UITableViewCell.SeparatorStyle) -> Self {
        tableView.separatorStyle = tableViewStyle
        return self
    }

    @discardableResult
    @objc public func show(error: Bool) -> Self {
        if error {
            addSubview(errorView)
            errorView.addSubview(errorLabel)
            NSLayoutConstraint.activate([
                errorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CometChatSpacing.Padding.p2),
                errorView.leadingAnchor.constraint(equalTo: leadingAnchor),
                errorView.trailingAnchor.constraint(equalTo: trailingAnchor),
                errorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CometChatSpacing.Padding.p2),

                errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
                errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor),
                errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: CometChatSpacing.Padding.p6),
                errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -CometChatSpacing.Padding.p6),
                errorLabel.topAnchor.constraint(equalTo: errorView.topAnchor, constant: CometChatSpacing.Padding.p2),
                errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor, constant: -CometChatSpacing.Padding.p2),
                errorLabel.heightAnchor.constraint(equalToConstant: 200),
            ])
        } else {
            errorView.removeFromSuperview()
        }
        return self
    }
}

// MARK: - UITableView DataSource & Delegate

extension CometChatAISmartReply: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        aiMessagesList.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AIRepliesCell", for: indexPath) as? AIRepliesCell else {
            return UITableViewCell()
        }

        let message = aiMessagesList[indexPath.row]
        cell.cellLabel.text = message
        cell.cellLabel.textColor = style.repliesTextColor
        cell.cellLabel.font = style.repliesTextFont
        cell.containerView.borderWith(width: style.repliesViewBorderWidth)
        cell.containerView.borderColor(color: style.repliesViewBorderColor)
        cell.containerView.roundViewCorners(corner: style.repliesViewCornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r2))
        cell.containerView.backgroundColor = style.repliesViewBackgroundColor
        cell.backgroundColor = .clear
        return cell
    }

    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let onClick = onAiMessageClicked?(aiMessagesList[indexPath.row]) {
            onClick
        }
    }

    public func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

public class SelfSizingTableView: UITableView {
    var maxHeight = CGFloat.infinity

    override public var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    override public var intrinsicContentSize: CGSize {
        let height = min(maxHeight, contentSize.height)
        return CGSize(width: contentSize.width, height: height)
    }
}
