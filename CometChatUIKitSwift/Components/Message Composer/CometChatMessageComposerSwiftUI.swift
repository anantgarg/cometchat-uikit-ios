//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatMessageComposerSwiftUI: View {
    @ObservedObject private var viewModel: MessageComposerViewModelSwiftUI
    private var style: MessageComposerStyle
    
    @State private var text: String = ""
    @State private var isTextEmpty: Bool = true
    @State private var isKeyboardVisible: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var showAttachmentOptions: Bool = false
    @State private var showAIOptions: Bool = false
    @State private var showMediaRecorder: Bool = false
    @State private var messagePreviewVisible: Bool = false
    @State private var messagePreviewText: String = ""
    @State private var messageComposerMode: MessageComposerMode = .draft
    
    private var headerView: AnyView?
    private var footerView: AnyView?
    private var secondaryButtonView: AnyView?
    private var auxiliaryButtonView: AnyView?
    private var sendButtonView: AnyView?
    
    private var hideHeaderView: Bool = true
    private var hideFooterView: Bool = true
    private var hideSendButton: Bool = false
    private var hideAIButton: Bool = false
    private var hideAttachmentButton: Bool = false
    private var hideVoiceRecordingButton: Bool = false
    private var hideStickersButton: Bool = false
    private var disableSoundForMessages: Bool = false
    private var disableTypingEvents: Bool = false
    private var disableMentions: Bool = false
    private var auxiliaryButtonsAlignment: AuxilaryButtonAlignment = .left
    private var customSoundForMessage: URL?
    private var placeholderText: String = "TYPE_A_MESSAGE".localize()
    
    private var onSendButtonClick: ((BaseMessage) -> Void)?
    private var onError: ((CometChatException) -> Void)?
    private var onTextChanged: ((String) -> Void)?
    
    public init(style: MessageComposerStyle = CometChatMessageComposer.style) {
        self.style = style
        self._viewModel = ObservedObject(wrappedValue: MessageComposerViewModelSwiftUI())
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if !hideHeaderView, let headerView = headerView {
                headerView
            }
            
            if messagePreviewVisible {
                messagePreviewView
            }
            
            composerView
                .background(Color(style.composeBoxBackgroundColor))
                .cornerRadius(style.composerBoxCornerRadius.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: style.composerBoxCornerRadius.cornerRadius)
                        .stroke(Color(style.composeBoxBorderColor), lineWidth: style.composeBoxBorderWidth)
                )
                .padding(.horizontal, CometChatSpacing.Margin.m2)
                .padding(.bottom, CometChatSpacing.Margin.m2)
            
            if !hideFooterView, let footerView = footerView {
                footerView
            }
        }
        .padding(.bottom, isKeyboardVisible ? keyboardHeight : CometChatSpacing.Margin.m8)
        .background(Color(style.backgroundColor))
        .cornerRadius(style.cornerRadius?.cornerRadius ?? 0)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? 0)
                .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
        )
        .onAppear {
            setupKeyboardObservers()
            viewModel.connect()
        }
        .onDisappear {
            removeKeyboardObservers()
            viewModel.disconnect()
        }
        .sheet(isPresented: $showAttachmentOptions) {
            attachmentOptionsView
        }
        .sheet(isPresented: $showAIOptions) {
            aiOptionsView
        }
        .sheet(isPresented: $showMediaRecorder) {
            mediaRecorderView
        }
    }
    
    private var composerView: some View {
        VStack(spacing: 0) {
            textInputView
                .padding(.horizontal, CometChatSpacing.Padding.p3)
                .padding(.vertical, CometChatSpacing.Padding.p1)
            
            Divider()
                .background(Color(style.composerSeparatorColor))
            
            HStack(alignment: .center) {
                secondaryButtonsView
                
                Spacer()
                
                auxiliaryButtonsView
                
                Spacer()
                
                primaryButtonView
            }
            .frame(height: 48)
            .padding(.horizontal, CometChatSpacing.Padding.p3)
        }
    }
    
    private var textInputView: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholderText)
                    .font(Font(style.placeHolderTextFont))
                    .foregroundColor(Color(style.placeHolderTextColor))
                    .padding(.vertical, 8)
            }
            
            TextEditor(text: $text)
                .font(Font(style.textFiledFont))
                .foregroundColor(Color(style.textFiledColor))
                .frame(minHeight: 36, maxHeight: 120)
                .background(Color.clear)
                .onChange(of: text) { newValue in
                    isTextEmpty = newValue.isEmpty
                    onTextChanged?(newValue)
                    
                    if !disableTypingEvents {
                        viewModel.sendTypingIndicator()
                    }
                }
        }
    }
    
    private var secondaryButtonsView: some View {
        Group {
            if let secondaryButtonView = secondaryButtonView {
                secondaryButtonView
            } else {
                HStack(spacing: CometChatSpacing.Padding.p4) {
                    if !hideAttachmentButton {
                        Button(action: {
                            showAttachmentOptions = true
                        }) {
                            Image(uiImage: style.attachmentImage)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color(style.attachmentImageTint))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                    }
                    
                    if !hideVoiceRecordingButton {
                        Button(action: {
                            showMediaRecorder = true
                        }) {
                            Image(uiImage: style.voiceRecordingImage)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color(style.voiceRecordingImageTint))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
        }
    }
    
    private var auxiliaryButtonsView: some View {
        Group {
            if let auxiliaryButtonView = auxiliaryButtonView {
                auxiliaryButtonView
            } else {
                HStack(spacing: CometChatSpacing.Padding.p4) {
                    if !hideStickersButton {
                        Button(action: {
                        }) {
                            Image(systemName: "face.smiling")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color(style.stickerTint))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                    }
                    
                    if !hideAIButton {
                        Button(action: {
                            showAIOptions = true
                        }) {
                            Image(uiImage: style.aiImage)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color(style.aiImageTint))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
        }
    }
    
    private var primaryButtonView: some View {
        Group {
            if let sendButtonView = sendButtonView {
                sendButtonView
            } else if !hideSendButton {
                Button(action: {
                    sendMessage()
                }) {
                    Image(uiImage: style.sendButtonImage)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(style.sendButtonImageTint))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                .frame(width: 32, height: 32)
                .background(isTextEmpty ? Color(style.inactiveSendButtonImageBackgroundColor) : Color(style.activeSendButtonImageBackgroundColor))
                .cornerRadius(16)
                .disabled(isTextEmpty)
            }
        }
    }
    
    private var messagePreviewView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("EDIT_MESSAGE".localize())
                    .font(.caption)
                    .foregroundColor(Color(style.textFiledColor))
                
                Text(messagePreviewText)
                    .font(.caption2)
                    .foregroundColor(Color(style.textFiledColor.withAlphaComponent(0.7)))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: {
                hideEditPreview()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Color(style.textFiledColor))
            }
        }
        .padding(CometChatSpacing.Padding.p2)
        .background(Color(style.composeBoxBackgroundColor.withAlphaComponent(0.5)))
        .cornerRadius(8)
        .padding(.horizontal, CometChatSpacing.Margin.m2)
    }
    
    private var attachmentOptionsView: some View {
        let attachmentOptions = viewModel.getAttachmentOptions()
        
        return VStack {
            ForEach(attachmentOptions, id: \.id) { option in
                Button(action: {
                    showAttachmentOptions = false
                    option.onActionClick?()
                }) {
                    HStack {
                        if let icon = option.startIcon {
                            Image(uiImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                        
                        Text(option.text ?? "")
                            .font(.body)
                        
                        Spacer()
                    }
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
            }
        }
        .padding()
    }
    
    private var aiOptionsView: some View {
        let aiOptions = viewModel.getAIOptions()
        
        return VStack {
            ForEach(aiOptions, id: \.id) { option in
                Button(action: {
                    showAIOptions = false
                    option.onActionClick?()
                }) {
                    HStack {
                        if let icon = option.startIcon {
                            Image(uiImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                        
                        Text(option.text ?? "")
                            .font(.body)
                        
                        Spacer()
                    }
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
            }
        }
        .padding()
    }
    
    private var mediaRecorderView: some View {
        CometChatMediaRecorderSwiftUI()
            .onSubmit { url in
                showMediaRecorder = false
                if let onSendButtonClick = onSendButtonClick {
                    onSendButtonClick(viewModel.setupBaseMessage(url: url))
                    resetComposer()
                } else {
                    if viewModel.user != nil {
                        viewModel.sendMediaMessageToUser(url: url, type: .audio)
                    } else {
                        viewModel.sendMediaMessageToGroup(url: url, type: .audio)
                    }
                }
            }
    }
    
    private func sendMessage() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        if let onSendButtonClick = onSendButtonClick {
            if !text.isEmpty {
                let message = viewModel.setupBaseMessage(message: text, textFormatter: [:])
                onSendButtonClick(message)
                resetComposer()
            }
        } else {
            switch messageComposerMode {
            case .draft:
                if let _ = viewModel.user, !text.isEmpty {
                    viewModel.sendTextMessageToUser(message: text, textFormatter: [:])
                    resetComposer()
                } else if let _ = viewModel.group, !text.isEmpty {
                    viewModel.sendTextMessageToGroup(message: text, textFormatter: [:])
                    resetComposer()
                }
            case .edit:
                if let currentMessage = viewModel.message as? TextMessage, !text.isEmpty {
                    viewModel.editTextMessage(textMessage: currentMessage, message: text, textFormatter: [:])
                    resetComposer()
                }
            case .reply:
                break
            }
        }
    }
    
    private func resetComposer() {
        text = ""
        isTextEmpty = true
        messageComposerMode = .draft
        if messagePreviewVisible {
            hideEditPreview()
        }
    }
    
    private func presentEditPreview(for message: BaseMessage) {
        if let textMessage = message as? TextMessage {
            messagePreviewText = textMessage.text
            messagePreviewVisible = true
        }
    }
    
    private func hideEditPreview() {
        messageComposerMode = .draft
        messagePreviewVisible = false
        messagePreviewText = ""
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self.keyboardHeight = keyboardFrame.height
                self.isKeyboardVisible = true
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            self.keyboardHeight = 0
            self.isKeyboardVisible = false
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public func set(user: User) -> Self {
        var view = self
        view.viewModel.user = user
        return view
    }
    
    public func set(group: Group) -> Self {
        var view = self
        view.viewModel.group = group
        return view
    }
    
    public func set(parentMessageId: Int) -> Self {
        var view = self
        view.viewModel.parentMessageId = parentMessageId
        return view
    }
    
    public func hide(headerView: Bool) -> Self {
        var view = self
        view.hideHeaderView = headerView
        return view
    }
    
    public func hide(footerView: Bool) -> Self {
        var view = self
        view.hideFooterView = footerView
        return view
    }
    
    public func hide(sendButton: Bool) -> Self {
        var view = self
        view.hideSendButton = sendButton
        return view
    }
    
    public func hide(aiButton: Bool) -> Self {
        var view = self
        view.hideAIButton = aiButton
        return view
    }
    
    public func hide(attachmentButton: Bool) -> Self {
        var view = self
        view.hideAttachmentButton = attachmentButton
        return view
    }
    
    public func hide(voiceRecordingButton: Bool) -> Self {
        var view = self
        view.hideVoiceRecordingButton = voiceRecordingButton
        return view
    }
    
    public func hide(stickersButton: Bool) -> Self {
        var view = self
        view.hideStickersButton = stickersButton
        return view
    }
    
    public func disable(soundForMessages: Bool) -> Self {
        var view = self
        view.disableSoundForMessages = soundForMessages
        return view
    }
    
    public func disable(typingEvents: Bool) -> Self {
        var view = self
        view.disableTypingEvents = typingEvents
        return view
    }
    
    public func disable(mentions: Bool) -> Self {
        var view = self
        view.disableMentions = mentions
        return view
    }
    
    public func set(auxiliaryButtonsAlignment: AuxilaryButtonAlignment) -> Self {
        var view = self
        view.auxiliaryButtonsAlignment = auxiliaryButtonsAlignment
        return view
    }
    
    public func set(customSoundForMessage: URL?) -> Self {
        var view = self
        view.customSoundForMessage = customSoundForMessage
        return view
    }
    
    public func set(placeholderText: String) -> Self {
        var view = self
        view.placeholderText = placeholderText
        return view
    }
    
    public func set<T: View>(headerView: T) -> Self {
        var view = self
        view.headerView = AnyView(headerView)
        return view
    }
    
    public func set<T: View>(footerView: T) -> Self {
        var view = self
        view.footerView = AnyView(footerView)
        return view
    }
    
    public func set<T: View>(secondaryButtonView: T) -> Self {
        var view = self
        view.secondaryButtonView = AnyView(secondaryButtonView)
        return view
    }
    
    public func set<T: View>(auxiliaryButtonView: T) -> Self {
        var view = self
        view.auxiliaryButtonView = AnyView(auxiliaryButtonView)
        return view
    }
    
    public func set<T: View>(sendButtonView: T) -> Self {
        var view = self
        view.sendButtonView = AnyView(sendButtonView)
        return view
    }
    
    public func onSendButtonClick(_ action: @escaping (BaseMessage) -> Void) -> Self {
        var view = self
        view.onSendButtonClick = action
        return view
    }
    
    public func onError(_ action: @escaping (CometChatException) -> Void) -> Self {
        var view = self
        view.onError = action
        return view
    }
    
    public func onTextChanged(_ action: @escaping (String) -> Void) -> Self {
        var view = self
        view.onTextChanged = action
        return view
    }
    
    public func edit(message: BaseMessage) -> Self {
        var view = self
        if let textMessage = message as? TextMessage {
            view.viewModel.message = textMessage
            view.messageComposerMode = .edit
            view.text = textMessage.text
            view.isTextEmpty = textMessage.text.isEmpty
            view.presentEditPreview(for: textMessage)
        }
        return view
    }
}

extension CometChatMessageComposerSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatMessageComposerSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        CometChatMessageComposerSwiftUI()
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Default")
        
        CometChatMessageComposerSwiftUI()
            .hide(attachmentButton: true)
            .hide(voiceRecordingButton: true)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Minimal")
    }
}
