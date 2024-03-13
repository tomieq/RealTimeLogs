//
//  MobileLogCollector.swift
//
//
//  Created by Tomasz on 12/03/2024.
//

import Foundation
import Swifter

class MobileLogCollector {
    private var websocketSessions: [WebSocketSession: String] = [:]
    private var clientFileStream: [String: OutputFileStream] = [:]
    private var clientFileName: [String: String] = [:]
    
    init(server: HttpServer, logConverter: ((String) -> String)? = nil) {
        server["/mobile"] = websocket(text: { [weak self] session, text in
            guard let name = self?.websocketSessions[session] else { return }
            let log = logConverter?(text) ?? text
            print("\(name): \(log)")
            if var output = self?.clientFileStream[name] {
                print(log, to: &output)
            }
        }, binary: { session, binary in
        }, connected: { [weak self] session in
            let name = RandomNameGenerator.randomAdjective.capitalized + RandomNameGenerator.randomNoun.capitalized
            print("Connected client: \(name)")
            self?.websocketSessions[session] = name
            self?.prepareFileHandler(for: name)
        }, disconnected: { [weak self] session in
            print("Disconnected client: \(self?.websocketSessions[session] ?? "nil")")
            if let name = self?.websocketSessions[session] {
                self?.closeFileHandle(for: name)
                self?.websocketSessions[session] = nil
            }
        })
        let lastID = try? FileManager.default.contentsOfDirectory(atPath: FileManager.default.currentDirectoryPath)
            .filter{ $0.contains(".log") }
            .compactMap { filename in
                filename.components(separatedBy: CharacterSet(charactersIn: "-")).first
            }
            .compactMap { UInt64($0) }
            .map { $0 + 1 }
            .max()
        if let lastID = lastID {
            ProcessID.current = lastID
        }
    }

    var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: Date())
    }
    var time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH-mm"
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: Date())
    }

    private func path(for name: String) -> String {
        FileManager.default.currentDirectoryPath.appending("/\(name).log")
    }

    private func prepareFileHandler(for name: String) {
        let uniqueName = "\(ProcessID.next)-\(name)-captured-\(self.date)-at-\(self.time)"
        let filePath = self.path(for: uniqueName)
        let temporaryFilePath = filePath + ".tmp"
        if let output = OutputFileStream(temporaryFilePath) {
            self.clientFileStream[name] = output
            self.clientFileName[name] = filePath
            print("Created temporary file log for \(temporaryFilePath)")
        } else {
            print("Problem creating temporary file log for \(temporaryFilePath)")
        }
    }

    private func closeFileHandle(for name: String) {
        self.clientFileStream[name]?.close()
        if let filePath = self.clientFileName[name] {
            try? FileManager.default.moveItem(atPath: filePath + ".tmp", toPath: filePath)
            print("Stored logs into \(filePath)")
        }
    }
}
