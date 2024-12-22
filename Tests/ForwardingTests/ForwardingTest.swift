import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

import ForwardingMacros

let testMacros: [String: Macro.Type] = [
	"Forward": ForwardMacro.self,
]

final class QSLibsTests: XCTestCase {
	func testSuper() throws {
		assertMacroExpansion("""
@Forward("A", "X")
@Forward("B", "Y")
protocol Proto {
    func A_func()
    func B_func() throws
}
""",
							 expandedSource: """
protocol Proto {
    func A_func()
    func B_func() throws
}

extension Proto {
    func A_func() {
        return X_func()
    }
}

extension Proto {
    func B_func() throws {
        return try Y_func()
    }
}
""",
							 macros: testMacros)
	}
}
