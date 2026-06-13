//
//  FinalNewlineCheck.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

struct FinalNewlineCheck: ContentCheck {
    func run(url: URL, lines: inout [String]) -> [Issue] {

        if lines.isEmpty {
            return []
        }
        if lines.last != "" {
            lines.append("")
            return [
                Issue(description: "File does not end with a newline", line: lines.count, autoFixed: true)
            ]
        }
        if lines.count >= 2 && lines[lines.count - 2].trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            // remove extra newlines at the end
            while lines.count >= 2 && lines[lines.count - 2].trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                lines.remove(at: lines.count - 2)
            }
            return [
                Issue(description: "File has extra newlines at the end", line: lines.count, autoFixed: true)
            ]
        }
        return []
    }
}
