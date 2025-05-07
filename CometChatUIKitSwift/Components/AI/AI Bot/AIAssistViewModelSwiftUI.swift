//
//
//

import Combine
import CometChatSDK
import Foundation
import SwiftUI

public class AIAssistViewModelSwiftUI: ObservableObject {
    @Published var messageDataSource: [TextMessage] = []
    @Published var bot: User?
    @Published var isKeyboardVisible: Bool = false
    @Published var keyboardHeight: CGFloat = 0

    private var configuration = AIAssistBotConfiguration()

    public init() {
        setupKeyboardObservers()
    }

    deinit {
        removeKeyboardObservers()
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            DispatchQueue.main.async {
                self.isKeyboardVisible = true
                self.keyboardHeight = keyboardFrame.height
            }
        }
    }

    @objc private func keyboardWillHide(notification _: NSNotification) {
        DispatchQueue.main.async {
            self.isKeyboardVisible = false
            self.keyboardHeight = 0
        }
    }

    public func add(message: TextMessage) {
        DispatchQueue.main.async {
            self.messageDataSource.append(message)
        }
    }

    public func update(message: TextMessage) {
        DispatchQueue.main.async {
            if let index = self.messageDataSource.firstIndex(where: { $0.text == message.text }) {
                self.messageDataSource[index] = message
            }
        }
    }

    public func set(bot: User?) {
        DispatchQueue.main.async {
            self.bot = bot
        }
    }

    public func set(configuration: AIAssistBotConfiguration?) {
        guard let configuration else { return }
        self.configuration = configuration
    }
}
