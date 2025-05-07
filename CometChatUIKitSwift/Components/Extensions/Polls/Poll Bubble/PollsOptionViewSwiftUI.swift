//
//
//

import CometChatSDK
import SwiftUI

struct PollsOptionViewSwiftUI: View {
    @State private var pollOption: PollOptions
    @State private var total: Int
    @State private var style: PollBubbleStyle = .init()
    @State private var isOptionSelected: Bool = false
    @State private var isLoading: Bool = false
    @State private var onSelected: ((_ pollOption: PollOptions) -> Void)?

    @State private var optionCheckIcon: UIImage? = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
    @State private var optionUncheckIcon: UIImage? = UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate)

    init(pollOption: PollOptions, total: Int) {
        _pollOption = State(initialValue: pollOption)
        _total = State(initialValue: total)

        for (uid, _, _) in pollOption.user {
            if uid == CometChat.getLoggedInUser()?.uid {
                _isOptionSelected = State(initialValue: true)
                break
            }
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: CometChatSpacing.Padding.p2) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(style.optionProgressTintColor)))
                        .frame(width: 20, height: 20)
                } else {
                    Image(uiImage: isOptionSelected ? (optionCheckIcon ?? UIImage()) : (optionUncheckIcon ?? UIImage()))
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(isOptionSelected ? style.selectedPollImageTint : style.nonSelectedPollImageTint))
                }
            }

            VStack(alignment: .leading, spacing: CometChatSpacing.Padding.p1) {
                Text(pollOption.text)
                    .font(Font(style.optionTextFont))
                    .foregroundColor(Color(style.optionTextColor))
                    .multilineTextAlignment(.leading)

                ProgressBar(value: total == 0 ? 0 : Float(pollOption.count) / Float(total))
                    .frame(height: 8)
                    .cornerRadius(style.optionProgressCornerRadius.cornerRadius)
            }

            Spacer()

            HStack(spacing: -8) {
                ForEach(0 ..< min(pollOption.user.count, 4), id: \.self) { index in
                    let user = pollOption.user[index]
                    CometChatAvatarSwiftUI()
                        .set(name: user.name)
                        .set(avatarURL: user.avatar)
                        .set(width: 20)
                        .set(height: 20)
                }

                Text("\(pollOption.count)")
                    .font(Font(style.optionCountTextFont))
                    .foregroundColor(Color(style.optionCountTextColor))
                    .padding(.leading, 4)
            }
            .frame(height: 20)
        }
        .onTapGesture {
            onOptionSelected()
        }
    }

    private func onOptionSelected() {
        isLoading = true
        onSelected?(pollOption)
    }

    func set(onClicked: @escaping ((_ pollOption: PollOptions) -> Void)) -> Self {
        var view = self
        view.onSelected = onClicked
        return view
    }

    func set(style: PollBubbleStyle) -> Self {
        var view = self
        view.style = style
        return view
    }

    func set(optionCheckIcon: UIImage?) -> Self {
        var view = self
        view.optionCheckIcon = optionCheckIcon
        return view
    }

    func set(optionUncheckIcon: UIImage?) -> Self {
        var view = self
        view.optionUncheckIcon = optionUncheckIcon
        return view
    }
}

struct ProgressBar: View {
    var value: Float
    @State private var backgroundColor: Color = .init(CometChatTheme.neutralColor400)
    @State private var foregroundColor: Color = .init(CometChatTheme.primaryColor)

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(backgroundColor)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                Rectangle()
                    .fill(foregroundColor)
                    .frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .animation(.linear, value: value)
            }
        }
    }

    func backgroundColor(_ color: Color) -> ProgressBar {
        var progressBar = self
        progressBar.backgroundColor = color
        return progressBar
    }

    func foregroundColor(_ color: Color) -> ProgressBar {
        var progressBar = self
        progressBar.foregroundColor = color
        return progressBar
    }
}

struct PollsOptionViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(uid: "user1", name: "John Doe")
        let pollOption = PollOptions(id: "1", text: "Option 1", count: 5, index: "0", user: [(uid: "user1", avatar: "", name: "John Doe")])

        return VStack(spacing: 16) {
            PollsOptionViewSwiftUI(pollOption: pollOption, total: 10)
                .set(style: PollBubbleStyle(styleType: .incoming))

            PollsOptionViewSwiftUI(pollOption: pollOption, total: 10)
                .set(style: PollBubbleStyle(styleType: .outgoing))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
