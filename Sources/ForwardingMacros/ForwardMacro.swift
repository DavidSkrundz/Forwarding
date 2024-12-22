import SwiftSyntax
import SwiftSyntaxMacros

public struct ForwardMacro: ExtensionMacro {
	public static func expansion(of node: AttributeSyntax,
								 attachedTo declaration: some DeclGroupSyntax,
								 providingExtensionsOf type: some TypeSyntaxProtocol,
								 conformingTo protocols: [TypeSyntax],
								 in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
		// Only allow Protocols
		guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
			throw Error.message("@Forward only works on protocols")
		}

		// Require macro arguments
		guard case .argumentList(let argumentList) = node.arguments else {
			throw Error.message("@Forward requires arguments")
		}
		var arguments = try argumentList.map {
			guard let stringLiteral = $0.expression.as(StringLiteralExprSyntax.self) else {
				throw Error.message("@Forward arguments must be string literals")
			}
			return stringLiteral.segments.trimmedDescription
		}.makeIterator()
		guard let protoPrefix = arguments.next() else {
			throw Error.message("@Forward is missing an argument")
		}
		guard let forwardPrefix = arguments.next() else {
			throw Error.message("@Forward is missing an argument")
		}
		guard arguments.next() == nil else {
			throw Error.message("@Forward has too many arguments")
		}

		// Gather all functions that should be forwarded
		let functions = protocolDecl.memberBlock.members
			.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
			.filter { $0.name.text.starts(with: protoPrefix) }

		// Generate forwarding functions
		let generatedFunctions: [MemberBlockItemSyntax] = functions
			.map { (function: FunctionDeclSyntax) in
				var function = function

				let forwardName = forwardPrefix + function.name.text.stripPrefix(protoPrefix)

				let functionArgs = function.signature.parameterClause.parameters
				let forwardArgs = functionArgs.map { argument in
					return LabeledExprSyntax(
						label: argument.firstName,
						colon: argument.colon,
						expression: DeclReferenceExprSyntax(baseName: argument.secondName ?? argument.firstName),
						trailingComma: argument.trailingComma)
				}

				let functionCall = FunctionCallExprSyntax(
					calledExpression: DeclReferenceExprSyntax(baseName: .identifier(forwardName)),
					leftParen: .leftParenToken(),
					arguments: LabeledExprListSyntax(forwardArgs),
					rightParen: .rightParenToken())
				let returnStatement: ReturnStmtSyntax
				if function.signature.effectSpecifiers?.throwsClause != nil {
					returnStatement = .init(expression: TryExprSyntax(expression: functionCall))
				} else {
					returnStatement = .init(expression: functionCall)
				}

				function.body = .init(statements: [.init(item: .stmt(.init(returnStatement)))])
				return function
			}
			.map { .init(decl: $0) }

		return [
			.init(
				modifiers: protocolDecl.modifiers,
				extendedType: type,
				memberBlock: .init(members: .init(generatedFunctions))),
		]
	}
}
