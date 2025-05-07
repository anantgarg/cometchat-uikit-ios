//
//  CallActionBubbleStyle.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 05/11/24.
//

import Foundation
import UIKit

public struct CallActionBubbleStyle {
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor02

    public var callImage: UIImage?

    public var callImageTintColor: UIColor = CometChatTheme.iconColorSecondary

    public var missedCallImageTintColor: UIColor = CometChatTheme.errorColor

    public var borderWidth: CGFloat = 1

    public var borderColor: UIColor = CometChatTheme.borderColorDefault

    public var cornerRadius: CometChatCornerStyle?

    public var callTextFont: UIFont = CometChatTypography.Caption1.regular

    public var callTextColor: UIColor = CometChatTheme.textColorSecondary

    public var missedCallTextFont: UIFont = CometChatTypography.Caption1.regular

    public var missedCallTextColor: UIColor = CometChatTheme.errorColor

    public init() {}
}
