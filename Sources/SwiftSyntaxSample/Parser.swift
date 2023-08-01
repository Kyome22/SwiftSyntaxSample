import Foundation
import SwiftSyntax
import SwiftSyntaxParser

final class Parser {
    private let path: String
    private var packageSwift: SourceFileSyntax?

    init(path: String) {
        self.path = path
    }

    func loadPackageSwift() throws {
        let url = URL(fileURLWithPath: path)
        guard url.lastPathComponent == "Package.swift" else {
            throw ParserError.notGetPackageSwift
        }
        packageSwift = try SyntaxParser.parse(url)
    }

    func extractPackages() -> [String] {
        guard let packageSwift else { return [] }
        let detector = PackageDetectorSyntaxVisitor(viewMode: .all)
        detector.walk(packageSwift)
        return detector.packages
    }

    func overwritePackage(_ package: String, to: String) -> String? {
        guard let packageSwift else { return nil }
        let updater = PackageUpdaterSyntaxRewriter(package: package, to: to)
        return updater.visit(packageSwift).description
    }
}
