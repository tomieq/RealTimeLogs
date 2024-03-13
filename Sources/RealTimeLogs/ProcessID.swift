//
//  ProcessID.swift
//
//
//  Created by Tomasz on 13/03/2024.
//

import Foundation

class ProcessID {
    private static var counter: UInt64 = 0
    static var current: UInt64 {
        get {
            Self.counter
        }
        set {
            Self.counter = max(Self.counter, newValue)
        }
    }
    static var next: String {
        defer {
            Self.counter += 1
        }
        return String(format: "%03d", Self.counter)
    }
}
