import SwiftUI

@main
struct ScreechApp: App {
    @StateObject private var model = ScreechModel()
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            ContentView().environmentObject(model).onAppear { Screenshots.apply(to: model) }
            #else
            ContentView().environmentObject(model)
            #endif
        }
    }
}
