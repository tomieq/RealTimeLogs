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
    private var fileHandle: [String: OutputFileStream] = [:]
    
    init(server: HttpServer, logConverter: ((String) -> String)? = nil) {
        server["/mobile"] = websocket(text: { [weak self] session, text in
            guard let name = self?.websocketSessions[session] else { return }
            let log = logConverter?(text) ?? text
            print("\(name): \(log)")
            if var output = self?.fileHandle[name] {
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
    }
    
    private func path(for name: String) -> String {
        FileManager.default.currentDirectoryPath.appending("/\(name).log")
    }

    private func prepareFileHandler(for name: String) {
        let filePath = self.path(for: name) + ".tmp"
        if let output = OutputFileStream(filePath) {
            self.fileHandle[name] = output
            print("Created temporary file log for \(filePath)")
        } else {
            print("Problem creating temporary file log for \(filePath)")
        }
    }

    private func closeFileHandle(for name: String) {
        self.fileHandle[name]?.close()
        let filePath = self.path(for: name)
        try? FileManager.default.moveItem(atPath: filePath + ".tmp", toPath: filePath)
        print("Stored logs into \(filePath)")
    }
}
