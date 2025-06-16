//
//  SelectionView.swift
//  StudyTimer
//
//  Created by Pursuit on 6/14/25.
//

import SwiftUI

import SwiftUI

struct OptionRow<T: Equatable>: View {
    let value: T
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(String(describing: value))
                .font(.system(size: 18, weight: .semibold))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(isSelected ? Color.screenBackground : Color.cardBackground)
                .background(isSelected ? Color.cardBackground : Color.screenBackground)
                .cornerRadius(isSelected ? 12 : 0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

struct SelectionView<T: Hashable>: View {
    var viewModel: ViewModel
    @Binding var selectedOption: T?
    @Environment(\.dismiss) private var dismiss


    var body: some View {
        VStack(spacing: 20) {
            Text(String(describing: viewModel.title))
                .font(.system(size: 50, weight: .semibold))
                .foregroundColor(.buttonTitleText)
                .multilineTextAlignment(.leading)
                .padding(.top, 20)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.options, id: \.self) { option in
                        OptionRow(
                            value: option,
                            isSelected: option == selectedOption,
                            onTap: {
                                selectedOption = option
                            }
                        )
                    }
                }
                .padding()
            }
            HStack(spacing: 12) {
                Button {
                    guard selectedOption != nil else { return }
                    dismiss()
                } label: {
                    Text("Done")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cardBackground)
                        .foregroundColor(Color.screenBackground)
                        .cornerRadius(12)
                        .opacity(selectedOption == nil ? 0.4 : 1)
                }

                Button {
                    selectedOption = nil
                    dismiss()
                } label: {
                    Text("Cancel")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(Color.cardBackground)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
        .background(Color.screenBackground)
    }
}

extension SelectionView {
    final class ViewModel {
        let title: String
        let options: [T]
        
        init(
            title: String,
            options: [T]
        ) {
            self.title = title
            self.options = options
        }
    }
}

#Preview {
    @Previewable @State var selectedOption: String? = nil
    return SelectionView(
        viewModel: .init(title: "Select Option", options: ["option1", "option2", "option3", "option4"]),
        selectedOption: $selectedOption
    )
}
