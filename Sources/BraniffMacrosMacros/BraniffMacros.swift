//
//  BraniffMacros.swift
//  BraniffUtilities
//
//  Created by Matthew Braniff on 8/20/25.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct BraniffMacros: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        CodingKeysMacro.self,
        CodingIgnoreMacro.self,
        EncodableRequestMacro.self,
        CodedMacro.self
    ]
}
