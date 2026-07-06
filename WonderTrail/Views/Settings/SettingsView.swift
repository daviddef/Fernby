import SwiftUI

struct SettingsView: View {
    let onDismiss: () -> Void

    @AppStorage("wt.voiceEnabled") private var voiceEnabled = true
    @AppStorage("wt.hapticsEnabled") private var hapticsEnabled = true
    @State private var showDeleteConfirm = false
    @State private var showDeleteDone = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Sound & Feedback") {
                    Toggle("Spoken instructions", isOn: $voiceEnabled)
                        .onChange(of: voiceEnabled) { _, newValue in Voice.shared.enabled = newValue }
                    Toggle("Gentle taps", isOn: $hapticsEnabled)
                        .onChange(of: hapticsEnabled) { _, newValue in Haptics.shared.enabled = newValue }
                }

                Section {
                    NavigationLink("Preview Letter Sounds") {
                        PhonicsPreviewView()
                    }
                    NavigationLink("What's Your Companion Learning?") {
                        ParentDashboardView()
                    }
                } header: {
                    Text("Grown-Up Tools")
                } footer: {
                    Text("Preview Letter Sounds plays every phonics sound this app teaches, so you can check pronunciation before a child hears it.")
                }

                Section {
                    Button("Delete data on this device", role: .destructive) {
                        showDeleteConfirm = true
                    }
                } header: {
                    Text("Privacy & Data")
                } footer: {
                    Text("Everything WonderTrail knows about this child — quest progress, mastery, session history — stays on this device. Nothing is sent anywhere. This clears it and starts fresh, useful between test sessions with different children.")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done", action: onDismiss)
                }
            }
            .alert("Delete all local data?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    ProgressStore.shared.resetActiveProfileData()
                    SessionLog.shared.deleteAll()
                    showDeleteDone = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes quest progress, mastery, and session history for this device. It cannot be undone.")
            }
            .alert("Data deleted", isPresented: $showDeleteDone) {
                Button("OK") {}
            }
        }
    }
}
