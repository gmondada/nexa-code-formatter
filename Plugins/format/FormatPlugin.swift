//
//  FormatPlugin.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import PackagePlugin
import Foundation

@main
struct FormatPlugin: CommandPlugin {

    let contentChecks: [any ContentCheck] = [
        TrailingBlanksCheck(),
        TabToSpaceCheck(),
        ExoticCharCheck(),
        FinalNewlineCheck(),
        LegacyHeaderCheck(),
    ]

    func performCommand(context: PluginContext, arguments: [String]) async throws {

        let packageUrl = context.package.directoryURL
        // print("Package Dir: \(packageUrl.path)")

        let config = try Config.load(from: packageUrl)

        let headerChecks: [any HeaderCheck] = [
            CopyrightSymbolCheck(),
            HeaderFilenameCheck(),
            CopyrightYearCheck(),
            LegalNoticeCheck(config: config),
        ]

        scan(packageUrl, config: config, headerChecks: headerChecks)
    }

    private func scan(_ url: URL, config: Config, headerChecks: [any HeaderCheck]) {
        let urls = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey] , options: [.skipsHiddenFiles])

        for url in urls {
            // print("Procssing \(url.path)")
            if try! url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory! {
                scan(url, config: config, headerChecks: headerChecks)
            } else {
                guard url.lastPathComponent != "Package.swift" else {
                    continue
                }
                if url.pathExtension == "c" || url.pathExtension == "cpp" || url.pathExtension == "h" || url.pathExtension == "m" || url.pathExtension == "swift" {
                    processSourceFile(url, config: config, headerChecks: headerChecks)
                }
            }
        }
    }

    private func processSourceFile(_ url: URL, config: Config, headerChecks: [any HeaderCheck]) {
        do {
            var issues: [Issue] = []
            let sourceFile = try SourceFile(url: url)
            for check in contentChecks {
                let checkIssues = check.run(url: url, lines: &sourceFile.lines)
                issues.append(contentsOf: checkIssues)
            }

            let headerLines = sourceFile.header
            let header: Header
            if headerLines.isEmpty {
                header = Header(url: url, config: config)
                issues.append(Issue(description: "Created header", line: 0, autoFixed: true))
                sourceFile.header = header.format()
            } else {
                header = try Header(lines: headerLines)

                // check for standard header formatting
                let formattedHeaderLines = header.format()
                if headerLines != formattedHeaderLines {
                    sourceFile.header = formattedHeaderLines
                    issues.append(Issue(description: "Header not properly formatted", line: 0, autoFixed: true))
                }
            }

            for check in headerChecks {
                let checkIssues = check.run(url: url, header: header)
                issues.append(contentsOf: checkIssues)
                if !checkIssues.isEmpty {
                    sourceFile.header = header.format()
                }
            }

            if sourceFile.body.first != "" {
                sourceFile.body.insert("", at: 0)
                issues.append(Issue(description: "Added empty line between header and body", line: sourceFile.header.count + 1, autoFixed: true))
            }

            var hasBeenFixed = false
            for issue in issues {
                if issue.autoFixed {
                    hasBeenFixed = true
                }
                print("\(url.path):\(issue.line): \(issue.autoFixed ? "auto-fixed" : "") issue: \(issue.description)")
            }
            if hasBeenFixed {
                try sourceFile.save()
            }
        } catch {
            print("\(url.path): error: \(error)")
        }
    }
}
