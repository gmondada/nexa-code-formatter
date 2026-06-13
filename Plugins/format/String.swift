//
//  String.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

extension String {
    func substring(_ from: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: from)...])
    }
}
