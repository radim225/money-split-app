import SwiftUI

struct MembersView: View {
    @Environment(\.modelContext) private var modelContext
    let group: SplitGroup
    @State private var vm: MembersViewModel?
    @State private var memberToEdit: Member? = nil

    var body: some View {
        Group {
            if let vm {
                MembersContent(vm: vm, group: group, memberToEdit: $memberToEdit)
            }
        }
        .onAppear {
            if vm == nil {
                vm = MembersViewModel(group: group, context: modelContext)
            }
        }
    }
}

private struct MembersContent: View {
    @ObservedObject var vm: MembersViewModel
    let group: SplitGroup
    @Binding var memberToEdit: Member?

    var body: some View {
        List {
            if vm.members.isEmpty {
                EmptyStateView(
                    systemImage: "person.badge.plus",
                    title: "No Members",
                    message: "Add people to this group.",
                    actionTitle: "Add Member",
                    action: { vm.showAddSheet = true }
                )
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            } else {
                Section {
                    ForEach(vm.members) { member in
                        MemberRowView(
                            member: member,
                            currencyCode: group.currencyCode,
                            netCents: nil
                        )
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                vm.deleteMember(member)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                            Button {
                                memberToEdit = member
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    vm.showAddSheet = true
                } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
        .sheet(isPresented: $vm.showAddSheet) {
            AddMemberSheet(vm: vm)
        }
        .sheet(item: $memberToEdit) { member in
            EditMemberSheet(vm: vm, member: member)
        }
    }
}

private struct AddMemberSheet: View {
    @ObservedObject var vm: MembersViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Member name", text: $vm.newMemberName)
                        .autocorrectionDisabled()
                }
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                        ForEach(AppTheme.avatarColors, id: \.self) { hex in
                            Button {
                                vm.newMemberColorHex = hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(.white, lineWidth: 3)
                                            .opacity(vm.newMemberColorHex == hex ? 1 : 0)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                Section {
                    HStack {
                        Spacer()
                        AvatarView(name: vm.newMemberName.isEmpty ? "?" : vm.newMemberName,
                                   colorHex: vm.newMemberColorHex, size: 60)
                        Spacer()
                    }
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        vm.addMember()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!vm.isNewMemberValid)
                }
            }
        }
    }
}

private struct EditMemberSheet: View {
    @ObservedObject var vm: MembersViewModel
    let member: Member
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var colorHex: String

    init(vm: MembersViewModel, member: Member) {
        self.vm = vm
        self.member = member
        _name = State(initialValue: member.name)
        _colorHex = State(initialValue: member.avatarColorHex)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Member name", text: $name)
                        .autocorrectionDisabled()
                }
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                        ForEach(AppTheme.avatarColors, id: \.self) { hex in
                            Button {
                                colorHex = hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(.white, lineWidth: 3)
                                            .opacity(colorHex == hex ? 1 : 0)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                Section {
                    HStack {
                        Spacer()
                        AvatarView(name: name.isEmpty ? "?" : name, colorHex: colorHex, size: 60)
                        Spacer()
                    }
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("Edit Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        vm.updateMember(member, name: name, colorHex: colorHex)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MembersView(group: PreviewData.sampleGroup)
            .navigationTitle("Members")
    }
    .modelContainer(PreviewData.container)
}
