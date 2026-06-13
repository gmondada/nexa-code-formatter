//
//  FormatError.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

struct FormatError: Error {
    let message: String
    init(_ message: String) {
        self.message = message
    }
}
