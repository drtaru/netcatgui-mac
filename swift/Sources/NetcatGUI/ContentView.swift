import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var sender = PayloadSender()
    @State private var host = ""
    @State private var port = ""
    @State private var filePath = ""

    private var canSend: Bool {
        !sender.isSending && !host.isEmpty && !port.isEmpty && !filePath.isEmpty
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                TextField("IP Address", text: $host)
                    .textFieldStyle(.roundedBorder)
                TextField("Port", text: $port)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 70)
            }

            HStack(spacing: 8) {
                TextField("File path", text: $filePath)
                    .textFieldStyle(.roundedBorder)
                Button("…") { selectFile() }
                    .frame(width: 32)
            }

            Button("Inject Payload") { sendPayload() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(!canSend)

            Text(sender.status)
                .font(.headline)
                .foregroundStyle(statusColor)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .frame(width: 430)
    }

    private var statusColor: Color {
        switch sender.statusType {
        case .idle:    return .secondary
        case .sending: return .blue
        case .success: return .green
        case .failure: return .red
        }
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        if panel.runModal() == .OK {
            filePath = panel.url?.path ?? ""
        }
    }

    private func sendPayload() {
        guard let portNum = UInt16(port) else {
            sender.status = "Invalid port number"
            sender.statusType = .failure
            return
        }
        sender.send(host: host, port: portNum, filePath: filePath)
    }
}
