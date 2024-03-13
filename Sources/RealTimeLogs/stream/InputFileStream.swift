//
//  InputFileStream.swift
//
//
//  Created by Tomasz on 13/03/2024.
//

import Foundation

public struct InputFileStream {
  private var fp: UnsafeMutablePointer<FILE>?
  private var isEOF: Bool
  private var fileSize: Int64
  private var buf: UnsafeMutableBufferPointer<UInt8>

  static public let defaultCapacity = 4096

  public init?(_ name: String, capacity: Int = InputFileStream.defaultCapacity) {
    if name.isEmpty {
      return nil
    }
    var fp: UnsafeMutablePointer<FILE>?
    var fileSize: Int64 = 0
    name.withCString { utf8 in
      fp = fopen(utf8, "r")
      var statbuf = stat()
      stat(utf8, &statbuf)
      fileSize = Int64(statbuf.st_size)
    }
    if fp == nil || fileSize < 0 {
      return nil
    }
    self.fp = fp
    self.isEOF = false
    self.fileSize = fileSize
    self.buf = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: capacity)
    self.buf.initialize(repeating: 0)
  }

  private mutating func _read(_ buf: UnsafeMutableBufferPointer<UInt8>) -> String? {
    let utf8Count = fread(buf.baseAddress!, 1, buf.count, self.fp)
    guard utf8Count > 0 else {
      self.isEOF = true
      return nil
    }
    let utf8 = UnsafePointer<UInt8>(buf.baseAddress!)
    return String(cString: utf8)
  }

  public mutating func read(size: Int = InputFileStream.defaultCapacity) -> String? {
    if self.isEOF {
      return nil
    }
    if InputFileStream.defaultCapacity < size {
      reallocBuf(size)
    }
    return _read(self.buf)
  }

  public mutating func readAll() -> String? {
    if self.isEOF {
      return nil
    }
    let cap = Int64(InputFileStream.defaultCapacity) + self.fileSize
    if cap > Int.max {
      return nil
    }
    reallocBuf(Int(cap))
    return _read(self.buf)
  }

  public mutating func close() {
    fclose(self.fp)
    self.buf.deallocate()
  }

  private mutating func reallocBuf(_ cap: Int) {
    self.buf.deallocate()
    self.buf = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: cap)
  }
}
