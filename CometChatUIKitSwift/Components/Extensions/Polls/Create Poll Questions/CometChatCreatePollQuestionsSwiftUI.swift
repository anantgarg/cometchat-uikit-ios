//
//
//

import SwiftUI

struct CometChatCreatePollQuestionsSwiftUI: View {
    @Binding var questionText: String
    @State private var style: CreatePollStyle = CreatePollStyle()
    
    var body: some View {
        VStack {
            TextField("ASK_QUESTION".localize(), text: $questionText)
                .font(Font(style.questionTextFont))
                .foregroundColor(Color(style.questionTextColor))
                .padding(.horizontal, CometChatSpacing.Padding.p4)
                .padding(.vertical, CometChatSpacing.Padding.p2)
                .background(Color(style.questionInputBoxBackground))
                .cornerRadius(style.questionInputBoxCornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r2)
                .overlay(
                    RoundedRectangle(cornerRadius: style.questionInputBoxCornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r2)
                        .stroke(Color(style.questionInputBoxBorderColor), lineWidth: style.questionInputBoxBorderWidth)
                )
        }
    }
    
    func set(style: CreatePollStyle) -> Self {
        var view = self
        view.style = style
        return view
    }
}

struct CometChatCreatePollQuestionsSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        CometChatCreatePollQuestionsSwiftUI(questionText: .constant("What's your favorite programming language?"))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
