import SwiftUI

enum BottomTab: String, CaseIterable {
    case history = "History"
    case library = "Library"
    case timer = "Timer"

    var icon: String {
        switch self {
        case .history:
            return "archivebox.fill"
        case .library:
            return "books.vertical.fill"
        case .timer:
            return "timer"
        }
    }
}

struct AppRootView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedTab: BottomTab = .history
    @State private var selectedTemplateTitle: String?
    @State private var isAddFishScreenPresented = false
    @State private var addFishTemplateTitle: String?

    var body: some View {
        GeometryReader { geo in
            let rawWidth = geo.size.width
            let baseScale = rawWidth.isFinite && rawWidth > 0 ? (rawWidth / 393.0) : 1.0
            let scale = min(max(baseScale, 0.82), 1.15)

            ZStack {
                Image("bg")
                    .resizable()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    if let selectedTemplateTitle {
                        TemplateEditScreen(
                            scale: scale,
                            templateTitle: selectedTemplateTitle,
                            onBack: { self.selectedTemplateTitle = nil },
                            onUseTemplate: { templateTitle in
                                self.selectedTemplateTitle = nil
                                addFishTemplateTitle = templateTitle
                                isAddFishScreenPresented = true
                            }
                        )
                    } else if isAddFishScreenPresented {
                        AddFishScreen(
                            scale: scale,
                            onBack: {
                                isAddFishScreenPresented = false
                                addFishTemplateTitle = nil
                            },
                            onSaved: {
                                isAddFishScreenPresented = false
                                addFishTemplateTitle = nil
                                selectedTab = .history
                            },
                            initialTemplateTitle: addFishTemplateTitle
                        )
                    } else {
                        switch selectedTab {
                        case .history:
                            ArchiveAssessmentsScreen(
                                scale: scale,
                                isAssessmentsEmpty: store.assessments.isEmpty,
                                isCooksEmpty: store.cookingRecords.isEmpty,
                                onTemplateTap: { title in selectedTemplateTitle = title },
                                onAddFishTap: {
                                    addFishTemplateTitle = nil
                                    isAddFishScreenPresented = true
                                }
                            )
                        case .library:
                            LibraryScreen(scale: scale)
                        case .timer:
                            TimerScreen(
                                scale: scale,
                                onBack: { selectedTab = .history }
                            )
                        }
                    }

                    if selectedTemplateTitle == nil && !isAddFishScreenPresented {
                        BottomGlassTabBar(selectedTab: $selectedTab, scale: scale)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct PlaceholderScreen: View {
    let title: String
    let scale: CGFloat

    var body: some View {
        VStack(spacing: 10 * scale) {
            Spacer()
            Text(title)
                .font(.system(size: 28 * scale, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 8, y: 3)
            Text("Coming soon")
                .font(.system(size: 16 * scale, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct BottomGlassTabBar: View {
    @Binding var selectedTab: BottomTab
    let scale: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 296 * scale, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.968, green: 0.968, blue: 0.968), Color(red: 0.968, green: 0.968, blue: 0.968)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(Color.white.opacity(0.5))
                    .overlay(Color.black.opacity(0.004))
                    .frame(width: 286 * scale, height: 54 * scale)

                RoundedRectangle(cornerRadius: 1000 * scale, style: .continuous)
                    .fill(Color.black.opacity(0.04))
                    .blur(radius: 10 * scale)
                    .frame(width: 234 * scale, height: 4 * scale)
                    .offset(y: 20 * scale)

                HStack(spacing: -10 * scale) {
                    ForEach(BottomTab.allCases, id: \.self) { tab in
                        tabButton(for: tab)
                    }
                }
                .frame(width: 286 * scale, height: 54 * scale)
            }
            .frame(width: 393 * scale, height: 95 * scale)
            .padding(.top, 16 * scale)
            .padding(.horizontal, 25 * scale)
            .padding(.bottom, 25 * scale)
        }
        .frame(width: 393 * scale, height: 95 * scale)
    }

    private func tabButton(for tab: BottomTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 1 * scale) {
                Image(systemName: tab.icon)
                    .font(.system(size: 17 * scale, weight: isSelected ? .semibold : .regular))
                    .frame(width: 86 * scale, height: 28 * scale)

                Text(tab.rawValue)
                    .font(.system(size: 10 * scale, weight: isSelected ? .semibold : .medium))
                    .tracking(-0.1 * scale)
                    .frame(width: 86 * scale, height: 12 * scale)
            }
            .foregroundStyle(isSelected ? Color(red: 0.169, green: 0.098, blue: 0.706) : Color(red: 0.251, green: 0.251, blue: 0.251))
            .frame(width: 102 * scale, height: 54 * scale)
            .background(
                RoundedRectangle(cornerRadius: 100 * scale, style: .continuous)
                    .fill(isSelected ? Color(red: 0.929, green: 0.929, blue: 0.929) : .clear)
                    .blendMode(.plusDarker)
            )
        }
        .buttonStyle(SoundPlainButtonStyle())
    }
}

#Preview {
    AppRootView()
        .environmentObject(AppDataStore())
}
