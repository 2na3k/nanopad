# NanoPad

> A featherweight syntax note‑taking app that lives in your macOS menu bar.

## Philosophy

NanoPad is a **single‑purpose** tool: a checklist scratchpad that is always one
click (or keystroke) away. It launches at login, sits quietly in the menu bar,
and disappears when you don't need it. No windows, no tabs, no distractions.

## Core Features

| # | Feature | Detail |
|---|---------|--------|
| 1 | **Menu‑bar only** | Pure `NSStatusItem`/`MenuBarExtra` app. No dock icon, no window manager entry. |
| 2 | **Instant access** | Click the menu‑bar icon **or** press a global hotkey (`⌥ Space`) to toggle the popover. |
| 3 | **Checklist syntax** | Lines starting with `- [ ]` or `- [x]` render as interactive checkboxes. |
| 4 | **Plain‑text storage** | Notes are saved as a single `.md` file in `~/Library/Application Support/com.nanopad/`. |
| 5 | **Minimal formatting** | Inline `*italic*`, `**bold**`, `` `code` `` and `# Headers` – just enough to be useful. |
| 6 | **Auto‑save** | Every keystroke is flushed to disk immediately (debounced 500 ms). |
| 7 | **Dark mode** | Respects the system appearance automatically. |

## Syntax Reference

```
# Today's Tasks

- [ ] Buy groceries          ← unchecked
- [x] File taxes             ← checked (toggled via click)

## Notes

This is *italic* and this is **bold**.
Use `code` for inline snippets.

- A plain bullet
- Another bullet
```

Only the checklist syntax is interactive – the rest is display‑only formatting.

## Architecture (High‑Level)

```
┌─────────────────────────────────────────────┐
│              NanoPad App                     │
│  ┌───────────────────────────────────────┐  │
│  │         MenuBarExtra / NSStatusItem    │  │
│  │   Icon: ☐  (unfilled checkbox)        │  │
│  └──────────────────┬────────────────────┘  │
│                     ▼                       │
│  ┌───────────────────────────────────────┐  │
│  │            NSPopover                   │  │
│  │  ┌─────────────────────────────────┐  │  │
│  │  │  NSTextView (editing area)      │  │  │
│  │  │  • Syntax highlighting          │  │  │
│  │  │  • Checklist hit‑testing        │  │  │
│  │  └─────────────────────────────────┘  │  │
│  │  ┌─────────────────────────────────┐  │  │
│  │  │  Toolbar (New / Pin / Trash)    │  │  │
│  │  └─────────────────────────────────┘  │  │
│  └───────────────────────────────────────┘  │
│                                             │
│  ┌───────────────────────────────────────┐  │
│  │        Storage Layer                  │  │
│  │  FileManager + Codable → ~/Library/… │  │
│  └───────────────────────────────────────┘  │
│                                             │
│  ┌───────────────────────────────────────┐  │
│  │     Global Hotkey (CGEvent)           │  │
│  │  Register via MediaKeyTap / MAS      │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

## Building

Requires Xcode ≥15 and macOS 13+.

```bash
swift build -c release
```

The binary is at `.build/arm64-apple-macosx/release/NanoPad`. To create a
standalone `.app` bundle:

```bash
mkdir -p NanoPad.app/Contents/MacOS
cp .build/arm64-apple-macosx/release/NanoPad NanoPad.app/Contents/MacOS/
cp Sources/NanoPad/Info.plist NanoPad.app/Contents/Info.plist
plutil -replace CFBundleExecutable -string NanoPad NanoPad.app/Contents/Info.plist
codesign --force --sign - NanoPad.app
```

Then drag `NanoPad.app` to `/Applications`.

## Releasing

NanoPad uses semantic versioning with a `v` prefix:

| Git tag     | Example |
|-------------|---------|
| `v1.2.3`    | Bug fix or minor change |
| `v1.3.0`    | New feature (backward-compatible) |
| `v2.0.0`    | Breaking change |

**To cut a new release:**

```bash
# 1. Tag the current commit
git tag v1.0.0

# 2. Push the tag — the CI pipeline builds the DMG and creates a
#    GitHub Release automatically.
git push origin v1.0.0
```

The CI workflow (`.github/workflows/build.yml`) will:

1. Build the release binary.
2. Sign the `.app` bundle.
3. Generate `NanoPad-<version>.dmg`.
4. Create a GitHub Release with the DMG attached.

You can also download the `.app` artifact from any CI run on `main` via the
Actions tab, without cutting a full release.

## File Tree

```
NanoPad/
├── Package.swift                 # SwiftPM manifest
├── Sources/NanoPad/
│   ├── NanoPadApp.swift          # @main, NSStatusItem + NSPopover
│   ├── ContentView.swift         # Toolbar + editor layout
│   ├── EditorView.swift          # ChecklistTextView with syntax highlighting
│   ├── NoteStore.swift           # Persistence with auto-save
│   ├── SyntaxHighlighter.swift   # Regex-based NSAttributedString
│   ├── HotKeyManager.swift       # Global ⌥ Space hotkey
│   ├── PreferencesView.swift     # Font size + hotkey info
│   └── Info.plist                # LSUIElement = YES
├── .github/workflows/build.yml   # CI: build + DMG release
├── LICENSE
└── README.md
```

## License

MIT — see [LICENSE](LICENSE).
