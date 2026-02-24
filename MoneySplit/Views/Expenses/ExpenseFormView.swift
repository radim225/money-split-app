import SwiftUI

struct ExpenseFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let group: SplitGroup
    private let expense: Expense?
    @State private var vm: ExpenseFormViewModel?

    init(group: SplitGroup, expense: Expense? = nil) {
        self.group = group
        self.expense = expense
    }

    var body: some View {
        NavigationStack {
            Group {
                if let vm {
                    ExpenseFormContent(vm: vm, group: group, dismiss: dismiss)
                }
            }
            .navigationTitle(expense == nil ? "New Expense" : "Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if vm == nil {
                    vm = ExpenseFormViewModel(context: modelContext, group: group, expense: expense)
                }
            }
        }
    }
}

private struct ExpenseFormContent: View {
    @ObservedObject var vm: ExpenseFormViewModel
    let group: SplitGroup
    let dismiss: DismissAction

    var orderedMembers: [Member] {
        group.members.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        Form {
            // MARK: Basic Info
            Section("Basic Info") {
                TextField("Title (e.g. Dinner, Hotel…)", text: $vm.title)
                    .autocorrectionDisabled()

                HStack {
                    Text(group.currencyCode)
                        .foregroundStyle(.secondary)
                    TextField("0.00", text: $vm.amountString)
                        .keyboardType(.decimalPad)
                        .onChange(of: vm.amountString) { vm.recalculateSplits() }
                }

                // Category chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ExpenseCategory.allCases) { cat in
                            Button {
                                vm.selectedCategory = cat
                            } label: {
                                CategoryBadge(
                                    category: cat,
                                    style: vm.selectedCategory == cat ? .pill : .compact
                                )
                                .padding(.vertical, 4)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            vm.selectedCategory == cat ? cat.accentColor : .clear,
                                            lineWidth: 1.5
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }

            // MARK: Date & Notes
            Section("Date & Notes") {
                DatePicker("Date", selection: $vm.date, displayedComponents: .date)
                TextField("Notes (optional)", text: $vm.notes, axis: .vertical)
                    .lineLimit(2...4)
            }

            // MARK: Who Paid
            Section("Who Paid") {
                ForEach(orderedMembers) { member in
                    Button {
                        vm.selectedPayerId = member.id
                    } label: {
                        HStack(spacing: 12) {
                            AvatarView(name: member.name, colorHex: member.avatarColorHex, size: 34)
                            Text(member.name)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Spacer()
                            if vm.selectedPayerId == member.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.accentColor)
                                    .font(.title3)
                            }
                        }
                    }
                }
            }

            // MARK: Split Between
            Section {
                ForEach(orderedMembers) { member in
                    Button {
                        vm.toggleMember(member.id)
                        vm.recalculateSplits()
                    } label: {
                        HStack(spacing: 12) {
                            AvatarView(name: member.name, colorHex: member.avatarColorHex, size: 34)
                            Text(member.name)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Spacer()
                            if vm.involvedMemberIds.contains(member.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.accentColor)
                                    .font(.title3)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(Color(.systemGray3))
                                    .font(.title3)
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Split Between")
                    Spacer()
                    Button(vm.involvedMemberIds.count == orderedMembers.count ? "Deselect All" : "Select All") {
                        if vm.involvedMemberIds.count == orderedMembers.count {
                            vm.deselectAllMembers()
                        } else {
                            vm.selectAllMembers()
                        }
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppTheme.accentColor)
                    .textCase(nil)
                }
            }

            // MARK: Split Method
            if !vm.involvedMemberIds.isEmpty {
                Section("Split Method") {
                    Picker("Method", selection: $vm.splitMode) {
                        ForEach(SplitMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: vm.splitMode) { vm.recalculateSplits() }
                    .padding(.vertical, 4)
                }

                Section {
                    ForEach(vm.involvedMembers) { member in
                        switch vm.splitMode {
                        case .equal:
                            SplitInputRow(
                                member: member,
                                currencyCode: group.currencyCode,
                                amountString: .constant(""),
                                isReadOnly: true,
                                displayAmount: vm.splitPreview[member.id]
                            )
                        case .manual:
                            SplitInputRow(
                                member: member,
                                currencyCode: group.currencyCode,
                                amountString: Binding(
                                    get: { vm.manualSplits[member.id] ?? "" },
                                    set: { vm.manualSplits[member.id] = $0; vm.recalculateSplits() }
                                )
                            )
                        }
                    }
                } header: {
                    Text("Amounts")
                } footer: {
                    if vm.splitMode == .manual {
                        splitFooter
                    } else if vm.remainderCents > 0 {
                        Text("±\(CurrencyFormatter.centsToInputString(vm.remainderCents)) rounding to first member")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // MARK: Validation error
            if let error = vm.validationError {
                Section {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(error)
                            .foregroundStyle(.orange)
                    }
                    .font(.subheadline)
                }
            }

            if let error = vm.saveError {
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
                Button(vm.isEditing ? "Save" : "Add") {
                    vm.save()
                    if vm.saveError == nil { dismiss() }
                }
                .fontWeight(.semibold)
                .disabled(!vm.isValid)
            }
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                        to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }

    private var splitFooter: some View {
        let total = vm.amountCents
        let assigned = vm.manualSplitTotalCents
        let diff = total - assigned
        return HStack {
            Text("Total: \(CurrencyFormatter.format(cents: total, currencyCode: group.currencyCode))")
            Spacer()
            if diff == 0 {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Balanced")
                    .foregroundStyle(.green)
            } else if diff > 0 {
                Text("\(CurrencyFormatter.format(cents: diff, currencyCode: group.currencyCode)) unassigned")
                    .foregroundStyle(.orange)
            } else {
                Text("\(CurrencyFormatter.format(cents: -diff, currencyCode: group.currencyCode)) over")
                    .foregroundStyle(.red)
            }
        }
        .font(.caption.weight(.medium))
    }
}

#Preview {
    ExpenseFormView(group: PreviewData.sampleGroup)
        .modelContainer(PreviewData.container)
}
