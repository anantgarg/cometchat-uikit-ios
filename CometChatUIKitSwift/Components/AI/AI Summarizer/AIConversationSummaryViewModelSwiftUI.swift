//
//
//

import Foundation
import SwiftUI
import Combine

public class AIConversationSummaryViewModelSwiftUI: ObservableObject {
    @Published var summary: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var title: String = "CONVERSATION_SUMMARY".localize()
    
    public init() {}
    
    public func set(summary: String) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.summary = summary
        }
    }
    
    public func set(title: String) {
        DispatchQueue.main.async {
            self.title = title
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
