//
//
//

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class CallBubbleViewModelSwiftUI: ObservableObject {
    @Published var callType: CometChatSDK.CallType = .audio
    @Published var audioCallTitleText = "MESSAGE_AUDIO".localize()
    @Published var videoCallTitleText = "MESSAGE_VIDEO".localize()
    @Published var dateText: String = ""
    
    public init() {}
    
    public func set(callType: CometChatSDK.CallType) {
        DispatchQueue.main.async {
            self.callType = callType
        }
    }
    
    public func set(audioCallTitleText: String) {
        DispatchQueue.main.async {
            self.audioCallTitleText = audioCallTitleText
        }
    }
    
    public func set(videoCallTitleText: String) {
        DispatchQueue.main.async {
            self.videoCallTitleText = videoCallTitleText
        }
    }
    
    public func set(dateText: String) {
        DispatchQueue.main.async {
            self.dateText = dateText
        }
    }
}
