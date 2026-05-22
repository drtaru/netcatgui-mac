import Foundation
import Network

enum SendStatus {
    case idle, sending, success, failure
}

@MainActor
final class PayloadSender: ObservableObject {
    @Published var status = "Idle..."
    @Published var statusType: SendStatus = .idle
    @Published var isSending = false

    func send(host: String, port: UInt16, filePath: String) {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            status = "Error: could not read file"
            statusType = .failure
            return
        }

        isSending = true
        status = "Connecting..."
        statusType = .sending

        let connection = NWConnection(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(rawValue: port)!,
            using: .tcp
        )

        connection.stateUpdateHandler = { [weak self] state in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch state {
                case .ready:
                    self.status = "Sending \(data.count) bytes…"
                    connection.send(content: data, completion: .contentProcessed { error in
                        Task { @MainActor [weak self] in
                            guard let self else { return }
                            if let error {
                                self.status = "Error: \(error.localizedDescription)"
                                self.statusType = .failure
                            } else {
                                self.status = "Done — \(data.count) bytes sent"
                                self.statusType = .success
                            }
                            connection.cancel()
                            self.isSending = false
                        }
                    })
                case .failed(let error):
                    self.status = "Failed: \(error.localizedDescription)"
                    self.statusType = .failure
                    self.isSending = false
                case .cancelled:
                    break
                default:
                    break
                }
            }
        }

        connection.start(queue: .global())
    }
}
