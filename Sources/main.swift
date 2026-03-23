import SwiftUI
import AppKit

// MARK: - App Entry Point
@main
struct AppUninstallerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// MARK: - Data Models
struct AppInfo: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let bundleIdentifier: String?
    let icon: NSImage?
    var relatedFiles: [String] = []
}

enum UninstallState {
    case idle
    case analyzing
    case ready(AppInfo)
    case uninstalling
    case completed
    case error(String)
}

// MARK: - Main View
struct ContentView: View {
    @State private var state: UninstallState = .idle
    @State private var isTargeted = false
    @State private var showConfirmation = false
    @State private var currentApp: AppInfo?
    @State private var uninstallLog: [String] = []
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ZStack {
                dropZoneView
                
                switch state {
                case .idle:
                    idleView
                case .analyzing:
                    analyzingView
                case .ready(let app):
                    readyView(app: app)
                case .uninstalling:
                    uninstallingView
                case .completed:
                    completedView
                case .error(let message):
                    errorView(message: message)
                }
            }
            .frame(width: 500, height: 400)
        }
        .frame(width: 500, height: 450)
        .background(Color(NSColor.windowBackgroundColor))
        .confirmationDialog(
            "确认卸载",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("卸载", role: .destructive) {
                if let app = currentApp {
                    performUninstall(app: app)
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            if let app = currentApp {
                Text("将删除 \(app.name) 及其 \(app.relatedFiles.count) 个关联文件，此操作不可撤销！")
            }
        }
    }
    
    // MARK: - Header
    var headerView: some View {
        HStack {
            Image(systemName: "trash.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.red)
            Text("App Uninstaller")
                .font(.headline)
            Spacer()
            if case .ready = state {
                Button("重新选择") {
                    resetState()
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Drop Zone
    var dropZoneView: some View {
        Rectangle()
            .fill(Color.clear)
            .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
                handleDrop(providers: providers)
                return true
            }
    }
    
    // MARK: - State Views
    var idleView: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 3, dash: [10])
                    )
                    .foregroundColor(isTargeted ? .blue : .gray.opacity(0.5))
                    .animation(.easeInOut(duration: 0.2), value: isTargeted)
                
                VStack(spacing: 16) {
                    Image(systemName: "arrow.down.app.fill")
                        .font(.system(size: 60))
                        .foregroundColor(isTargeted ? .blue : .gray)
                    
                    Text("拖放应用到此处")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    Text("将要卸载的 .app 文件拖到这里")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 350, height: 250)
            .scaleEffect(isTargeted ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isTargeted)
        }
    }
    
    var analyzingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("正在分析应用...")
                .font(.headline)
        }
    }
    
    func readyView(app: AppInfo) -> some View {
        VStack(spacing: 16) {
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 80, height: 80)
            } else {
                Image(systemName: "app.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
            }
            
            Text(app.name)
                .font(.title2.bold())
            
            if let bundleId = app.bundleIdentifier {
                Text(bundleId)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("将删除以下 \(app.relatedFiles.count) 个文件:")
                    .font(.subheadline.bold())
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(app.relatedFiles, id: \.self) { file in
                            HStack {
                                Image(systemName: "doc.fill")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                Text(file)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                    }
                }
                .frame(maxHeight: 120)
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                currentApp = app
                showConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("卸载应用")
                }
                .frame(width: 200, height: 40)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
    
    var uninstallingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("正在卸载...")
                .font(.headline)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(uninstallLog, id: \.self) { log in
                        Text(log)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxHeight: 100)
            .padding(.horizontal, 30)
        }
    }
    
    var completedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("卸载完成！")
                .font(.title2.bold())
            
            Text("建议重启电脑以确保后台服务完全终止")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("继续卸载其他应用") {
                resetState()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("卸载失败")
                .font(.title2.bold())
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("重试") {
                resetState()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - Actions
    func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil),
                  url.pathExtension == "app" else {
                DispatchQueue.main.async {
                    state = .error("请拖入 .app 格式的应用程序")
                }
                return
            }
            
            DispatchQueue.main.async {
                analyzeApp(at: url.path)
            }
        }
    }
    
    func analyzeApp(at path: String) {
        state = .analyzing
        
        DispatchQueue.global(qos: .userInitiated).async {
            let analyzer = AppAnalyzer()
            let result = analyzer.analyze(appPath: path)
            
            DispatchQueue.main.async {
                switch result {
                case .success(let app):
                    state = .ready(app)
                case .failure(let error):
                    state = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func performUninstall(app: AppInfo) {
        state = .uninstalling
        uninstallLog = []
        
        DispatchQueue.global(qos: .userInitiated).async {
            let uninstaller = AppUninstaller()
            uninstaller.uninstall(app: app) { log in
                DispatchQueue.main.async {
                    uninstallLog.append(log)
                }
            } completion: { success, error in
                DispatchQueue.main.async {
                    if success {
                        state = .completed
                    } else {
                        state = .error(error ?? "未知错误")
                    }
                }
            }
        }
    }
    
    func resetState() {
        state = .idle
        currentApp = nil
        uninstallLog = []
    }
}

// MARK: - App Analyzer
class AppAnalyzer {
    func analyze(appPath: String) -> Result<AppInfo, Error> {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: appPath) else {
            return .failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "应用不存在"]))
        }
        
        let appName = (appPath as NSString).lastPathComponent.replacingOccurrences(of: ".app", with: "")
        let bundleIdentifier = getBundleIdentifier(at: appPath)
        let icon = getAppIcon(at: appPath)
        
        var relatedFiles = findRelatedFiles(appName: appName, bundleIdentifier: bundleIdentifier)
        relatedFiles.append(appPath)
        
        let app = AppInfo(
            name: appName,
            path: appPath,
            bundleIdentifier: bundleIdentifier,
            icon: icon,
            relatedFiles: relatedFiles
        )
        
        return .success(app)
    }
    
    private func getBundleIdentifier(at path: String) -> String? {
        let plistPath = (path as NSString).appendingPathComponent("Contents/Info.plist")
        guard let plist = NSDictionary(contentsOfFile: plistPath) else { return nil }
        return plist["CFBundleIdentifier"] as? String
    }
    
    private func getAppIcon(at path: String) -> NSImage? {
        return NSWorkspace.shared.icon(forFile: path)
    }
    
    private func findRelatedFiles(appName: String, bundleIdentifier: String?) -> [String] {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        
        let searchPaths = [
            "\(homeDir)/Library/Application Support",
            "\(homeDir)/Library/Preferences",
            "\(homeDir)/Library/Caches",
            "\(homeDir)/Library/Logs",
            "\(homeDir)/Library/Saved Application State",
            "\(homeDir)/Library/HTTPStorages",
            "\(homeDir)/Library/WebKit",
            "\(homeDir)/Library/Containers",
            "/Library/Application Support",
            "/Library/Preferences",
            "/Library/Caches",
            "/Library/Logs"
        ]
        
        var files: [String] = []
        let fileManager = FileManager.default
        
        for searchPath in searchPaths {
            guard fileManager.fileExists(atPath: searchPath) else { continue }
            
            if let enumerator = fileManager.enumerator(
                at: URL(fileURLWithPath: searchPath),
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) {
                for case let fileURL as URL in enumerator {
                    let relativePath = fileURL.path.replacingOccurrences(of: searchPath, with: "")
                    let pathDepth = relativePath.components(separatedBy: "/").count - 1
                    
                    if pathDepth > 3 {
                        enumerator.skipDescendants()
                        continue
                    }
                    
                    let fileName = fileURL.lastPathComponent.lowercased()
                    let filePath = fileURL.path.lowercased()
                    let appNameLower = appName.lowercased()
                    let bundleIdLower = bundleIdentifier?.lowercased() ?? ""
                    
                    if fileName.contains(appNameLower) ||
                       filePath.contains("/\(appNameLower)/") ||
                       (!bundleIdLower.isEmpty && fileName.contains(bundleIdLower)) {
                        files.append(fileURL.path)
                        if (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true {
                            enumerator.skipDescendants()
                        }
                    }
                }
            }
        }
        
        return Array(Set(files)).sorted()
    }
}

// MARK: - App Uninstaller
class AppUninstaller {
    func uninstall(
        app: AppInfo,
        progress: @escaping (String) -> Void,
        completion: @escaping (Bool, String?) -> Void
    ) {
        var failedFiles: [String] = []
        let fileManager = FileManager.default
        
        for file in app.relatedFiles {
            progress("正在删除: \(file)")
            
            do {
                if fileManager.fileExists(atPath: file) {
                    if fileManager.isDeletableFile(atPath: file) {
                        try fileManager.removeItem(atPath: file)
                        progress("✓ 已删除: \(file)")
                    } else {
                        let success = deleteWithPrivileges(path: file)
                        if success {
                            progress("✓ 已删除 (sudo): \(file)")
                        } else {
                            failedFiles.append(file)
                            progress("✗ 删除失败: \(file)")
                        }
                    }
                }
            } catch {
                let success = deleteWithPrivileges(path: file)
                if success {
                    progress("✓ 已删除 (sudo): \(file)")
                } else {
                    failedFiles.append(file)
                    progress("✗ 删除失败: \(file)")
                }
            }
        }
        
        if failedFiles.isEmpty {
            completion(true, nil)
        } else {
            completion(true, "部分文件删除失败: \(failedFiles.count) 个")
        }
    }
    
    private func deleteWithPrivileges(path: String) -> Bool {
        let script = """
        do shell script "rm -rf '\(path.replacingOccurrences(of: "'", with: "'\\''"))'" with administrator privileges
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            return error == nil
        }
        return false
    }
}

