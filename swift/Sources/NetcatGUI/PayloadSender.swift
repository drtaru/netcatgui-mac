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

    private var timeoutTask: Task<Void, Never>?

    func send(host: String, port: UInt16, filePath: String) {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            status = "Error: could not read file"
            statusType = .failure
            return
        }

        let timeout = min(300.0, max(15.0, 10.0 + Double(data.count) / 125_000))

        isSending = true
        status = "Connecting..."
        statusType = .sending

        let connection = NWConnection(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(rawValue: port)!,
            using: .tcp
        )

        timeoutTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            guard let self, self.isSending else { return }
            connection.cancel()
            self.status = "Timed out after \(Int(timeout))s"
            self.statusType = .failure
            self.isSending = false
        }

        connection.stateUpdateHandler = { [weak self] state in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch state {
                case .ready:
                    self.status = "Sending \(data.count) bytes…"
                    connection.send(content: data, completion: .contentProcessed { error in
                        Task { @MainActor [weak self] in
                            guard let self else { return }
                            self.timeoutTask?.cancel()
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
                    self.timeoutTask?.cancel()
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
