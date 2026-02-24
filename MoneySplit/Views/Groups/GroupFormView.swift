import SwiftUI

struct GroupFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let group: SplitGroup?
    @State private var vm: GroupFormViewModel?

    init(group: SplitGroup? = nil) {
        self.group = group
    }

    var body: some View {
        NavigationStack {
            Group {
                if let vm {
                    FormContent(vm: vm, dismiss: dismiss)
                }
            }
            .navigationTitle(group == nil ? "New Group" : "Edit Group")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if vm == nil {
                    vm = GroupFormViewModel(context: modelContext, group: group)
                }
            }
        }
    }
}

private struct FormContent: View {
    @ObservedObject var vm: GroupFormViewModel
    let dismiss: DismissAction

    var body: some View {
        Form {
            // Name
            Section("Group Name") {
                TextField("e.g. Barcelona Trip", text: $vm.name)
                    .autocorrectionDisabled()
            }

            // Emoji picker
            Section("Icon") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(GroupFormViewModel.emojiPresets, id: \.self) { emoji in
                            Button {
                                vm.emoji = emoji
                            } label: {
                                Text(emoji)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        vm.emoji == emoji
                                            ? Color(hex: vm.colorHex).opacity(0.2)
                                            : Color(.systemGray6),
                                        in: RoundedRectangle(cornerRadius: 10)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(
                                                vm.emoji == emoji ? Color(hex: vm.colorHex) : .clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // Color picker
            Section("Color") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 8) {
                    ForEach(GroupFormViewModel.colorPresets, id: \.self) { hex in
                        Button {
                            vm.colorHex = hex
                        } label: {
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white, lineWidth: 3)
                                        .opacity(vm.colorHex == hex ? 1 : 0)
                                )
                                .shadow(color: Color(hex: hex).opacity(0.4), radius: 4, y: 2)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // Currency
            Section("Currency") {
                Picker("Currency", selection: $vm.currencyCode) {
                    ForEach(GroupFormViewModel.currencyCodes, id: \.self) { code in
                        Text(code).tag(code)
                    }
                }
                .pickerStyle(.menu)
            }

            if let error = vm.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(vm.isEditing ? "Save" : "Create") {
                    vm.save()
                    if vm.errorMessage == nil { dismiss() }
                }
                .fontWeight(.semibold)
                .disabled(!vm.isValid)
            }
        }
    }
}

#Preview {
    GroupFormView()
        .modelContainer(PreviewData.container)
}
