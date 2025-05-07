//
//
//

#if canImport(CometChatCallsSDK)

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class OngoingCallViewModelSwiftUI: ObservableObject {
    @Published var users: [User] = []
    @Published var audioDevices: [AudioDevice] = []
    @Published var isCallEnded: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isRecordingStarted: Bool = false
    @Published var recordingUser: User?
    
    private var callView: UIView?
    private var sessionId: String?
    private var callSettings: CometChatCallsSDK.CallSettings?
    private var callWorkFlow: CallWorkFlow?
    
    private var callEvents = CallingEvents()
    
    public init() {
        callEvents.parent = self
    }
    
    public func set(callView: UIView?) {
        self.callView = callView
    }
    
    public func set(sessionId: String?) {
        self.sessionId = sessionId
    }
    
    public func set(callSettingsBuilder: CometChatCallsSDK.CallSettingsBuilder) {
        self.callSettings = callSettingsBuilder.setDelegate(self.callEvents).build()
    }
    
    public func set(callWorkFlow: CallWorkFlow) {
        self.callWorkFlow = callWorkFlow
    }
    
    public func startCall() {
        if let authToken = CometChat.getUserAuthToken() as? NSString, let sessionId = sessionId as NSString?, let callView = callView, let callSettings = callSettings {
            CometChatCalls.generateToken(authToken: authToken, sessionID: sessionId) { token in
                CometChatCalls.startSession(callToken: token ?? "", callSetting: callSettings, view: callView, onSuccess: {_ in
                }, onError: { error in
                    DispatchQueue.main.async {
                        self.isError = true
                        self.errorMessage = error?.errorDescription ?? "Error starting call"
                    }
                })
            } onError: { error in
                DispatchQueue.main.async {
                    self.isError = true
                    self.errorMessage = error?.errorDescription ?? "Error generating token"
                }
            }
        }
    }
    
    class CallingEvents: CallsEventsDelegate {
        weak var parent: OngoingCallViewModelSwiftUI! = nil
        
        func onCallEnded() {
            if parent.callWorkFlow != .directCalling {
                CometChatCalls.endSession()
                CometChat.clearActiveCall()
                DispatchQueue.main.async {
                    self.parent.isCallEnded = true
                }
            }
        }
        
        func onCallEndButtonPressed() {
            if parent.callWorkFlow != .directCalling {
                endCall()
            } else {
                CometChatCalls.endSession()
                DispatchQueue.main.async {
                    self.parent.isCallEnded = true
                }
            }
        }
        
        func onUserJoined(user: NSDictionary) {
            if let user = OngoingCallViewModel.userFromDictionary(userData: user) {
            }
        }
        
        func onUserLeft(user: NSDictionary) {
            if let user = OngoingCallViewModel.userFromDictionary(userData: user) {
            }
        }
        
        func onUserListChanged(userList: NSArray) {
            var users: [User] = []
            for userDict in userList {
                if let userDict = userDict as? [String: Any], let user = OngoingCallViewModel.userFromDictionary(userData: userDict as NSDictionary) {
                    users.append(user)
                }
            }
            DispatchQueue.main.async {
                self.parent.users = users
            }
        }
        
        func onAudioModeChanged(audioModeList: NSArray) {
            var audioDevices: [AudioDevice] = []
            for audioDict in audioModeList {
                if let audioDict = audioDict as? [String: Any], let audio = OngoingCallViewModel.audioFromDictionary(audioData: audioDict as NSDictionary) {
                    audioDevices.append(audio)
                }
            }
            DispatchQueue.main.async {
                self.parent.audioDevices = audioDevices
            }
        }
        
        func onCallSwitchedToVideo(info: NSDictionary) {
        }
        
        func onUserMuted(info: NSDictionary) {
        }
        
        func onRecordingToggled(info: NSDictionary) {
            if let userDict = info["user"] as? NSDictionary, let recordStarted = info["recordingStarted"], let user = OngoingCallViewModel.userFromDictionary(userData: userDict) {
                if let recordingStarted = recordStarted as? Bool {
                    DispatchQueue.main.async {
                        self.parent.isRecordingStarted = recordingStarted
                        self.parent.recordingUser = user
                    }
                }
            }
        }
        
        private func endCall() {
            if let sessionId = parent.sessionId {
                CometChat.endCall(sessionID: sessionId, onSuccess: { call in
                    if let call = call {
                        DispatchQueue.main.async {
                            self.parent.isCallEnded = true
                        }
                        CometChatCallEvents.ccCallEnded(call: call)
                    }
                }, onError: { error in
                    DispatchQueue.main.async {
                        self.parent.isError = true
                        self.parent.errorMessage = error?.errorDescription ?? "Error ending call"
                    }
                })
            }
        }
    }
    
    typealias AudioDevice = OngoingCallViewModel.AudioDevice
}

#endif
