//
//  MobileLog.swift
//
//
//  Created by Tomasz on 12/03/2024.
//

import Foundation

struct MobileLog: Codable {
    let date: Date
    let message: String
    let tags: [String]?
}
