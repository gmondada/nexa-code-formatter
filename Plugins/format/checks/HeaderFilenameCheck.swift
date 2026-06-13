//
//  HeaderFilenameCheck.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

struct HeaderFilenameCheck: HeaderCheck {
    func run(url: URL, header: Header) -> [Issue] {
        let filename = url.lastPathComponent
        if header.filename != filename {
            header.filename = filename
            return [Issue(description: "Updated header filename to match the real filename", line: 0, autoFixed: true)]
        }
        return []
    }
}
