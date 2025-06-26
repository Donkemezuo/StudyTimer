//
//  InfoRowView.swift
//  StudyTimer
//
//  Created by Pursuit on 6/14/25.
//

import SwiftUI

import SwiftUI

struct InfoRowView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            HStack {
                Text(viewModel.title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(viewModel.titleTintColor)

                Spacer()

                Button {
                    viewModel.onTap?()
                }
            label: {
                    Text(viewModel.value)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(viewModel.valueTintColor)
                        .padding()
                        .background(viewModel.valueBackgroundColor)
                        .cornerRadius(20)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isInteractionDisabled)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

extension InfoRowView {
    final class ViewModel: ObservableObject {
        let title: String
        let value: String
        let isInteractionDisabled: Bool
        let valueBackgroundColor: Color
        let titleTintColor: Color
        let valueTintColor: Color
        var onTap: (() -> Void?)? = nil
        init(
            title: String,
            value: String,
            isInteractionDisabled: Bool = false,
            valueBackgroundColor: Color,
            titleTintColor: Color,
            valueTintColor: Color,
            onTap: ( () -> Void?)? = nil
        ) {
            self.title = title
            self.value = value
            self.isInteractionDisabled = isInteractionDisabled
            self.valueBackgroundColor = valueBackgroundColor
            self.titleTintColor = titleTintColor
            self.valueTintColor = valueTintColor
            self.onTap = onTap
        }
    }
}

#Preview {
    InfoRowView(viewModel: .init(
         title: "Subject",
         value: "Physics",
         valueBackgroundColor: .orange,
         titleTintColor: .primary,
         valueTintColor: .white,
         onTap: {
             print("Tapped Physics row")
         }
     ))
}
