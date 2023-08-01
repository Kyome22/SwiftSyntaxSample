import SwiftSyntax
import SwiftSyntaxParser

final class PackageDetectorSyntaxVisitor: SyntaxVisitor {
    var packages = [String]()

#if VISITOR_PATTERN_1
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if node.calledExpression.as(IdentifierExprSyntax.self)?.identifier.text == "Package",
           let tuple = node.argumentList.first(where: { $0.label?.text == "dependencies" }),
           let array = tuple.expression.as(ArrayExprSyntax.self) {

            array.elements
                .compactMap { element in
                    element.expression.as(FunctionCallExprSyntax.self)
                }
                .filter { funcCall in
                    funcCall.calledExpression.as(MemberAccessExprSyntax.self)?.name.text == "package"
                }
                .forEach { funcCall in
                    let urlText = funcCall.argumentList
                        .first { $0.label?.text == "url" }?
                        .expression.as(StringLiteralExprSyntax.self)?
                        .segments
                        .compactMap { element -> String? in
                            if case .stringSegment(let segment) = element {
                                return segment.content.text
                            }
                            return nil
                        }
                        .first
                    if let urlText {
                        packages.append(urlText)
                    }
                }
        }
        return .skipChildren
    }
#endif

#if VISITOR_PATTERN_2
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        // 🐮の方のFunctionCallExprSyntaxの場合
        if node.calledExpression.as(IdentifierExprSyntax.self)?.identifier.text == "Package" {
            return .visitChildren
        }
        // 🐸の方のFunctionCallExprSyntaxの場合
        if node.calledExpression.as(MemberAccessExprSyntax.self)?.name.text == "package" {
            let urlText = node.argumentList
                .first { $0.label?.text == "url" }?
                .expression.as(StringLiteralExprSyntax.self)?
                .segments
                .compactMap { element -> String? in
                    if case .stringSegment(let segment) = element {
                        return segment.content.text
                    }
                    return nil
                }
                .first
            if let urlText {
                packages.append(urlText)
            }
        }
        return .skipChildren
    }

    override func visit(_ node: TupleExprElementSyntax) -> SyntaxVisitorContinueKind {
        if node.label?.text == "dependencies", node.expression.is(ArrayExprSyntax.self) {
            return .visitChildren
        }
        return .skipChildren
    }
#endif

#if VISITOR_PATTERN_3
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        // 目的のノードかどうかを確認する
        if node.calledExpression.as(MemberAccessExprSyntax.self)?.name.text == "package" {
            // ルートノードまでの構文を一気に確認していく
            if let element = node.parent?.as(ArrayElementSyntax.self),
               let list = element.parent?.as(ArrayElementListSyntax.self),
               let array = list.parent?.as(ArrayExprSyntax.self),
               let tuple = array.parent?.as(TupleExprElementSyntax.self),
               tuple.label?.text == "dependencies",
               let tupleList = tuple.parent?.as(TupleExprElementListSyntax.self),
               let funcCall = tupleList.parent?.as(FunctionCallExprSyntax.self),
               funcCall.calledExpression.as(IdentifierExprSyntax.self)?.identifier.text == "Package" {
                let urlText = node.argumentList
                    .first { $0.label?.text == "url" }?
                    .expression.as(StringLiteralExprSyntax.self)?
                    .segments
                    .compactMap { element -> String? in
                        if case .stringSegment(let segment) = element {
                            return segment.content.text
                        }
                        return nil
                    }
                    .first
                if let urlText {
                    packages.append(urlText)
                }
            }
        }
        return .visitChildren
    }
#endif
}
