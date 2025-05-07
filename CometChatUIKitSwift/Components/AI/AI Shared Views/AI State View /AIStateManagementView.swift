//
//  AIStateManagementView.swift
//
//
//  Created by admin on 25/09/23.
//

import Foundation
import UIKit

class AIStateManagementView: UIStackView {
    let spinnerView = UIActivityIndicatorView()
    let mainLabel = UILabel()
    let firstSpacingView = UIView()
    let lastSpacingView = UIView()
    var iconImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        spacing = 10
        layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 20)
        isLayoutMarginsRelativeArrangement = true
        backgroundColor = CometChatTheme_v4.palatte.background

        alignment = .center

        addArrangedSubview(firstSpacingView)

        spinnerView.startAnimating()
        addArrangedSubview(spinnerView)

        addArrangedSubview(mainLabel)
        addArrangedSubview(lastSpacingView)

        mainLabel.textColor = CometChatTheme_v4.palatte.accent700
    }

    @discardableResult
    public func setHeight(height: CGFloat) -> Self {
        heightAnchor.constraint(equalToConstant: height).isActive = true
        return self
    }

    @discardableResult
    public func setStackView(axis: NSLayoutConstraint.Axis) -> Self {
        self.self.axis = axis
        if axis == .horizontal {
            firstSpacingView.isHidden = true
        } else {
            spacing = 15
            firstSpacingView.isHidden = false
            lastSpacingView.isHidden = false
            spinnerView.style = .large
            distribution = .equalCentering
        }
        layoutIfNeeded()
        return self
    }

    @discardableResult
    public func setMainText(text: String) -> Self {
        mainLabel.text = text
        return self
    }

    @discardableResult
    public func setOnlySpinnerView() -> Self {
        mainLabel.isHidden = true
        firstSpacingView.isHidden = true
        lastSpacingView.isHidden = true
        return self
    }

    @discardableResult
    public func setIcon(icon: UIImage?, iconWidth: CGFloat? = nil, iconHeight: CGFloat? = nil) -> Self {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
        addArrangedSubview(firstSpacingView)

        iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = CometChatTheme_v4.palatte.accent
        iconImageView.contentMode = .scaleAspectFit

        addArrangedSubview(iconImageView)
        iconImageView.widthAnchor.constraint(equalToConstant: iconWidth ?? 25).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: iconHeight ?? 25).isActive = true

        addArrangedSubview(mainLabel)
        addArrangedSubview(lastSpacingView)

        return self
    }

    @discardableResult
    public func setTextFont(font: UIFont) -> Self {
        mainLabel.font = font
        return self
    }

    @discardableResult
    public func setBorder(border: CGFloat) -> Self {
        borderWith(width: border)
        return self
    }

    @discardableResult
    public func setBorderRadius(radius: CometChatCornerStyle) -> Self {
        roundViewCorners(corner: radius)
        return self
    }

    @discardableResult
    public func setTextColor(color: UIColor) -> Self {
        mainLabel.textColor = color
        return self
    }

    @discardableResult
    public func setBackground(color: UIColor) -> Self {
        backgroundColor = color
        return self
    }

    @discardableResult
    public func set(iconTint: UIColor) -> Self {
        iconImageView.tintColor = iconTint
        return self
    }

    @discardableResult
    public func configurationForLoadingView(configuration: AIParentConfiguration?, style: AIParentStyle?) -> Self {
        if let style {
//            self.setTextFont(font: style.loadingViewTextFont)
//            self.setBorder(border: style.loadingViewBorder)
//            self.setBorderRadius(radius: style.loadingViewBorderRadius)
//            self.setTextColor(color: style.loadingViewTextColor)
//            self.setBackground(color: style.loadingViewBackgroundColor)
//            self.set(iconTint: style.loadingViewIconTint)
        }

        if let configuration {
            if let loadingIcon = configuration.loadingIcon {
                setIcon(icon: loadingIcon)
            }
        }

        return self
    }

    @discardableResult
    public func configurationForErrorView(configuration: AIParentConfiguration?, style: AIParentStyle?) -> Self {
        if let style {
//            self.setTextFont(font: style.errorViewTextFont)
//            self.setBorder(border: style.errorViewBorder)
//            self.setBorderRadius(radius: style.errorViewBorderRadius)
//            self.setTextColor(color: style.errorViewTextColor)
//            self.setBackground(color: style.errorViewBackgroundColor)
//            self.set(iconTint: style.errorViewIconTint)
        }

        if let configuration {
            if let errorIcon = configuration.errorIcon {
                setIcon(icon: errorIcon)
            }
        }

        return self
    }

    @discardableResult
    public func configurationForEmptyView(configuration: AIParentConfiguration?, style: AIParentStyle?) -> Self {
        if let style {
//            self.setTextFont(font: style.emptyViewTextFont)
//            self.setBorder(border: style.emptyViewBorder)
//            self.setBorderRadius(radius: style.emptyViewBorderRadius)
//            self.setTextColor(color: style.emptyViewTextColor)
//            self.setBackground(color: style.emptyViewBackgroundColor)
//            self.set(iconTint: style.errorViewIconTint)
        }

        if let configuration {
            if let errorIcon = configuration.errorIcon {
                setIcon(icon: errorIcon)
            }
        }

        return self
    }
}
