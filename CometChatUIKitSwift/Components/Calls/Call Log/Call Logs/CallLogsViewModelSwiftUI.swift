//
//
//

#if canImport(CometChatCallsSDK)

    import Combine
    import CometChatSDK
    import Foundation
    import SwiftUI

    public class CallLogsViewModelSwiftUI: ObservableObject {
        @Published var callLogs: [CometChatCallsSDK.CallLog] = []
        @Published var isLoading: Bool = false
        @Published var isError: Bool = false
        @Published var isEmpty: Bool = false
        @Published var errorMessage: String = ""

        private var callLogRequest: CometChatCallsSDK.CallLogsRequest
        private var callLogRequestBuilder: CometChatCallsSDK.CallLogsRequest.CallLogsBuilder
        private var isFetching: Bool = false
        private var isFetchedAll: Bool = false
        private var isFreshReloading: Bool = false

        public init() {
            callLogRequestBuilder = CometChatCallsSDK.CallLogsRequest.CallLogsBuilder()
                .set(authToken: CometChat.getUserAuthToken())
                .set(callCategory: .call)
            callLogRequest = callLogRequestBuilder.build()
        }

        public func set(callLogRequestBuilder: CometChatCallsSDK.CallLogsRequest.CallLogsBuilder) {
            self.callLogRequestBuilder = callLogRequestBuilder
            callLogRequest = callLogRequestBuilder.build()
        }

        public func fetchCallLogs() {
            isLoading = true
            isFreshReloading = true
            callLogRequest = callLogRequestBuilder.build()
            fetchNext()
        }

        public func fetchNext() {
            if isFetchedAll { return }
            isFetching = true

            callLogRequest.fetchNext { [weak self] callLogs in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false

                    if !callLogs.isEmpty {
                        self.addCallLogs(newCallLogs: callLogs)
                    } else {
                        self.isFetchedAll = true
                        self.isFreshReloading = false

                        if self.callLogs.isEmpty {
                            self.isEmpty = true
                        }
                    }
                    self.isFetching = false
                }
            } onError: { [weak self] error in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isFreshReloading = false
                    self.isFetching = false
                    self.isError = true
                    self.errorMessage = error?.errorDescription ?? "Something went wrong"
                }
            }
        }

        private func addCallLogs(newCallLogs: [CometChatCallsSDK.CallLog]) {
            if isFreshReloading {
                callLogs.removeAll()
                isFreshReloading = false
            }
            callLogs.append(contentsOf: newCallLogs)
        }

        public func refresh() {
            isFetchedAll = false
            fetchCallLogs()
        }
    }

#endif
