import XCTest
@testable import MAformacCore

final class JSONValueTests: XCTestCase {
    func testRoundTripPreservesAllSupportedJSONCases() throws {
        let value: JSONValue = .object([
            "null": .null,
            "bool": .bool(true),
            "int": .int(3),
            "double": .double(3.5),
            "string": .string("warm"),
            "array": .array([.string("driver"), .int(2)]),
            "object": .object(["power": .string("on")])
        ])

        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)

        XCTAssertEqual(decoded, value)
    }

    func testDecodedIntegerAndDoubleRemainDistinct() throws {
        let data = Data(#"{"integer":2,"number":2.25}"#.utf8)

        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)

        XCTAssertEqual(decoded, .object([
            "integer": .int(2),
            "number": .double(2.25)
        ]))
    }
}
