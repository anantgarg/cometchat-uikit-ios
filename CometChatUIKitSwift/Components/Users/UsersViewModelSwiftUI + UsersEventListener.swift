//
//
//
//

import CometChatSDK
import Foundation

extension UsersViewModelSwiftUI: CometChatUserDelegate {
    public func onUserOnline(user: User) {
        user.status = .online
        update(user: user)
    }

    public func onUserOffline(user: User) {
        user.status = .offline
        update(user: user)
    }
}

extension UsersViewModelSwiftUI: CometChatUserEventListener {
    public func ccUserUnblocked(user: CometChatSDK.User) {
        user.blockedByMe = false
        update(user: user)
    }

    public func ccUserBlocked(user: User) {
        user.blockedByMe = true
        update(user: user)
    }
}
