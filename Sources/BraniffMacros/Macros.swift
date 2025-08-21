//
//  Macros.swift
//  BraniffUtilities
//
//  Created by Matthew Braniff on 8/17/25.
//

@attached(member, names: named(CodingKeys))
public macro AutoCodingKeys() = #externalMacro(
    module: "BraniffMacrosMacros",
    type: "CodingKeysMacro"
)

@attached(peer)
public macro CodingIgnore() = #externalMacro(
    module: "BraniffMacrosMacros",
    type: "CodingIgnoreMacro"
)

@attached(extension, conformances: Encodable, names: named(CodingKeys), named(encode))
public macro EncodableRequest() = #externalMacro(
    module: "BraniffMacrosMacros",
    type: "EncodableRequestMacro"
)

@attached(peer)
public macro Coded() = #externalMacro(
    module: "BraniffMacrosMacros",
    type: "CodedMacro"
)
