//
//  CodingKeysMacro.swift
//  BraniffUtilities
//
//  Created by Matthew Braniff on 8/17/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct CodingKeysMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else { return [] }

        let cases: [DeclSyntax] = structDecl.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .compactMap { variable in
                guard let name = variable.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                    return nil
                }
                let camelCase = toUpperCamel(name)
                return "case \(raw: name) = \"\(raw: camelCase)\""
            }
            .map { try! DeclSyntax(validating: $0) }

        let enumDecl: DeclSyntax =
        """
        enum CodingKeys: String, CodingKey {
            \(raw: cases)
        }
        """

        return [enumDecl]
    }
}

/// helper: convert `transactionId` -> `TransactionId`
private func toUpperCamel(_ name: String) -> String {
    guard let first = name.first else { return name }
    var result = String(first).uppercased() + String(name.dropFirst())

    // If you want to split by words (like "transactionDateString" → "TransactionDateString"),
    // you can leave it as-is, since Swift property names are usually camelCase.
    return result
}
