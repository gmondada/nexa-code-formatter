//
//  Config.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

struct Config: Decodable {
    struct PrimaryProject: Decodable {
        let copyrightOwner: String
        let license: String
    }

    struct SecondaryProject: Decodable {
        let originalProject: String
        let copyrightOwner: String
        let license: String
    }

    enum ProjectType {
        case primary(PrimaryProject)
        case secondary(SecondaryProject)
    }

    struct Project: Decodable {
        let tag: String
        let type: ProjectType

        private enum CodingKeys: String, CodingKey {
            case tag, type, copyrightOwner, license, originalProject
        }

        private enum TypeValue: String, Decodable {
            case primary, secondary
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            tag = try c.decode(String.self, forKey: .tag)
            switch try c.decode(TypeValue.self, forKey: .type) {
            case .primary:
                type = .primary(PrimaryProject(
                    copyrightOwner: try c.decode(String.self, forKey: .copyrightOwner),
                    license: try c.decode(String.self, forKey: .license)
                ))
            case .secondary:
                type = .secondary(SecondaryProject(
                    originalProject: try c.decode(String.self, forKey: .originalProject),
                    copyrightOwner: try c.decode(String.self, forKey: .copyrightOwner),
                    license: try c.decode(String.self, forKey: .license)
                ))
            }
        }
    }

    let defaultAuthor: String
    let projects: [Project]

    static func load(from packageDir: URL) throws -> Config {
        let url = packageDir.appendingPathComponent("nexa-code-format.json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Config.self, from: data)
    }
}
