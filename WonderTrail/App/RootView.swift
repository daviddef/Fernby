import SwiftUI

/// v0.1 has one screen worth entering at: the world map. This indirection
/// exists so a settings screen / profile switcher (v0.3) has an obvious
/// place to attach later without reshuffling the app entry point. The
/// NavigationStack exists only to host WorldMapView's Settings toolbar item.
struct RootView: View {
    var body: some View {
        NavigationStack {
            WorldMapView()
        }
    }
}
