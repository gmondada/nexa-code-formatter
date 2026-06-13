//
//  LegalNoticeCheck.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

struct LegalNoticeCheck: HeaderCheck {
    let config: Config

    func run(url: URL, header: Header) -> [Issue] {
        var issues: [Issue] = []
        for (index, tag) in header.tags.enumerated() {
            guard let project = project(for: tag, primary: index == 0) else {
                issues.append(Issue(description: "Unknown \(index == 0 ? "primary" : "secondary") project tag: \(tag)", line: 0, autoFixed: false))
                break
            }
            if index == 0 {
                guard case .primary(let project) = project.type else { fatalError() }
                if let notice = header.legalNotices.first {
                    // A notice already exists, check if it's correct
                    if notice.owner != project.copyrightOwner {
                        header.legalNotices[0].owner = project.copyrightOwner
                        issues.append(Issue(description: "Updated copyright owner", line: 0, autoFixed: true))
                    }
                    if notice.license != project.license {
                        header.legalNotices[0].license = project.license
                        issues.append(Issue(description: "Updated license", line: 0, autoFixed: true))
                    }
                } else {
                    // Notice is missing, add it
                    let date = Date()
                    let notice = Header.LegalNotice(
                        origin: .created(by: config.defaultAuthor, date: date),
                        message: "Copyright (c)",
                        owner: project.copyrightOwner,
                        year: Calendar.current.component(.year, from: date),
                        rights: nil,
                        license: project.license
                    )
                    header.legalNotices.append(notice)
                    issues.append(Issue(description: "Added license notice", line: 0, autoFixed: true))
                }
            } else {
                // guard case .secondary(let project) = project.type else { fatalError() }
                // TODO
            }
        }
        return issues
    }

    func project(for tag: String, primary: Bool) -> Config.Project? {
        return config.projects.first {
            $0.tag == tag && $0.isPrimary == primary
        }
    }
}

private extension Config.Project {
    var isPrimary: Bool {
        if case .primary(_) = type {
            return true
        } else {
            return false
        }
    }
}
