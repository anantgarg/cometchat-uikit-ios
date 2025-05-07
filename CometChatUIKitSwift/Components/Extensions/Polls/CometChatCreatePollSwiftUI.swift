//
//
//

import CometChatSDK
import SwiftUI

public struct CometChatCreatePollSwiftUI: View {
    @State private var questionString: String = ""
    @State private var items: [String] = ["", ""]
    @State private var style: CreatePollStyle = .init()
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showExitAlert: Bool = false

    @Environment(\.presentationMode) var presentationMode

    private var user: User?
    private var group: Group?
    private var onDismiss: (() -> Void)?

    public init() {}

    public var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("QUESTION".localize())
                        .font(Font(style.questionTitleTextFont))
                        .foregroundColor(Color(style.questionTitleTextColor)))
                    {
                        CometChatCreatePollQuestionsSwiftUI(questionText: $questionString)
                            .set(style: style)
                    }

                    Section(header: Text("OPTIONS".localize())
                        .font(Font(style.optionsTitleTextFont))
                        .foregroundColor(Color(style.optionsTitleTextColor)))
                    {
                        ForEach(0 ..< items.count, id: \.self) { index in
                            CometChatCreatePollOptionsSwiftUI(
                                optionText: Binding(
                                    get: { items[index] },
                                    set: { items[index] = $0 }
                                ),
                                items: $items,
                                index: index,
                                onDelete: {
                                    if items.count > 2, index != items.count - 1 {
                                        items.remove(at: index)
                                    }
                                },
                                onTextChanged: { newText, idx in
                                    if idx == 0 || idx == 1 {
                                        if idx == items.count - 1, !newText.isEmpty, items.count < 12 {
                                            items.append("")
                                        }
                                    } else if idx == items.count - 1, !newText.isEmpty, items.count < 12 {
                                        items.append("")
                                    }
                                },
                                onEditingEnd: { _ in
                                    cleanupEmptyOptions()
                                }
                            )
                            .set(style: style)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .background(Color(style.backgroundColor))

                if showError {
                    HStack(spacing: CometChatSpacing.Padding.p1) {
                        Image(uiImage: style.errorImage ?? UIImage())
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color(style.errorImageTintColor))

                        Text(errorMessage)
                            .font(Font(style.errorTextFont))
                            .foregroundColor(Color(style.errorTextColor))
                    }
                    .padding(CometChatSpacing.Padding.p2)
                    .background(Color(style.errorViewBackgroundColor))
                    .cornerRadius(style.errorViewCornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r2)
                    .overlay(
                        RoundedRectangle(cornerRadius: style.errorViewCornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r2)
                            .stroke(Color(style.errorViewBorderColor), lineWidth: style.errorViewBorderWidth)
                    )
                    .padding(.horizontal, CometChatSpacing.Padding.p4)
                    .padding(.bottom, CometChatSpacing.Padding.p10)
                }
            }
            .navigationBarTitle("CREATE_POLL".localize(), displayMode: .inline)
            .navigationBarItems(
                leading: Button("CANCEL".localize()) {
                    if !questionString.isEmpty || !items[0].isEmpty || !items[1].isEmpty {
                        showExitAlert = true
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .foregroundColor(Color(style.cancelButtonTextColor))
                .font(Font(style.cancelButtonTextFont)),

                trailing: Button("SEND".localize()) {
                    sendPoll()
                }
                .disabled(!isSendButtonEnabled())
                .foregroundColor(Color(isSendButtonEnabled() ? style.sendButtonTextColor : style.sendButtonDisabledTextColor))
                .font(Font(style.sendButtonTextFont))
            )
            .alert(isPresented: $showExitAlert) {
                Alert(
                    title: Text("EXIT".localize()),
                    message: Text("EXIT_ALERT".localize()),
                    primaryButton: .destructive(Text("YES".localize())) {
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel(Text("NO".localize()))
                )
            }
            .overlay(
                Group {
                    if isLoading {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)

                        VStack {
                            Text("CREATING_POLL".localize())
                                .foregroundColor(.white)
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        .padding()
                        .background(Color(CometChatTheme.backgroundColor))
                        .cornerRadius(8)
                    }
                }
            )
        }
        .onDisappear {
            onDismiss?()
        }
    }

    private func isSendButtonEnabled() -> Bool {
        if questionString.isEmpty {
            return false
        }

        let filledOptions = items.filter { !$0.isEmpty }
        if items.count == 2 {
            return filledOptions.count == 2
        } else {
            return filledOptions.count >= 2
        }
    }

    private func cleanupEmptyOptions() {
        for (index, optionText) in items.enumerated().reversed() {
            if optionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, index != items.count - 1, items.count > 2 {
                items.remove(at: index)
            }
        }
    }

    private func sendPoll() {
        if questionString.isEmpty {
            return
        }

        let options = items.filter { !$0.isEmpty }
        if options.count < 2 {
            showError = true
            errorMessage = "FILL_POLL_DETAILS".localize()
            return
        }

        isLoading = true

        var body = ["question": questionString, "options": options] as [String: Any]

        if let user {
            body["receiver"] = user.uid ?? ""
            body["receiverType"] = ReceiverTypeConstants.user
        } else if let group {
            body["receiver"] = group.guid
            body["receiverType"] = ReceiverTypeConstants.group
        }

        CometChat.callExtension(slug: ExtensionConstants.polls, type: .post, endPoint: "v2/create", body: body) { _ in
            isLoading = false
            presentationMode.wrappedValue.dismiss()
        } onError: { error in
            isLoading = false
            if let error {
                showError = true
                errorMessage = CometChatServerError.get(error: error).errorDescription ?? "ERROR_CREATING_POLL".localize()
            }
        }
    }

    public func set(user: User) -> Self {
        var view = self
        view.user = user
        return view
    }

    public func set(group: Group) -> Self {
        var view = self
        view.group = group
        return view
    }

    public func set(style: CreatePollStyle) -> Self {
        var view = self
        view.style = style
        return view
    }

    public func set(onDismiss: @escaping (() -> Void)) -> Self {
        var view = self
        view.onDismiss = onDismiss
        return view
    }

    public func toUIKit() -> UIViewController {
        let hostingController = UIHostingController(rootView: self)
        let navigationController = UINavigationController(rootViewController: hostingController)
        return navigationController
    }
}

struct CometChatCreatePollSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        CometChatCreatePollSwiftUI()
    }
}
