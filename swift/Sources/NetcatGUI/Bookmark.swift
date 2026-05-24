import Foundation

struct Bookmark: Codable, Identifiable {
    var id: UUID
    var name: String
    var host: String
    var port: String
    var filePath: String

    init(id: UUID = UUID(), name: String, host: String, port: String, filePath: String) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.filePath = filePath
    }
}
