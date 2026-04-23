//
//  MainView.swift
//  BufalloSteaklovers
//

import SwiftUI

private func isPhoneSEClassLayout(width: CGFloat, height: CGFloat) -> Bool {
    let shortSide = min(width, height)
    let longSide = max(width, height)
    return shortSide <= 376 && longSide <= 670
}

enum SteakMainTab: Int, Hashable, CaseIterable {
    case log = 0
    case archive = 1
    case timer = 2
    case library = 3
    case stats = 4
}

private struct SteakCustomTabBar: View {
    @Binding var selection: SteakMainTab
    var bottomSafeInset: CGFloat = 0

    var isPhoneSEClass: Bool = false
    @Environment(\.layoutScale) private var scale

    var body: some View {
        let outerPadH = fpScale(25, scale)
        let outerPadTop = fpScale(20, scale)
        let bottomExtra = isPhoneSEClass ? fpScale(22, scale) : max(fpScale(2, scale), 2)
        let outerPadBottom = bottomExtra + bottomSafeInset
        let barH = fpScale(54, scale)
        let innerHPad = fpScale(2, scale)
        let shadowRadius = min(fpScale(20, scale), 24)
        let shadowY = min(fpScale(8, scale), 10)

        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(SteakMainTab.allCases, id: \.rawValue) { tab in
                    tabButton(tab, barHeight: barH)
                }
            }
            .padding(.horizontal, innerHPad)
            .frame(height: barH)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(Color(steakHex: "3E2723"))
                    .overlay(
                        Capsule()
                            .fill(Color.black.opacity(0.004))
                    )
            )
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.12), radius: shadowRadius, x: 0, y: shadowY)
        }
        .padding(.horizontal, outerPadH)
        .padding(.top, outerPadTop)
        .padding(.bottom, outerPadBottom)
        .frame(maxWidth: .infinity)
        .background(Color(steakHex: "2D1B11"))
    }

    private func tabButton(_ tab: SteakMainTab, barHeight: CGFloat) -> some View {
        let active = selection == tab
        let vGap = active ? fpScale(1, scale) : fpScale(0.5, scale)
        return Button {
            selection = tab
        } label: {
            ZStack {
                if active {
                    Capsule()
                        .fill(Color(steakHex: "FF5722"))
                        .padding(.leading, -fpScale(2, scale))
                        .padding(.trailing, -fpScale(2.4, scale))
                }
                VStack(spacing: vGap) {
                    Text(tab.tabIconEmoji)
                        .font(.system(size: fpScale(24, scale)))
                        .frame(height: fpScale(28, scale))
                        .minimumScaleFactor(0.7)
                        .grayscale(active ? 0 : 0.55)
                        .opacity(active ? 1 : 0.72)
                    Text(tab.title)
                        .font(.system(size: fpScale(10, scale), weight: .semibold))
                        .tracking(-0.1)
                        .foregroundStyle(active ? Color.white : Color(steakHex: "A1887F"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .padding(.top, fpScale(6, scale))
                .padding(.horizontal, fpScale(8, scale))
                .padding(.bottom, fpScale(7, scale))
            }
            .frame(maxWidth: .infinity)
            .frame(height: barHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(SteakSoundPlainButtonStyle())
    }
}

private extension SteakMainTab {
    var title: String {
        switch self {
        case .log: return "Log"
        case .archive: return "Archive"
        case .timer: return "Timer"
        case .library: return "Library"
        case .stats: return "Stats"
        }
    }

    var tabIconEmoji: String {
        switch self {
        case .log: return "🥩"
        case .archive: return "🦴"
        case .timer: return "⏱️"
        case .library: return "📙"
        case .stats: return "📊"
        }
    }
}

struct MainView: View {
    @StateObject private var steakRepository = SteakDataRepository()
    @StateObject private var newSteakLogViewModel = NewSteakLogViewModel()

    @State private var selectedTab: SteakMainTab = .log
    @State private var logRoute: LogTabRoute = .newSteak
    /// `-1` until measured from key window (avoids SwiftUI keyboard-inflated `GeometryReader.safeAreaInsets`).
    @State private var keyWindowBottomInset: CGFloat = -1
    @State private var didInstallGlobalButtonSound = false

    var body: some View {
        ZStack {
            Color(steakHex: "2D1B11")
                .ignoresSafeArea()

            GeometryReader { geo in
                let w = max(geo.size.width, 1)
                let stableHeight = max(geo.size.height, UIScreen.main.bounds.height)
                let scale = DesignScale.from(containerWidth: w, designWidth: SteakDesign.width)
                let bottomInset = keyWindowBottomInset >= 0 ? keyWindowBottomInset : max(geo.safeAreaInsets.bottom, 0)
                // Keep device class stable while keyboard is shown (geo height may shrink with keyboard).
                let isSE = isPhoneSEClassLayout(width: w, height: stableHeight)
                let tabReserve = steakTabBarReserveHeight(scale: scale, bottomSafeInset: bottomInset, isPhoneSEClass: isSE)

                ZStack {
                    SteakKeyWindowBottomSafeInsetReader(bottomInset: $keyWindowBottomInset)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(false)

                    ZStack(alignment: .bottom) {
                        VStack(spacing: 0) {
                            if selectedTab != .archive && selectedTab != .timer && selectedTab != .library && selectedTab != .stats {
                                SteakTabScreenHeader(title: "Buffalo Steak Lovers")
                                    .environment(\.layoutScale, scale)
                            }

                            Group {
                                switch selectedTab {
                                case .log:
                                    Group {
                                        switch logRoute {
                                        case .newSteak:
                                            NewSteakLogView(viewModel: newSteakLogViewModel) { submission in
                                                switch submission {
                                                case .savedToSuccesses:
                                                    break
                                                case .openFailureArchive(let draft):
                                                    logRoute = .analyzeFailure(draft)
                                                }
                                            }
                                            .environment(\.layoutScale, scale)
                                        case .analyzeFailure(let draft):
                                            AnalyzeFailureView(
                                                draft: draft,
                                                onBack: { logRoute = .newSteak },
                                                onSavedToArchive: {
                                                    newSteakLogViewModel.resetAfterSubmit()
                                                }
                                            )
                                            .environment(\.layoutScale, scale)
                                        }
                                    }
                                case .archive:
                                    ArchiveTabView()
                                        .environment(\.layoutScale, scale)
                                case .timer:
                                    SmartTimerView()
                                        .environment(\.layoutScale, scale)
                                case .library:
                                    KnowledgeBaseView()
                                        .environment(\.layoutScale, scale)
                                case .stats:
                                    StatsTabView()
                                        .environment(\.layoutScale, scale)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.bottom, tabReserve)
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                        SteakCustomTabBar(
                            selection: $selectedTab,
                            bottomSafeInset: bottomInset,
                            isPhoneSEClass: isSE
                        )
                        .environment(\.layoutScale, scale)
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
                .environmentObject(steakRepository)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: selectedTab) { newTab in
            if newTab != .log {
                logRoute = .newSteak
            }
        }
        .onAppear {
            guard !didInstallGlobalButtonSound else { return }
            didInstallGlobalButtonSound = true
            SteakGlobalButtonSound.installOnce()
        }
    }
}

#Preview {
    MainView()
}
