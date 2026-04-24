import SwiftUI
import UIKit

private struct FreshnessLineData: Identifiable {
    let id: UUID
    let title: String
    let selectedValue: String
    let unselectedValue: String
}

struct TemplateEditScreen: View {
    @EnvironmentObject private var store: AppDataStore
    let scale: CGFloat
    let templateTitle: String
    let onBack: () -> Void
    let onUseTemplate: (String) -> Void

    @State private var freshnessRows: [FreshnessLineData] = []
    @State private var selectionByRow: [UUID: Bool] = [:]
    @State private var showAddCategorySheet = false
    @State private var newCategoryName = ""
    @State private var newFirstPoint = ""
    @State private var newSecondPoint = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                navBar

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24 * scale) {
                        checklistCard
                    }
                    .padding(.top, 24 * scale)
                    .padding(.horizontal, 16 * scale)
                    .padding(.bottom, 16 * scale)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8 * scale) {
                    Button {
                        onUseTemplate(templateTitle)
                    } label: {
                        Text("Use template")
                            .font(.system(size: 20 * scale, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 56 * scale)
                            .background(Color(red: 0.169, green: 0.098, blue: 0.706))
                            .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
                    }
                    .buttonStyle(SoundPlainButtonStyle())
                    .padding(.horizontal, 16 * scale)

                    saveButton
                        .padding(.horizontal, 16 * scale)
                }
                .padding(.top, 8 * scale)
                .background(Color.clear)
            }

            if showAddCategorySheet {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showAddCategorySheet = false
                    }

                addCategorySheet
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showAddCategorySheet)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            if freshnessRows.isEmpty {
                let source = store.template(by: templateTitle)?.items ?? []
                freshnessRows = source.map {
                    FreshnessLineData(id: $0.id, title: $0.title, selectedValue: $0.goodOption, unselectedValue: $0.badOption)
                }
                selectionByRow = Dictionary(uniqueKeysWithValues: freshnessRows.map { ($0.id, true) })
            }
        }
    }

    private var navBar: some View {
        HStack {
            Button(action: onBack) {
                Circle()
                    .fill(Color(red: 0.169, green: 0.098, blue: 0.706))
                    .frame(width: 42 * scale, height: 42 * scale)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15 * scale, weight: .semibold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(SoundPlainButtonStyle())

            Spacer()

            Text(templateTitle)
                .font(.system(size: 34 * scale, weight: .semibold))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer()

            Color.clear
                .frame(width: 42 * scale, height: 42 * scale)
        }
        .padding(.horizontal, 16 * scale)
        .frame(height: 46 * scale)
        .padding(.top, 8 * scale)
    }

    private var checklistCard: some View {
        VStack(alignment: .leading, spacing: 24 * scale) {
            Text("Freshness Checklist")
                .font(.system(size: 24 * scale, weight: .semibold))
                .foregroundStyle(.black)

            VStack(spacing: 24 * scale) {
                ForEach(freshnessRows) { row in
                    freshnessLine(row)
                }
            }

            Button(action: { showAddCategorySheet = true }) {
                HStack(spacing: 4 * scale) {
                    Image(systemName: "plus")
                        .font(.system(size: 20 * scale, weight: .medium))
                        .foregroundStyle(.black)
                    Text("Add")
                        .font(.system(size: 17 * scale, weight: .medium))
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity, minHeight: 52 * scale)
                .background(Color(red: 0.737, green: 0.737, blue: 0.929))
                .overlay(
                    RoundedRectangle(cornerRadius: 16 * scale, style: .continuous)
                        .stroke(Color(red: 0.169, green: 0.098, blue: 0.706), lineWidth: 2 * scale)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
            }
            .buttonStyle(SoundPlainButtonStyle())
        }
        .padding(.vertical, 20 * scale)
        .padding(.horizontal, 16 * scale)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.965, green: 0.98, blue: 0.996))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
    }

    private func freshnessLine(_ row: FreshnessLineData) -> some View {
        let isLeftSelected = selectionByRow[row.id] ?? true
        return HStack {
            Text(row.title)
                .font(.system(size: 20 * scale, weight: .semibold))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer()

            HStack(spacing: 12 * scale) {
                Button {
                    selectionByRow[row.id] = true
                } label: {
                    Text(row.selectedValue)
                        .font(.system(size: 17 * scale, weight: .semibold))
                        .foregroundStyle(isLeftSelected ? .white : .black.opacity(0.5))
                        .frame(width: 72 * scale, height: 28 * scale)
                        .background(
                            RoundedRectangle(cornerRadius: 8 * scale, style: .continuous)
                                .fill(isLeftSelected ? Color(red: 0.169, green: 0.098, blue: 0.706) : .clear)
                        )
                }
                .buttonStyle(SoundPlainButtonStyle())

                Button {
                    selectionByRow[row.id] = false
                } label: {
                    Text(row.unselectedValue)
                        .font(.system(size: 17 * scale, weight: .semibold))
                        .foregroundStyle(isLeftSelected ? .black.opacity(0.5) : .white)
                        .frame(width: 72 * scale, height: 28 * scale)
                        .background(
                            RoundedRectangle(cornerRadius: 8 * scale, style: .continuous)
                                .fill(isLeftSelected ? .clear : Color(red: 0.169, green: 0.098, blue: 0.706))
                        )
                }
                .buttonStyle(SoundPlainButtonStyle())
            }
            .padding(12 * scale)
            .frame(width: 180 * scale, height: 52 * scale)
            .background(Color(red: 0.91, green: 0.91, blue: 0.965))
            .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
        }
        .frame(height: 52 * scale)
    }

    private var saveButton: some View {
        Button(action: saveTemplate) {
            Text("Save")
                .font(.system(size: 20 * scale, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 56 * scale)
                .background(Color(red: 0.169, green: 0.098, blue: 0.706))
                .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
        }
        .buttonStyle(SoundPlainButtonStyle())
    }

    private var addCategorySheet: some View {
        VStack(spacing: 16 * scale) {
            VStack(spacing: 10 * scale) {
                Capsule()
                    .fill(Color(red: 0.8, green: 0.8, blue: 0.8))
                    .frame(width: 36 * scale, height: 5 * scale)
                    .padding(.top, 5 * scale)

                HStack {
                    Button {
                        showAddCategorySheet = false
                    } label: {
                        Circle()
                            .fill(Color(red: 120.0 / 255.0, green: 120.0 / 255.0, blue: 128.0 / 255.0).opacity(0.16))
                            .frame(width: 44 * scale, height: 44 * scale)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 17 * scale, weight: .medium))
                                    .foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.6))
                            )
                    }
                    .buttonStyle(SoundPlainButtonStyle())

                    Spacer()

                    Text("Add category")
                        .font(.system(size: 36.0 / 2 * scale, weight: .semibold))
                        .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))

                    Spacer()

                    Color.clear
                        .frame(width: 44 * scale, height: 44 * scale)
                }
                .padding(.horizontal, 16 * scale)
            }
            .frame(height: 72 * scale)

            VStack(alignment: .leading, spacing: 12 * scale) {
                Text("Name")
                    .font(.system(size: 17 * scale, weight: .semibold))
                    .foregroundStyle(.black)

                field(text: $newCategoryName, placeholder: "Category name")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 12 * scale) {
                Text("Key points")
                    .font(.system(size: 17 * scale, weight: .semibold))
                    .foregroundStyle(.black)

                field(text: $newFirstPoint, placeholder: "First points")
                field(text: $newSecondPoint, placeholder: "Second points")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                addCategory()
            } label: {
                Text("Add")
                    .font(.system(size: 20 * scale, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 56 * scale)
                    .background(Color(red: 0.169, green: 0.098, blue: 0.706))
                    .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
            }
            .buttonStyle(SoundPlainButtonStyle())
        }
        .padding(.horizontal, 16 * scale)
        .frame(maxWidth: .infinity)
        .frame(height: 424 * scale, alignment: .top)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 38 * scale, style: .continuous))
        .offset(y: 8 * scale)
    }

    private func field(text: Binding<String>, placeholder: String) -> some View {
        TextField("", text: text, prompt: Text(placeholder).foregroundColor(.black.opacity(0.5)))
            .font(.system(size: 17 * scale, weight: .regular))
            .padding(16 * scale)
            .frame(height: 52 * scale)
            .background(Color(red: 0.91, green: 0.91, blue: 0.965))
            .clipShape(RoundedRectangle(cornerRadius: 24 * scale, style: .continuous))
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(true)
            .submitLabel(.done)
            .onSubmit {
                dismissKeyboard()
            }
    }

    private func addCategory() {
        let title = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        let first = newFirstPoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let second = newSecondPoint.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty, !first.isEmpty, !second.isEmpty else { return }

        freshnessRows.append(
            FreshnessLineData(
                id: UUID(),
                title: title,
                selectedValue: first,
                unselectedValue: second
            )
        )
        if let last = freshnessRows.last {
            selectionByRow[last.id] = true
        }
        newCategoryName = ""
        newFirstPoint = ""
        newSecondPoint = ""
        showAddCategorySheet = false
        dismissKeyboard()
    }

    private func saveTemplate() {
        let items = freshnessRows.map {
            let isLeftSelected = selectionByRow[$0.id] ?? true
            return TemplateChecklistItem(
                id: $0.id,
                title: $0.title,
                goodOption: isLeftSelected ? $0.selectedValue : $0.unselectedValue,
                badOption: isLeftSelected ? $0.unselectedValue : $0.selectedValue
            )
        }
        store.updateTemplate(title: templateTitle, with: items)
        onBack()
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

