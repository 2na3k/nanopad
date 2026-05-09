import AppKit

enum SyntaxHighlighter {
    static func apply(to textView: NSTextView) {
        guard let textStorage = textView.textStorage,
              let font = textView.font
        else { return }

        let fullRange = NSRange(location: 0, length: textStorage.length)
        let nsString = textStorage.string as NSString

        textStorage.setAttributes(
            [.font: font, .foregroundColor: NSColor.labelColor],
            range: fullRange
        )

        let headerRegex = try! NSRegularExpression(pattern: "^#{1,6} .+", options: .anchorsMatchLines)
        enumerate(headerRegex, in: nsString) { range in
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: range)
            let descriptor = font.fontDescriptor.addingAttributes([.size: font.pointSize + 3])
            if let boldFont = NSFont(descriptor: descriptor, size: 0) {
                textStorage.addAttribute(.font, value: boldFont, range: range)
            }
        }

        let boldRegex = try! NSRegularExpression(pattern: "\\*\\*[^\\*]+\\*\\*")
        enumerate(boldRegex, in: nsString) { range in
            textStorage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: font.pointSize), range: range)
        }

        let italicRegex = try! NSRegularExpression(pattern: "(?<!\\*)\\*[^*\\n]+\\*(?!\\*)")
        enumerate(italicRegex, in: nsString) { range in
            let italicFont = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
            textStorage.addAttribute(.font, value: italicFont, range: range)
        }

        let codeRegex = try! NSRegularExpression(pattern: "`[^`]+`")
        enumerate(codeRegex, in: nsString) { range in
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemOrange, range: range)
            textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: font.pointSize, weight: .medium), range: range)
        }

        let uncheckedRegex = try! NSRegularExpression(pattern: "- \\[ \\]")
        enumerate(uncheckedRegex, in: nsString) { range in
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemRed, range: range)
        }

        let checkedRegex = try! NSRegularExpression(pattern: "- \\[x\\]")
        enumerate(checkedRegex, in: nsString) { range in
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: range)
            let lineRange = nsString.lineRange(for: range)
            let lineText = nsString.substring(with: lineRange).trimmingCharacters(in: .newlines)
            if !lineText.isEmpty {
                textStorage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: lineRange)
                textStorage.addAttribute(.strikethroughColor, value: NSColor.secondaryLabelColor, range: lineRange)
                textStorage.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: lineRange)
            }
        }
    }

    private static func enumerate(_ regex: NSRegularExpression, in nsString: NSString, using block: (NSRange) -> Void) {
        let fullRange = NSRange(location: 0, length: nsString.length)
        regex.enumerateMatches(in: nsString as String, range: fullRange) { match, _, _ in
            guard let range = match?.range else { return }
            block(range)
        }
    }
}
