//
//  SourceFile.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

class SourceFile {

    let url: URL
    var lines: [String]

    var header: [String] {
        get {
            let headerLineCount = self.headerLineCount
            return Array(lines[0..<headerLineCount])
        }
        set {
            let headerLineCount = self.headerLineCount
            let bodyLines = Array(lines[headerLineCount..<lines.count])
            self.lines = newValue + bodyLines
        }
    }

    var body: [String] {
        get {
            let headerLineCount = self.headerLineCount
            return Array(lines[headerLineCount..<lines.count])
        }
        set {
            let headerLineCount = self.headerLineCount
            let headerLines = Array(lines[0..<headerLineCount])
            self.lines = headerLines + newValue
        }
    }

    init(url: URL) throws {
        self.url = url

        let data = try Data(contentsOf: url)
        guard let content = String(data: data, encoding: .utf8) else {
            throw FormatError("Invalid utf8 encoding")
        }
        guard content.unicodeScalars.firstIndex(of: "\r") == nil else {
            throw FormatError("Invalid eol char")
        }
        lines = content.components(separatedBy: "\n")
    }

    func save() throws {
        let content = lines.joined(separator: "\n")
        try content.write(to: self.url, atomically: true, encoding: .utf8)
    }

    private var headerLineCount: Int {
        var headerLineCount = 0
        for index in 0..<lines.count {
            let line = lines[index]
            if line.starts(with: "//") {
                headerLineCount = index + 1
            } else {
                break
            }
        }
        return headerLineCount
    }
}
