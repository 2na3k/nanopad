import SwiftUI

struct PreferencesView: View {
    @AppStorage("fontSize") private var fontSize: Double = 10

    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 12) {
                Text("Font Size: \(Int(fontSize))")
                    .font(.headline)

                Slider(value: $fontSize, in: 10...24, step: 1)

                Divider()

                HStack {
                    Text("Global Hotkey")
                    Spacer()
                    Text("⌥ Space")
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(4)
                }

                Text("Requires Accessibility permission in System Settings > Privacy & Security.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .frame(width: 320, height: 200)
    }
}
