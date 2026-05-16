import SwiftUI
import AppKit

final class ChecklistTextView: NSTextView {
    var onToggleCheckbox: ((NSRange, Bool) -> Void)?

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let charIndex = characterIndexForInsertion(at: point)
        guard charIndex < (textStorage?.length ?? 0) else {
            super.mouseDown(with: event); return
        }

        let nsString = string as NSString
        let lineRange = nsString.lineRange(for: NSRange(location: charIndex, length: 0))
        let line = nsString.substring(with: lineRange)
        let clickOffset = charIndex - lineRange.location

        if isCheckboxLine(line), clickOffset <= 5 {
            let isChecked = line.hasPrefix("- [x]")
            let replaceRange = NSRange(
                location: lineRange.location,
                length: min(5, lineRange.length)
            )
            let replacement = isChecked ? "- [ ] " : "- [x] "

            if shouldChangeText(in: replaceRange, replacementString: replacement) {
                textStorage?.replaceCharacters(in: replaceRange, with: replacement)
                didChangeText()
                onToggleCheckbox?(replaceRange, !isChecked)
            }
            return
        }

        super.mouseDown(with: event)
    }

    private func isCheckboxLine(_ line: String) -> Bool {
        line.hasPrefix("- [ ] ") || line.hasPrefix("- [x] ")
    }
}

struct EditorView: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.autohidesScrollers = true

        let textView = ChecklistTextView(frame: .zero)
        textView.autoresizingMask = [.width, .height]
        textView.delegate = context.coordinator
        textView.onToggleCheckbox = { _, _ in
            context.coordinator.syncText(textView)
        }
        textView.isRichText = false
        textView.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        textView.textContainerInset = NSSize(width: 12, height: 8)
        textView.allowsUndo = true
        textView.typingAttributes = [
            .font: NSFont.monospacedSystemFont(ofSize: 10, weight: .regular),
            .foregroundColor: NSColor.labelColor
        ]
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.drawsBackground = false
        textView.layoutManager?.allowsNonContiguousLayout = true

        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! ChecklistTextView
        if textView.string != text {
            let selectedRanges = textView.selectedRanges
            textView.string = text
            textView.selectedRanges = selectedRanges
        }
        if context.coordinator.highlightedText != text {
            SyntaxHighlighter.apply(to: textView)
            context.coordinator.highlightedText = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: EditorView
        var highlightedText: String?

        init(_ parent: EditorView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            syncText(textView)
        }

        func syncText(_ textView: NSTextView) {
            parent.text = textView.string
        }
    }
}
