import SwiftUI

@main
struct MainApp: App {
    @StateObject private var store = AppDataStore()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(store)
        }
    }
}
