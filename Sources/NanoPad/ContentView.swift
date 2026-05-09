import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: NoteStore

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            EditorView(text: $store.content)
                .background(Color(nsColor: .textBackgroundColor))
            Divider()
            statusBar
        }
        .frame(width: 380, height: 440)
    }

    private var toolbar: some View {
        HStack(spacing: 4) {
            Button(action: { store.newNote() }) {
                Image(systemName: "plus.square")
            }
            .buttonStyle(.borderless)
            .help("New Note")

            Spacer()

            Button(action: { AppDelegate.shared?.showPreferences() }) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.borderless)
            .help("Preferences")

            Button(action: { AppDelegate.shared?.closePopover() }) {
                Image(systemName: "xmark.circle")
            }
            .buttonStyle(.borderless)
            .help("Close")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var statusBar: some View {
        HStack {
            Text("\(store.wordCount) words")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            if store.isSaving {
                ProgressView()
                    .scaleEffect(0.5)
                    .frame(width: 12, height: 12)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}
