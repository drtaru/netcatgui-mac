import Foundation

class BookmarkStore: ObservableObject {
    @Published var bookmarks: [Bookmark] = []

    private let key = "bookmarks"

    init() {
        load()
    }

    func add(name: String, host: String, port: String, filePath: String) {
        bookmarks.append(Bookmark(name: name, host: host, port: port, filePath: filePath))
        save()
    }

    func delete(at offsets: IndexSet) {
        bookmarks.remove(atOffsets: offsets)
        save()
    }

    func move(from source: IndexSet, to destination: Int) {
        bookmarks.move(fromOffsets: source, toOffset: destination)
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Bookmark].self, from: data)
        else { return }
        bookmarks = decoded
    }
}
