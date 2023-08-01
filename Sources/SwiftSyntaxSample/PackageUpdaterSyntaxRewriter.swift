import SwiftSyntax
import SwiftSyntaxParser

final class PackageUpdaterSyntaxRewriter: SyntaxRewriter {
    private let package: String
    private let newText: String

    init(package: String, to newText: String) {
        self.package = package
        self.newText = newText
    }

#if REWRITER_PATTERN_1
    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        guard node.calledExpression.as(IdentifierExprSyntax.self)?.identifier.text == "Package" else {
            return super.visit(node)
        }
        let newArgumentList = node.argumentList.map { item -> TupleExprElementSyntax in
            guard item.label?.text == "dependencies",
                  let array = item.expression.as(ArrayExprSyntax.self) else {
                return item
            }
            let newArray = array.elements.map { item -> ArrayElementSyntax in
                guard let funcCall = item.expression.as(FunctionCallExprSyntax.self),
                      funcCall.calledExpression.as(MemberAccessExprSyntax.self)?.name.text == "package" else {
                    return item
                }
                let newArgumentList = funcCall.argumentList.map { item -> TupleExprElementSyntax in
                    guard item.label?.text == "url",
                          let literal = item.expression.as(StringLiteralExprSyntax.self) else {
                        return item
                    }
                    let urlText = item
                        .expression.as(StringLiteralExprSyntax.self)?
                        .segments
                        .compactMap { element -> String? in
                            if case .stringSegment(let segment) = element {
                                return segment.content.text
                            }
                            return nil
                        }
                        .first
                    guard urlText == package else { return item }
                    return TupleExprElementSyntax(
                        leadingTrivia: item.leadingTrivia,
                        item.unexpectedBeforeLabel,
                        label: item.label,
                        item.unexpectedBetweenLabelAndColon,
                        colon: item.colon,
                        item.unexpectedBetweenColonAndExpression,
                        expression: literal.withSegments(
                            StringLiteralSegmentsSyntax([
                                .stringSegment(StringSegmentSyntax(content: TokenSyntax.stringSegment(newText)))
                            ])
                        ),
                        item.unexpectedBetweenExpressionAndTrailingComma,
                        trailingComma: item.trailingComma,
                        item.unexpectedAfterTrailingComma,
                        trailingTrivia: item.trailingTrivia

                    )
                }
                return item.withExpression(ExprSyntax(funcCall.withArgumentList(
                    TupleExprElementListSyntax(newArgumentList)
                )))
            }
            return item.withExpression(ExprSyntax(
                ArrayExprSyntax(
                    leadingTrivia: array.leadingTrivia,
                    array.unexpectedBeforeLeftSquare,
                    leftSquare: array.leftSquare,
                    array.unexpectedBetweenLeftSquareAndElements,
                    elements: ArrayElementListSyntax(newArray),
                    array.unexpectedBetweenElementsAndRightSquare,
                    rightSquare: array.rightSquare,
                    array.unexpectedAfterRightSquare,
                    trailingTrivia: array.trailingTrivia
                )
            ))
        }
        return super.visit(node.withArgumentList(TupleExprElementListSyntax(newArgumentList)))
    }
#endif

#if REWRITER_PATTERN_2
    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
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
                let newArgumentList = node.argumentList.map { item -> TupleExprElementSyntax in
                    guard item.label?.text == "url",
                          let literal = item.expression.as(StringLiteralExprSyntax.self) else {
                        return item
                    }
                    let urlText = item
                        .expression.as(StringLiteralExprSyntax.self)?
                        .segments
                        .compactMap { element -> String? in
                            if case .stringSegment(let segment) = element {
                                return segment.content.text
                            }
                            return nil
                        }
                        .first
                    guard urlText == package else { return item }
                    return TupleExprElementSyntax(
                        leadingTrivia: item.leadingTrivia,
                        item.unexpectedBeforeLabel,
                        label: item.label,
                        item.unexpectedBetweenLabelAndColon,
                        colon: item.colon,
                        item.unexpectedBetweenColonAndExpression,
                        expression: literal.withSegments(
                            StringLiteralSegmentsSyntax([
                                .stringSegment(StringSegmentSyntax(content: TokenSyntax.stringSegment(newText)))
                            ])
                        ),
                        item.unexpectedBetweenExpressionAndTrailingComma,
                        trailingComma: item.trailingComma,
                        item.unexpectedAfterTrailingComma,
                        trailingTrivia: item.trailingTrivia

                    )
                }
                return super.visit(node.withArgumentList(TupleExprElementListSyntax(newArgumentList)))
            }
        }
        return super.visit(node)
    }
#endif
}
