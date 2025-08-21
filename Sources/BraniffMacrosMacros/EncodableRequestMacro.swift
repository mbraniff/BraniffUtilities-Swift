//
//  EncodableRequestMacro.swift
//  BraniffUtilities
//
//  Created by Matthew Braniff on 8/20/25.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct EncodableRequestMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError.message("Macro can only be applied to structs")
        }
        
        // Ensure the struct conforms to ApiRequest
        let hasApiRequest = structDecl.inheritanceClause?.inheritedTypes.contains { type in
            type.type.as(IdentifierTypeSyntax.self)?.name.text == "ApiRequest"
        } ?? false
        
        if !hasApiRequest {
            throw MacroError.message("Struct must conform to ApiRequest")
        }
        
        // Collect properties marked with @Coded and remove @Coded attributes
        var modifiedMembers: [MemberBlockItemSyntax] = []
        var properties: [(name: String, camelCaseName: String)] = []
        
        for member in structDecl.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  let binding = varDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                modifiedMembers.append(member)
                continue
            }
            
            if varDecl.attributes.contains(where: { attr in
                attr.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "Coded"
            }) {
                // Remove @Coded attribute
                let newAttributes = varDecl.attributes.filter { attr in
                    attr.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text != "Coded"
                }
                let newVarDecl = varDecl.with(\.attributes, newAttributes)
                modifiedMembers.append(member.with(\.decl, DeclSyntax(newVarDecl)))
                
                // Collect property for CodingKeys and encoding
                let name = identifier.identifier.text
                let camelCaseName = name.prefix(1).uppercased() + name.dropFirst()
                properties.append((name, camelCaseName))
            } else {
                modifiedMembers.append(member)
            }
        }
        
        if properties.isEmpty {
            throw MacroError.message("At least one property must be marked with @Coded")
        }
        
        // Generate CodingKeys enum
        let codingKeysCases = properties.map { (name, camelCaseName) in
            "case \(name) = \"\(camelCaseName)\""
        }.joined(separator: "\n")
        
        let codingKeysDecl = """
        enum CodingKeys: String, CodingKey {
            \(codingKeysCases)
        }
        """
        
        // Generate encode(to:) method
        let encodeStatements = properties.map { (name, _) in
            "try container.encode(self.\(name), forKey: .\(name))"
        }.joined(separator: "\n")
        
        let encodeMethod = """
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            \(encodeStatements)
        }
        """
        
        // Create the extension declaration with Encodable conformance
        let extensionDecl = try ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: TypeInheritanceClauseSyntax(
                inheritedTypes: .init([
                    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("Encodable")))
                ])
            ),
            memberBlock: MemberBlockSyntax(
                members: MemberBlockItemListSyntax([
                    MemberBlockItemSyntax(decl: DeclSyntax(stringLiteral: codingKeysDecl)),
                    MemberBlockItemSyntax(decl: DeclSyntax(stringLiteral: encodeMethod))
                ])
            )
        )
        
        return [extensionDecl]
    }
}


// Coded attribute macro (empty, used as a marker)
public struct CodedMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        []
    }
}
