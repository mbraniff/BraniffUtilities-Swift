import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import BraniffMacros

final class CodingKeysMacroTests: XCTestCase {
    func testCodingKeysMacro() throws {
        assertMacroExpansion(
            """
            @CodingKeys
            struct TestStruct {
                var transactionId: String
                var userName: String
            }
            """,
            expandedSource: """
            struct TestStruct {
                var transactionId: String
                var userName: String

                enum CodingKeys: String, CodingKey {
                    case transactionId = "TransactionId"
                    case userName = "UserName"
                }
            }
            """,
            macros: ["CodingKeys": CodingKeysMacro.self]
        )
    }

    func testEmptyStruct() throws {
        assertMacroExpansion(
            """
            @CodingKeys
            struct EmptyStruct {
            }
            """,
            expandedSource: """
            struct EmptyStruct {
                enum CodingKeys: String, CodingKey {
                    // No coding keys generated
                }
            }
            """,
            macros: ["CodingKeys": CodingKeysMacro.self]
        )
    }

    func testNonStructFails() throws {
        assertMacroExpansion(
            """
            @CodingKeys
            class TestClass {
                var transactionId: String
            }
            """,
            expandedSource: """
            class TestClass {
                var transactionId: String
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@CodingKeys can only be applied to structs",
                    line: 1,
                    column: 1
                )
            ],
            macros: ["CodingKeys": CodingKeysMacro.self]
        )
    }
}
