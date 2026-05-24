import SwiftUI

struct BookmarksView: View {
    @EnvironmentObject var store: BookmarkStore
    @State private var isEditing = false

    var onSelect: (Bookmark) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Bookmarks")
                    .font(.headline)
                Spacer()
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            if store.bookmarks.isEmpty {
                Spacer()
                Text("No bookmarks yet")
                    .foregroundColor(.secondary)
                    .font(.callout)
                Spacer()
            } else {
                List {
                    ForEach(store.bookmarks) { bookmark in
                        HStack {
                            if isEditing {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        if let idx = store.bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
                                            store.delete(at: IndexSet(integer: idx))
                                        }
                                    }
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(bookmark.name)
                                    .font(.body)
                                Text("\(bookmark.host):\(bookmark.port)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !isEditing {
                                onSelect(bookmark)
                            }
                        }
                    }
                    .onMove { store.move(from: $0, to: $1) }
                }
                .listStyle(.plain)
            }
        }
        .frame(minWidth: 180, idealWidth: 200)
    }
}
