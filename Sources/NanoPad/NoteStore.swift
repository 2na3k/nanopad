import Foundation
import Combine

final class NoteStore: ObservableObject {
    static let shared = NoteStore()

    @Published var content: String = ""
    @Published var isSaving = false

    var wordCount: Int {
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? 0
            : content.split { $0.isWhitespace || $0.isNewline }.count
    }

    private let fileURL: URL
    private var cancellables = Set<AnyCancellable>()

    init() {
        let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("com.nanopad")
        try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        fileURL = supportDir.appendingPathComponent("note.md")
        load()
        $content
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.save() }
            .store(in: &cancellables)
    }

    private func load() {
        content = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
    }

    private func save() {
        isSaving = true
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            try? self.content.write(to: self.fileURL, atomically: true, encoding: .utf8)
            DispatchQueue.main.async { self.isSaving = false }
        }
    }

    func newNote() {
        content = ""
    }

    func trashNote() {
        let trashDir = fileURL.deletingLastPathComponent().appendingPathComponent("Trash")
        try? FileManager.default.createDirectory(at: trashDir, withIntermediateDirectories: true)
        let trashURL = trashDir.appendingPathComponent("note_\(Date().timeIntervalSince1970).md")
        try? FileManager.default.moveItem(at: fileURL, to: trashURL)
        newNote()
    }
}
