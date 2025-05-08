//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatFormBubbleSwiftUI: View {
    
    private var style: FormBubbleStyle = FormBubbleStyle()
    @State private var formMessage: FormMessage?
    @State private var elementEntities: [ElementEntity]?
    @State private var interactedElements: [String] = []
    @State private var cometChatData: [String: Any] = [:]
    @State private var isDateSelected: Bool = false
    @State private var showQuickView: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 5) {
            if showQuickView, let formMessage = formMessage {
                quickViewContent(formMessage: formMessage)
            } else {
                formContent()
            }
        }
        .padding(11)
        .background(Color(style.background))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
        )
        .onAppear {
            checkIfPresentQuickView()
        }
    }
    
    private func formContent() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            if let title = formMessage?.getTitle() {
                Spacer()
                    .frame(height: 14)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(style.getTitleColor()))
                    .padding(.horizontal, 8)
                    .frame(height: 30)
                
                Divider()
                    .background(Color.black)
                    .padding(.top, 25)
            }
            
            ForEach(elementEntities ?? [], id: \.elementId) { entity in
                elementView(for: entity)
            }
            
            if let formMessage = formMessage {
                submitButtonView(formMessage.getSubmitElement())
            }
        }
    }
    
    private func quickViewContent(formMessage: FormMessage) -> some View {
        VStack(spacing: 10) {
            CometChatQuickViewSwiftUI()
                .set(title: formMessage.sender?.name ?? "")
                .set(subTitle: formMessage.getTitle())
                .padding(8)
                .frame(height: 60)
            
            Text(formMessage.getGoalCompletionText().isEmpty ? "FORM_COMPLETION_MESSAGE".localize() : formMessage.getGoalCompletionText())
                .foregroundColor(Color(style.getLabelColor()))
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 8)
                .padding(.bottom, 24)
        }
    }
    
    @ViewBuilder
    private func elementView(for entity: ElementEntity) -> some View {
        switch entity.elementType {
        case .label:
            if let labelElement = entity as? LabelElement {
                labelView(labelElement)
            }
        case .textInput:
            if let textInputElement = entity as? TextInputElement {
                textInputView(textInputElement)
            }
        case .button:
            if let buttonElement = entity as? ButtonElement {
                buttonView(buttonElement)
            }
        case .checkbox:
            if let checkboxElement = entity as? CheckboxElement {
                checkboxView(checkboxElement)
            }
        case .radio:
            if let radioButtonElement = entity as? RadioButtonElement {
                radioButtonView(radioButtonElement)
            }
        case .dropdown:
            if let dropdownElement = entity as? DropdownElement {
                dropdownView(dropdownElement)
            }
        case .singleSelect:
            if let singleSelectElement = entity as? SingleSelectElement {
                singleSelectView(singleSelectElement)
            }
        case .dateTime:
            if let dateTimeElement = entity as? DateTimeElement {
                dateTimePickerView(dateTimeElement)
            }
        default:
            EmptyView()
        }
    }
    
    private func labelView(_ labelElement: LabelElement) -> some View {
        Text(labelElement.text)
            .foregroundColor(Color(style.getLabelColor()))
            .frame(height: 30)
    }
    
    private func textInputView(_ textInputElement: TextInputElement) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if !textInputElement.label.isEmpty {
                Spacer()
                    .frame(height: 14)
                
                Text(textInputElement.optional ?? true ? textInputElement.label : "\(textInputElement.label) *")
                    .foregroundColor(Color(style.getLabelColor()))
                    .padding(.horizontal, 8)
                    .frame(height: 30)
            }
            
            TextField(textInputElement.placeHolder, text: Binding(
                get: { textInputElement.text },
                set: { newValue in
                    if let index = elementEntities?.firstIndex(where: { $0.elementId == textInputElement.elementId }),
                       var textInput = elementEntities?[index] as? TextInputElement {
                        textInput.text = newValue
                        elementEntities?[index] = textInput
                        cometChatData[textInputElement.elementId] = newValue
                    }
                }
            ))
            .foregroundColor(Color(style.getInputTextColor()))
            .padding(8)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(style.getInputStrokeColor()), lineWidth: style.getInputStrokeWidth())
            )
            .padding(.horizontal, 8)
            .frame(height: 30)
        }
    }
    
    private func buttonView(_ buttonElement: ButtonElement) -> some View {
        Button(action: {
            onButtonClickAction(buttonElement)
        }) {
            Text(buttonElement.buttonText)
                .foregroundColor(Color(style.getButtonTextColor()))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(interactedElements.contains(buttonElement.elementId) && buttonElement.disableAfterInteracted ? 
                      style.getButtonBackgroundColor().withAlphaComponent(0.7) : 
                      style.getButtonBackgroundColor()))
        )
        .disabled(interactedElements.contains(buttonElement.elementId) && buttonElement.disableAfterInteracted)
        .padding(.horizontal, 8)
        .padding(.top, 24)
        .frame(height: 50)
    }
    
    private func submitButtonView(_ buttonElement: ButtonElement) -> some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 8)
            
            Button(action: {
                onSubmitButtonClickAction(buttonElement)
            }) {
                Text(buttonElement.buttonText)
                    .foregroundColor(Color(style.getButtonTextColor()))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(style.getButtonBackgroundColor()))
            )
            .padding(.horizontal, 8)
            .padding(.top, 24)
            .frame(height: 50)
            
            Spacer()
                .frame(height: 8)
        }
    }
    
    private func checkboxView(_ checkboxElement: CheckboxElement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !checkboxElement.label.isEmpty {
                Text(checkboxElement.optional ?? true ? checkboxElement.label : "\(checkboxElement.label) *")
                    .foregroundColor(Color(style.getLabelColor()))
                    .padding(.horizontal, 8)
            }
            
            ForEach(checkboxElement.options, id: \.self) { option in
                HStack {
                    Image(systemName: checkboxElement.selectedValues.contains(option) ? "checkmark.square.fill" : "square")
                        .foregroundColor(Color(style.getCheckboxButtonTint()))
                        .onTapGesture {
                            toggleCheckbox(option, in: checkboxElement)
                        }
                    
                    Text(option)
                        .foregroundColor(Color(style.getCheckboxTextColor()))
                }
                .padding(.horizontal, 8)
            }
        }
    }
    
    private func radioButtonView(_ radioButtonElement: RadioButtonElement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !radioButtonElement.label.isEmpty {
                Text(radioButtonElement.optional ?? true ? radioButtonElement.label : "\(radioButtonElement.label) *")
                    .foregroundColor(Color(style.getLabelColor()))
                    .padding(.horizontal, 8)
            }
            
            ForEach(radioButtonElement.options, id: \.self) { option in
                HStack {
                    Image(systemName: radioButtonElement.selectedValue == option ? "circle.fill" : "circle")
                        .foregroundColor(Color(style.getRadioButtonTint()))
                        .onTapGesture {
                            selectRadioOption(option, in: radioButtonElement)
                        }
                    
                    Text(option)
                        .foregroundColor(Color(style.getRadioButtonTextColor()))
                }
                .padding(.horizontal, 8)
            }
        }
    }
    
    private func dropdownView(_ dropdownElement: DropdownElement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !dropdownElement.label.isEmpty {
                Text(dropdownElement.optional ?? true ? dropdownElement.label : "\(dropdownElement.label) *")
                    .foregroundColor(Color(style.getLabelColor()))
                    .padding(.horizontal, 8)
            }
            
            Menu {
                ForEach(dropdownElement.options, id: \.self) { option in
                    Button(action: {
                        selectDropdownOption(option, in: dropdownElement)
                    }) {
                        Text(option)
                    }
                }
            } label: {
                HStack {
                    Text(dropdownElement.selectedValue.isEmpty ? dropdownElement.placeHolder : dropdownElement.selectedValue)
                        .foregroundColor(dropdownElement.selectedValue.isEmpty ? Color(style.getInputHintColor()) : Color(style.getInputTextColor()))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(style.getInputTextColor()))
                }
                .padding(8)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(style.getInputStrokeColor()), lineWidth: style.getInputStrokeWidth())
                )
            }
            .padding(.horizontal, 8)
        }
    }
    
    private func singleSelectView(_ singleSelectElement: SingleSelectElement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !singleSelectElement.label.isEmpty {
                Text(singleSelectElement.optional ?? true ? singleSelectElement.label : "\(singleSelectElement.label) *")
                    .foregroundColor(Color(style.getLabelColor()))
                    .padding(.horizontal, 8)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(singleSelectElement.options, id: \.self) { option in
                        Text(option)
                            .foregroundColor(singleSelectElement.selectedValue == option ? 
                                            Color(style.getSelectedOptionTextColor()) : 
                                            Color(style.getOptionTextColor()))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(singleSelectElement.selectedValue == option ? 
                                       Color(style.getSelectedBackgroundColor()) : 
                                       Color.clear)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(style.getInputStrokeColor()), lineWidth: 1)
                            )
                            .onTapGesture {
                                selectSingleOption(option, in: singleSelectElement)
                            }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
    
    private func dateTimePickerView(_ dateTimeElement: DateTimeElement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !dateTimeElement.label.isEmpty {
                Text(dateTimeElement.optional ?? true ? dateTimeElement.label : "\(dateTimeElement.label) *")
                    .foregroundColor(Color(style.getLabelColor()))
                    .padding(.horizontal, 8)
            }
            
            Button(action: {
                if let index = elementEntities?.firstIndex(where: { $0.elementId == dateTimeElement.elementId }),
                   var dateTime = elementEntities?[index] as? DateTimeElement {
                    dateTime.selectedDateTime = Date()
                    elementEntities?[index] = dateTime
                    cometChatData[dateTimeElement.elementId] = Date()
                    isDateSelected = true
                }
            }) {
                HStack {
                    Text(dateTimeElement.selectedDateTime != nil ? 
                         dateTimeElement.selectedDateTime!.description : 
                         dateTimeElement.placeHolder)
                        .foregroundColor(dateTimeElement.selectedDateTime != nil ? 
                                        Color(style.getInputTextColor()) : 
                                        Color(style.getInputHintColor()))
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .foregroundColor(Color(style.getInputTextColor()))
                }
                .padding(8)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(style.getInputStrokeColor()), lineWidth: style.getInputStrokeWidth())
                )
            }
            .padding(.horizontal, 8)
        }
    }
    
    private func onButtonClickAction(_ buttonElement: ButtonElement) {
        interactedElements.append(buttonElement.elementId)
        checkIfPresentQuickView()
    }
    
    private func onSubmitButtonClickAction(_ buttonElement: ButtonElement) {
        interactedElements.append(buttonElement.elementId)
        checkIfPresentQuickView()
    }
    
    private func toggleCheckbox(_ option: String, in checkboxElement: CheckboxElement) {
        if let index = elementEntities?.firstIndex(where: { $0.elementId == checkboxElement.elementId }),
           var checkbox = elementEntities?[index] as? CheckboxElement {
            if checkbox.selectedValues.contains(option) {
                checkbox.selectedValues.removeAll { $0 == option }
            } else {
                checkbox.selectedValues.append(option)
            }
            elementEntities?[index] = checkbox
            cometChatData[checkboxElement.elementId] = checkbox.selectedValues
        }
    }
    
    private func selectRadioOption(_ option: String, in radioButtonElement: RadioButtonElement) {
        if let index = elementEntities?.firstIndex(where: { $0.elementId == radioButtonElement.elementId }),
           var radio = elementEntities?[index] as? RadioButtonElement {
            radio.selectedValue = option
            elementEntities?[index] = radio
            cometChatData[radioButtonElement.elementId] = option
        }
    }
    
    private func selectDropdownOption(_ option: String, in dropdownElement: DropdownElement) {
        if let index = elementEntities?.firstIndex(where: { $0.elementId == dropdownElement.elementId }),
           var dropdown = elementEntities?[index] as? DropdownElement {
            dropdown.selectedValue = option
            elementEntities?[index] = dropdown
            cometChatData[dropdownElement.elementId] = option
        }
    }
    
    private func selectSingleOption(_ option: String, in singleSelectElement: SingleSelectElement) {
        if let index = elementEntities?.firstIndex(where: { $0.elementId == singleSelectElement.elementId }),
           var singleSelect = elementEntities?[index] as? SingleSelectElement {
            singleSelect.selectedValue = option
            elementEntities?[index] = singleSelect
            cometChatData[singleSelectElement.elementId] = option
        }
    }
    
    private func checkIfPresentQuickView() {
        guard let formMessage = formMessage,
              let interactions = formMessage.interactions,
              let interactionGoal = formMessage.interactionGoal,
              let elementIds = interactionGoal.elementIds else {
            return
        }
        
        switch interactionGoal.interactionType {
        case .allOf:
            var count = 0
            for interaction in interactions {
                if let elementId = interaction.elementId, elementIds.contains(elementId) {
                    count += 1
                }
            }
            if count == elementIds.count {
                showQuickView = true
            }
        case .anyOf:
            for interaction in interactions {
                if let elementId = interaction.elementId, elementIds.contains(elementId) {
                    showQuickView = true
                    return
                }
            }
        case .anyAction:
            if interactions.count > 0 {
                showQuickView = true
            }
        default:
            break
        }
    }
    
    public func set(formMessage: FormMessage) -> CometChatFormBubbleSwiftUI {
        var view = self
        view._formMessage = State(initialValue: formMessage)
        view._elementEntities = State(initialValue: formMessage.getFormFields())
        return view
    }
    
    public func set(style: FormBubbleStyle) -> CometChatFormBubbleSwiftUI {
        var view = self
        view.style = style
        return view
    }
}

extension CometChatFormBubbleSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatFormBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatFormBubbleSwiftUI()
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            CometChatFormBubbleSwiftUI()
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
