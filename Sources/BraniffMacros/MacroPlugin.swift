//
//  MacroPlugin.swift
//  BraniffUtilities
//
//  Created by Matthew Braniff on 8/17/25.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct BraniffMacros: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        CodingKeysMacro.self
    ]
}
