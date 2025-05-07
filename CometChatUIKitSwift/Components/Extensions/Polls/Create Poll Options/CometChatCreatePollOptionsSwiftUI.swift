//
//
//

import SwiftUI

struct CometChatCreatePollOptionsSwiftUI: View {
    @Binding var optionText: String
    @Binding var items: [String]
    @State private var style: CreatePollStyle = .init()
    let index: Int
    var onDelete: (() -> Void)?
    var onTextChanged: ((String, Int) -> Void)?
    var onEditingEnd: ((String) -> Void)?

    var body: some View {
        HStack(spacing: CometChatSpacing.Spacing.s2) {
            Image(uiImage: style.dragButtonImage ?? UIImage())
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(Color(style.dragButtonTintColor))

            TextField("ADD".localize(), text: $optionText)
                .font(Font(style.optionsTextFont))
                .foregroundColor(Color(style.optionsTextColor))
                .padding(.horizontal, CometChatSpacing.Padding.p2)
                .padding(.vertical, CometChatSpacing.Padding.p1)
                .background(Color(style.optionsInputBoxBackground))
                .cornerRadius(style.optionsInputBoxCornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r2)
                .overlay(
                    RoundedRectangle(cornerRadius: style.optionsInputBoxCornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r2)
                        .stroke(Color(style.optionsInputBoxBorderColor), lineWidth: style.optionsInputBoxBorderWidth)
                )
                .onChange(of: optionText) { newValue in
                    onTextChanged?(newValue, index)
                }
                .onSubmit {
                    onEditingEnd?(optionText)
                }

            Button(action: {
                onDelete?()
            }) {
                Image(uiImage: style.deleteButtonImage ?? UIImage())
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(style.deleteButtonTintColor))
            }
            .opacity(items.count > 2 && index != items.count - 1 ? 1.0 : 0.0)
            .disabled(items.count <= 2 || index == items.count - 1)
        }
        .padding(.vertical, CometChatSpacing.Spacing.s1)
        .padding(.horizontal, CometChatSpacing.Spacing.s4)
    }

    func set(style: CreatePollStyle) -> Self {
        var view = self
        view.style = style
        return view
    }
}

struct CometChatCreatePollOptionsSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CometChatCreatePollOptionsSwiftUI(
                optionText: .constant("Option 1"),
                items: .constant(["Option 1", "Option 2", ""]),
                index: 0
            )

            CometChatCreatePollOptionsSwiftUI(
                optionText: .constant("Option 2"),
                items: .constant(["Option 1", "Option 2", ""]),
                index: 1
            )

            CometChatCreatePollOptionsSwiftUI(
                optionText: .constant(""),
                items: .constant(["Option 1", "Option 2", ""]),
                index: 2
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
