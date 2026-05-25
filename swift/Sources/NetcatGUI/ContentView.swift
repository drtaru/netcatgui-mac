import SwiftUI
import AppKit
import Darwin

struct ContentView: View {
    @EnvironmentObject var bookmarkStore: BookmarkStore
    @StateObject private var sender = PayloadSender()
    @State private var host = ""
    @State private var port = "50000"
    @State private var filePath = UserDefaults.standard.string(forKey: "lastFilePath") ?? ""
    @State private var showingBookmarkAlert = false
    @State private var bookmarkName = ""

    private var canSend: Bool {
        !sender.isSending && !host.isEmpty && !port.isEmpty && !filePath.isEmpty
    }

    private var canSaveBookmark: Bool {
        !host.isEmpty && !port.isEmpty && !filePath.isEmpty
    }

    var body: some View {
        navigationContainer
            .sheet(isPresented: $showingBookmarkAlert) {
                VStack(spacing: 16) {
                    Text("Save Bookmark").font(.headline)
                    TextField("Name", text: $bookmarkName)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 220)
                    HStack(spacing: 12) {
                        Button("Cancel") {
                            bookmarkName = ""
                            showingBookmarkAlert = false
                        }
                        Button("Save") {
                            guard !bookmarkName.isEmpty else { return }
                            bookmarkStore.add(name: bookmarkName, host: host, port: port, filePath: filePath)
                            bookmarkName = ""
                            showingBookmarkAlert = false
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(bookmarkName.isEmpty)
                    }
                }
                .padding(24)
            }
    }

    @ViewBuilder
    private var navigationContainer: some View {
        if #available(macOS 13, *) {
            NavigationSplitView {
                sidebarContent
            } detail: {
                detailContent
            }
        } else {
            NavigationView {
                sidebarContent
                detailContent
            }
        }
    }

    private var sidebarContent: some View {
        BookmarksView { bookmark in
            host = bookmark.host
            port = bookmark.port
            filePath = bookmark.filePath
        }
        .environmentObject(bookmarkStore)
    }

    private var detailContent: some View {
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

            Text(sender.status)
                .font(.callout)
                .foregroundStyle(statusColor)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                Button("Inject Payload") { sendPayload() }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canSend)
                Spacer()
                Button("Save Bookmark") { showingBookmarkAlert = true }
                    .buttonStyle(.bordered)
                    .disabled(!canSaveBookmark)
            }
        }
        .padding(16)
        .frame(minWidth: 300)
        .onAppear {
            host = localIPAddress() ?? ""
        }
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
            UserDefaults.standard.set(filePath, forKey: "lastFilePath")
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

    private func localIPAddress() -> String? {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        defer { freeifaddrs(ifaddr) }

        var fallback: String?
        var ptr = ifaddr
        while let current = ptr {
            defer { ptr = current.pointee.ifa_next }
            let ifa = current.pointee
            guard ifa.ifa_addr.pointee.sa_family == UInt8(AF_INET) else { continue }
            let name = String(cString: ifa.ifa_name)
            guard name != "lo0" else { continue }

            var sin = ifa.ifa_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee }
            var buf = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
            inet_ntop(AF_INET, &sin.sin_addr, &buf, socklen_t(INET_ADDRSTRLEN))
            let ip = String(cString: buf)

            if name == "en0" || name == "en1" { return ip }
            fallback = ip
        }
        return fallback
    }
}
