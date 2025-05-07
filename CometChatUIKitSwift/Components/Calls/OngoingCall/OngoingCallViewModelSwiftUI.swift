//
//
//

#if canImport(CometChatCallsSDK)

    import Combine
    import CometChatSDK
    import Foundation
    import SwiftUI

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
            callSettings = callSettingsBuilder.setDelegate(callEvents).build()
        }

        public func set(callWorkFlow: CallWorkFlow) {
            self.callWorkFlow = callWorkFlow
        }

        public func startCall() {
            if let authToken = CometChat.getUserAuthToken() as? NSString, let sessionId = sessionId as NSString?, let callView, let callSettings {
                CometChatCalls.generateToken(authToken: authToken, sessionID: sessionId) { token in
                    CometChatCalls.startSession(callToken: token ?? "", callSetting: callSettings, view: callView, onSuccess: { _ in
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
                if let user = OngoingCallViewModelSwiftUI.userFromDictionary(userData: user) {}
            }

            func onUserLeft(user: NSDictionary) {
                if let user = OngoingCallViewModelSwiftUI.userFromDictionary(userData: user) {}
            }

            func onUserListChanged(userList: NSArray) {
                var users: [User] = []
                for userDict in userList {
                    if let userDict = userDict as? [String: Any], let user = OngoingCallViewModelSwiftUI.userFromDictionary(userData: userDict as NSDictionary) {
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
                    if let audioDict = audioDict as? [String: Any], let audio = OngoingCallViewModelSwiftUI.audioFromDictionary(audioData: audioDict as NSDictionary) {
                        audioDevices.append(audio)
                    }
                }
                DispatchQueue.main.async {
                    self.parent.audioDevices = audioDevices
                }
            }

            func onCallSwitchedToVideo(info _: NSDictionary) {}

            func onUserMuted(info _: NSDictionary) {}

            func onRecordingToggled(info: NSDictionary) {
                if let userDict = info["user"] as? NSDictionary, let recordStarted = info["recordingStarted"], let user = OngoingCallViewModelSwiftUI.userFromDictionary(userData: userDict) {
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
                        if let call {
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

        class AudioDevice: NSObject {
            var mode: String?
            var isSelected: Bool?
        }
        
        static func userFromDictionary(userData: NSDictionary) -> User? {
            let user: User?
            let decoder = JSONDecoder()

            do {
                let user_ = try decoder.decode(UserCodable.self, from: JSONSerialization.data(withJSONObject: userData, options: []))

                user = User(uid: user_.uid, name: user_.name)
                user?.avatar = user_.avatar
                user?.link = user_.link
                user?.role = user_.role
                if let status = userData["status"] as? String {
                    if status == "offline" {
                        user?.status = .offline
                    } else {
                        user?.status = .online
                    }
                }
                user?.statusMessage = user_.statusMessage
                user?.lastActiveAt = user_.lastActiveAt ?? 0.0
                user?.hasBlockedMe = user_.hasBlockedMe ?? false
                user?.blockedByMe = user_.blockedByMe ?? false
                user?.tags = user_.tags ?? []
                user?.deactivatedAt = user_.deactivatedAt ?? 0.0

                if let metadata = userData["metadata"] as? [String: Any] {
                    user?.metadata = metadata
                }

            } catch {
                return nil
            }
            return user
        }

        static func audioFromDictionary(audioData: NSDictionary) -> AudioDevice? {
            let audio: AudioDevice?
            let decoder = JSONDecoder()

            do {
                let _audio = try decoder.decode(AudioModeCodable.self, from: JSONSerialization.data(withJSONObject: audioData, options: []))
                audio = AudioDevice()
                audio?.mode = _audio.type
                audio?.isSelected = _audio.selected

            } catch {
                return nil
            }
            return audio
        }

        struct UserCodable: Codable {
            let uid: String
            let name: String
            let avatar: String?
            let link: String?
            let role: String?
            let status: String?
            let lastActiveAt: Double?
            let statusMessage: String?
            let blockedByMe: Bool?
            let hasBlockedMe: Bool?
            let tags: [String]?
            let deactivatedAt: Double?

            private enum CodingKeys: String, CodingKey {
                case uid
                case name
                case avatar
                case link
                case role
                case status
                case lastActiveAt
                case statusMessage
                case blockedByMe
                case hasBlockedMe
                case tags
                case deactivatedAt
            }
        }

        struct AudioModeCodable: Codable {
            let type: String
            let selected: Bool

            private enum CodingKeys: String, CodingKey {
                case type
                case selected
            }
        }
    }

#endif
