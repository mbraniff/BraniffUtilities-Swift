//
//  CodingKeysMacro.swift
//  BraniffUtilities
//
//  Created by Matthew Braniff on 8/17/25.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import SwiftCompilerPlugin

public struct CodingKeysMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError.message("This macro can only be applied to structs")
        }
        
        let members = structDecl.memberBlock.members
        let properties = members.compactMap { member -> String? in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  let binding = varDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else { return nil }
            
            // Skip if @CodingIgnore is present
            let attributes = varDecl.attributes
            for attr in attributes {
                if let attrId = attr.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text,
                   attrId == "CodingIgnore" {
                    return nil
                }
            }
            
            return identifier
        }
        
        let codingKeys: DeclSyntax = """
        enum CodingKeys: String, CodingKey {
            \(raw: properties.map { "case \($0) = \"\($0.prefix(1).uppercased() + $0.dropFirst())\"" }.joined(separator: "\n    "))
        }
        """
        
        return [codingKeys]
    }
}

enum MacroError: Error, CustomStringConvertible {
    case message(String)
    
    var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
}

public struct CodingIgnoreMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        []
    }
}
