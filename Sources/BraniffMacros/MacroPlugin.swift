//
//  MacroPlugin.swift
//  BraniffUtilities
//
//  Created by Matthew Braniff on 8/17/25.
//

@attached(member, names: named(CodingKeys))
public macro AutoCodingKeys() = #externalMacro(
    module: "BraniffMacrosImpl",
    type: "CodingKeysMacro"
)
