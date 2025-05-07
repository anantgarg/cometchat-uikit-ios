//
//
//

import Combine
import Foundation
import SwiftUI

public class AIConversationStarterViewModelSwiftUI: ObservableObject {
    @Published var aiMessagesList: [String] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false

    public init() {}

    public func set(aiMessageOptions: [String]) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.aiMessagesList = aiMessageOptions
        }
    }

    public func showLoadingView() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
    }

    public func hideLoadingView() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }

    public func show(error: Bool) {
        DispatchQueue.main.async {
            self.showError = error
        }
    }
}
