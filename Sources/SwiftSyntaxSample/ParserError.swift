import Foundation

enum ParserError: Error, LocalizedError {
    case notGetPackageSwift

    var errorDescription: String? {
        switch self {
        case .notGetPackageSwift:
            return "Package.swift not found."
        }
    }
}
