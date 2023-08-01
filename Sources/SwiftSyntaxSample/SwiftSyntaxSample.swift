import ArgumentParser

struct SwiftSyntaxSample: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "sss",
        abstract: "swift-syntax sample",
        version: "0.0.1"
    )

    @Option(
        name: [.customShort("p"), .customLong("path")],
        help: "Path of the Package.swift"
    )
    var path: String

    mutating func run() throws {
        let parser = Parser(path: path)
        try parser.loadPackageSwift()
        let packages = parser.extractPackages()
        packages.forEach { package in
            Swift.print(package)
        }
        if let first = packages.first,
           let result = parser.overwritePackage(first, to: "Hello World!!") {
            Swift.print(result)
        }
    }
}
