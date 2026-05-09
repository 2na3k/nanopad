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

## Implementation Plan

### Phase 1 – Scaffold

1. Create a new **macOS App** Xcode project (SwiftUI app with `MenuBarExtra`).
2. Set `LSUIElement = YES` in `Info.plist` so the app has no dock icon.
3. Add a `MenuBarExtra` with a system‑symbol checkbox icon.
4. Present a `Popover` with a `TextEditor` inside.

### Phase 2 – Persistence

1. Define `NoteStore` – a class wrapping `UserDefaults` or file I/O.
2. Store note content in `~/Library/Application Support/com.nanopad/note.md`.
3. Implement `String` extension for reading/writing to a file path.
4. Auto‑save on a 500 ms debounce timer after every text change.

### Phase 3 – Checklist Interactivity

1. Parse the text on every edit to build a list of checklist line ranges.
2. Overlay invisible `NSButton` (or `Toggle`) frames on checklist lines.
3. When toggled, replace `- [ ]` ↔ `- [x]` in the source text.
4. Use `NSTextStorage` delegate or `NSAttributedString` for syntax
   highlighting (headers bold, checkboxes coloured, etc.).

### Phase 4 – Global Hotkey

1. Use `CGEvent` tap or `Carbon.RegisterEventHotKey` to listen for `⌥ Space`.
2. Toggle the popover's `isShown` on hotkey press.
3. Request accessibility permissions on first launch if needed.

### Phase 5 – Quality of Life

1. **Pin note** – keep popover open even after losing focus.
2. **New note** – clear content (with confirmation if unsaved).
3. **Trash / archive** – move current note to a trash folder.
4. **Drag‑to‑reorder** checklist items via `NSCollectionView`.
5. **Export / copy as plain text**.

### Phase 6 – Polish

1. Launch at login via `SMAppService` (macOS 13+) or
   `SMLoginItemSetEnabled`.
2. Preferences window (font size, hotkey rebinding, storage location).
3. Light / dark icon variants.
4. Accessibility: VoiceOver labels, full keyboard navigation.

## File Tree (Proposed)

```
NanoPad/
├── NanoPadApp.swift              # @main entry, MenuBarExtra setup
├── ContentView.swift             # Popover root view
├── EditorView.swift              # NSTextView wrapper with highlighting
├── ChecklistOverlay.swift        # Invisible toggle buttons on checklist rows
├── NoteStore.swift               # Read / write / debounce persistence
├── SyntaxHighlighter.swift       # NSAttributedString formatting
├── HotKeyManager.swift           # Global keyboard shortcut registration
├── PreferencesView.swift         # Settings pane
├── Assets.xcassets/
│   ├── Icon.pdf                  # Template image for menu bar
│   └── AccentColor.colorset/
├── Info.plist                    # LSUIElement = YES
└── README.md
```

## Potential Challenges

- **NSTextView inside SwiftUI** – Use `NSViewRepresentable` to wrap the
  text view. Managing first‑responder state across popover show/hide cycles
  requires care.
- **Checkbox hit‑testing** – The text is in a scroll view. Overlay positions
  must be recalculated on scroll, resize, and text change.
- **Global hotkey on macOS** – Modern macOS requires
  `com.apple.security.device.events` entitlement or using a helper binary.
  Consider using `TISInputSource`‑based monitoring as a lighter alternative.
- **Sandboxing** – If distributing via the Mac App Store, file access needs
  security‑scoped bookmarks or a sandbox‑compatible storage strategy.

## Non‑Goals

- Cloud sync (iCloud, Dropbox, etc.)
- Rich text / WYSIWYG editing (bold/italic is display‑only)
- Multiple documents / tabs
- Search (system‑level Spotlight can index the plain‑text file)
- Markdown export or rendering (raw `.md` is the source of truth)

---

> **NanoPad – *write it down, get it done.** *
