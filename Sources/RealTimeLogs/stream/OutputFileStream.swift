//
//  OutputFileStream.swift
//
//
//  Created by Tomasz on 13/03/2024.
//

import Foundation

public struct OutputFileStream: TextOutputStream {
  private var fp: UnsafeMutablePointer<FILE>?

  public init?(_ name: String) {
    if name.isEmpty {
      return nil
    }
    var fp: UnsafeMutablePointer<FILE>?
    name.withCString { utf8 in
      fp = fopen(utf8, "w")
    }
    if fp == nil {
      return nil
    }
    self.fp = fp
  }

  public mutating func _lock() {}
  public mutating func _unlock() {}

  public mutating func write(_ string: String) {
    if string.isEmpty {
      return
    }
    var string = string
    _ = string.withUTF8 { utf8 in
      fwrite(utf8.baseAddress!, 1, utf8.count, self.fp)
    }
  }

  public mutating func close() {
    fclose(self.fp)
  }
}
