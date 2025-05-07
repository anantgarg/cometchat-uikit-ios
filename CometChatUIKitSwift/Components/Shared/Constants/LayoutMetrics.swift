//
//
//

import CoreGraphics
import Foundation

public enum LayoutMetrics {
    public static let avatarDefault: CGFloat = 36
    public static let avatarSmall: CGFloat = 24
    public static let avatarMedium: CGFloat = 40
    public static let avatarLarge: CGFloat = 48

    public static let spacingStandard: CGFloat = 8
    public static let spacingSmall: CGFloat = 4
    public static let spacingMedium: CGFloat = 12
    public static let spacingLarge: CGFloat = 16
    public static let spacingExtraLarge: CGFloat = 24

    public static let cornerRadiusStandard: CGFloat = 8
    public static let cornerRadiusSmall: CGFloat = 4
    public static let cornerRadiusMedium: CGFloat = 12
    public static let cornerRadiusLarge: CGFloat = 16
    public static let cornerRadiusRound: CGFloat = 24

    public static let buttonMinWidth: CGFloat = 20
    public static let buttonStandardHeight: CGFloat = 20

    public static let badgeMinWidth: CGFloat = 20
    public static let badgeHeight: CGFloat = 20

    public static let bubblePadding: CGFloat = 8

    public static let iconSize: CGFloat = 16
    public static let smallIconSize: CGFloat = 12
    public static let mediumIconSize: CGFloat = 20
    public static let largeIconSize: CGFloat = 24

    public static let listItemSpacing: CGFloat = 16
    public static let listItemVerticalPadding: CGFloat = 8

    public static let statusIndicatorOffset: CGFloat = 16
    public static let messageIndicatorBottomOffset: CGFloat = 100
    public static let messageIndicatorTrailingOffset: CGFloat = 80

    public static let loadingItemCount: Int = 8
    public static let loadingTextHeight: CGFloat = 12
    public static let loadingTextWidth: CGFloat = 120
    public static let loadingContentHeight: CGFloat = 60
    public static let loadingContentWidth: CGFloat = 200

    public static let spacingNone: CGFloat = 0
    public static let dividerHeight: CGFloat = 1
    public static let thinDividerHeight: CGFloat = 0.3
    public static let standardOpacity: CGFloat = 0.3
    public static let stickerKeyboardHeight: CGFloat = 250
    public static let previewWidth: CGFloat = 375

    public static let whiteboardTopImageHeight: CGFloat = 140
    public static let whiteboardIconSize: CGFloat = 32
    public static let whiteboardButtonHeight: CGFloat = 25
    public static let whiteboardBubbleWidth: CGFloat = 228
    public static let whiteboardBubbleHeight: CGFloat = 145

    public static let messageBubbleMaxWidth: CGFloat = 312 // Approximately UIScreen.main.bounds.width / 1.2 for iPhone 12
}
