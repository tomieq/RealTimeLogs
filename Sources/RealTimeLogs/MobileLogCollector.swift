//
//  MobileLogCollector.swift
//
//
//  Created by Tomasz on 12/03/2024.
//

import Foundation
import Swifter

class MobileLogCollector {
    private var websocketSessions: [WebSocketSession] = []
    
    init(server: HttpServer) {
        server["/mobile"] = websocket(text: { session, text in
            print("received: \(text)")
        }, binary: { session, binary in
        }, connected: { [weak self] session in
            print("Connected client")
            self?.websocketSessions.append(session)
        }, disconnected: { [weak self] session in
            print("Disconnected client")
            self?.websocketSessions.removeAll { $0 == session }
        })
    }
}
