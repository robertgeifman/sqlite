import Foundation
import FoundationAdditions

// MARK: - SQLiteDecoder
public final class SQLiteDecoder {
	static var registeredTypes = [String: String]()
	static var registeredIDs = Set<String>()
	private let _database: Database

	public init(_ database: Database) {
		self._database = database
	}

	public static func register<T: Entity>(_ type: T.Type, primaryKey: String) {
		registeredTypes["\(type)"] = primaryKey
		registeredIDs.insert("\(T.ID.self)")
	}
	public static func isRegisteredID<T>(_ type: T.Type) -> Bool {
		registeredIDs.contains("\(T.self)")
	}
	public static func registeredPrimaryKey<T>(_ type: T.Type) -> String? {
		registeredTypes["\(T.self)"]
	}
	@_disfavoredOverload
	public func decode<T: Decodable>(_ type: T.Type = T.self, using sql: SQL, arguments: SQLiteArguments = [:]) throws -> T {
		let results = try decode([T].self, using: sql, arguments: arguments)
		guard let result = results.first else {
			throw SQLiteDecoder.Error.incorrectNumberOfResults(results.count)
		}

		return result
	}
	@_disfavoredOverload
	public func decodeIfPresent<T: Decodable>(_ type: T.Type, using sql: SQL, arguments: SQLiteArguments = [:]) throws -> T? {
		let results: [T] = try decode([T].self, using: sql, arguments: arguments)
		guard results.isEmpty || results.count == 1 else {
			throw SQLiteDecoder.Error.incorrectNumberOfResults(results.count)
		}
		
		if results.isEmpty { return nil }
		//let result = results.first
		let result = results[0]
		return result
	}

	@_disfavoredOverload
	public func decode<T: Decodable>(_ type: [T].Type, using sql: SQL, arguments: SQLiteArguments = [:]) throws -> [T] {
		let results = try _database.read(sql, arguments: arguments)
		return try results.map { [decoder = _SQLiteDecoder(database: _database)] in
			decoder.row = $0
			let result = try T(from: decoder)
			return result
		}
	}
}

// MARK: - internal implementation
private class _SQLiteDecoder: Swift.Decoder {
	let _database: Database
	var row: SQLiteRow?
	var codingPath: [CodingKey] = []
	var userInfo: [CodingUserInfoKey: Any] = [:]

	init(database: Database, row: SQLiteRow? = nil) {
		_database = database
		self.row = row
	}

	func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
		guard let row = self.row else { fatalError() }
		return KeyedDecodingContainer(_KeyedContainer<Key>(database: _database, row: row))
	}
	func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		fatalError("SQLiteDecoder doesn't support unkeyed decoding")
	}
	func singleValueContainer() throws -> SingleValueDecodingContainer {
		guard let row = self.row else { fatalError() }
		return _SingleValueContainer(database: _database, row: row)
	}
}

/// A container that can support the storage and direct decoding of a single
/// nonkeyed value.
class _SingleValueContainer: SingleValueDecodingContainer {
	let _database: Database
	var _row: SQLiteRow
	let codingPath: [CodingKey] = []

	init(database: Database, row: SQLiteRow) {
		self._database = database
		self._row = row
	}

    func decodeNil() -> Bool {
		guard _row.count == 1, let value = _row.first?.value else {
			return true
		}

		if case .null = value {
			return true
		} else {
			return false
		}
    }
    func decode(_ type: Bool.Type) throws -> Bool {
		guard _row.count == 1, let value = _row.first?.value.boolValue else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return value
	}
    func decode(_ type: String.Type) throws -> String {
		guard _row.count == 1, let value = _row.first?.value.stringValue else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return value
	}
    func decode(_ type: Double.Type) throws -> Double {
		guard _row.count == 1, let value = _row.first?.value.doubleValue else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return value
	}
    func decode(_ type: Float.Type) throws -> Float {
		guard _row.count == 1, let value = _row.first?.value.doubleValue else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return Float(value)
	}
	func decode(_ type: Int.Type) throws -> Int {
		guard _row.count == 1, let value = _row.first?.value.int64Value else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return Int(value)
	}
	func decode(_ type: Int8.Type) throws -> Int8 {
		guard _row.count == 1, let value = _row.first?.value.int64Value else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return Int8(value)
	}
	func decode(_ type: Int16.Type) throws -> Int16 {
		guard _row.count == 1, let value = _row.first?.value.int64Value else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return Int16(value)
	}
	func decode(_ type: Int32.Type) throws -> Int32 {
		guard _row.count == 1, let value = _row.first?.value.int64Value else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return Int32(value)
	}
	func decode(_ type: Int64.Type) throws -> Int64 {
		guard _row.count == 1, let value = _row.first?.value.int64Value else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return value
	}
	func decode(_ type: UInt.Type) throws -> UInt {
		guard _row.count == 1, let value = _row.first?.value.int64Value else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return UInt(value)
	}
	func decode(_ type: UInt8.Type) throws -> UInt8 {
		guard _row.count == 1, let value = _row.first?.value.int64Value else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return UInt8(value)
	}
	func decode(_ type: UInt16.Type) throws -> UInt16 {
		guard _row.count == 1, let value = _row.first?.value.int64Value else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return UInt16(value)
	}
	func decode(_ type: UInt32.Type) throws -> UInt32 {
		guard _row.count == 1, let value = _row.first?.value.int64Value else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return UInt32(value)
	}
	func decode(_ type: UInt64.Type) throws -> UInt64 {
		guard _row.count == 1, let value = _row.first?.value.int64Value else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return UInt64(value)
	}
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
		if Data.self == T.self {
			return try decode(Data.self) as! T
		} else if Date.self == T.self {
			return try decode(Date.self) as! T
		} else if URL.self == T.self {
			return try decode(URL.self) as! T
		} else if String.self == T.self {
			return try decode(String.self) as! T
		} else if Int.self == T.self {
			return try decode(Int.self) as! T
		} else if Double.self == T.self {
			return try decode(Double.self) as! T
		} else if Bool.self == T.self {
			return try decode(Bool.self) as! T
		} else if UUID.self == T.self {
			return try decode(UUID.self) as! T
		} else {
			let stringValue = try decode(String.self)
			if let uuid = UUID(uuidString: stringValue) {
				let recordType = "\(T.self)".lowercased()
				if recordType.contains("entityid<") {
					return try JSONDecoder().decode(T.self, from: JSONEncoder().encode(uuid))
				}
				let sql = "SELECT * FROM \":table\" WHERE uuid=:id;"
				return try SQLiteDecoder(_database).decode(T.self,
					using: sql.replacingOccurrences(of: ":table", with: recordType),
					arguments: ["id": .text(stringValue)])
			}

			guard let jsonData = stringValue.data(using: .utf8) else {
				throw SQLiteDecoder.Error.invalidJSON(stringValue)
			}

			return try jsonDecoder.decode(T.self, from: jsonData)
		}
    }
	func decode(_ type: Data.Type) throws -> Data {
		guard _row.count == 1, let value = _row.first?.value.dataValue else {
			throw SQLiteDecoder.Error.emptyResult
		}
		return value
	}
	func decode(_ type: Date.Type) throws -> Date {
		let string = try decode(String.self)
		if let date = PreciseDateFormatter.date(from: string) {
			return date
		} else {
			throw SQLiteDecoder.Error.invalidDate(string)
		}
	}
	func decode(_ type: URL.Type) throws -> URL {
		let string = try decode(String.self)
		if let url = URL(string: string) {
			return url
		} else {
			throw SQLiteDecoder.Error.invalidURL(string)
		}
	}
	func decode(_ type: UUID.Type) throws -> UUID {
		let string = try decode(String.self)
		if let uuid = UUID(uuidString: string) {
			return uuid
		} else {
			throw SQLiteDecoder.Error.invalidUUID(string)
		}
	}
}

private class _KeyedContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
	typealias Key = K

	let _database: Database
	var _row: SQLiteRow
	let codingPath: [CodingKey] = []
	var allKeys: [K] { return _row.keys.compactMap { K(stringValue: $0) } }

	init(database: Database, row: SQLiteRow) {
		self._database = database
		self._row = row
	}

	func contains(_ key: K) -> Bool {
		return _row[key.stringValue] != nil
	}

	func decodeNil(forKey key: K) throws -> Bool {
		guard let value = _row[key.stringValue] else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}

		if case .null = value {
			return true
		} else {
			return false
		}
	}
	func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
		guard let value = _row[key.stringValue]?.boolValue else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return value
	}
	func decode(_ type: String.Type, forKey key: K) throws -> String {
		guard let value = _row[key.stringValue]?.stringValue else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return value
	}
	func decode(_ type: Double.Type, forKey key: K) throws -> Double {
		guard let value = _row[key.stringValue]?.doubleValue else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return value
	}
	func decode(_ type: Float.Type, forKey key: K) throws -> Float {
		guard let value = _row[key.stringValue]?.doubleValue else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return Float(value)
	}
	func decode(_ type: Int.Type, forKey key: K) throws -> Int {
		guard let value = _row[key.stringValue]?.intValue else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return value
	}
	func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
		guard let value = _row[key.stringValue]?.int64Value else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return Int8(value)
	}
	func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
		guard let value = _row[key.stringValue]?.int64Value else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return Int16(value)
	}
	func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
		guard let value = _row[key.stringValue]?.int64Value else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return Int32(value)
	}
	func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
		guard let value = _row[key.stringValue]?.int64Value else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return value
	}
	func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
		guard let value = _row[key.stringValue]?.int64Value else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return UInt(value)
	}
	func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
		guard let value = _row[key.stringValue]?.int64Value else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return UInt8(value)
	}
	func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
		guard let value = _row[key.stringValue]?.int64Value else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return UInt16(value)
	}
	func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
		guard let value = _row[key.stringValue]?.int64Value else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return UInt32(value)
	}
	func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
		guard let value = _row[key.stringValue]?.int64Value else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return UInt64(value)
	}
	func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T: Decodable {
		if Data.self == T.self {
			return try decode(Data.self, forKey: key) as! T
		} else if Date.self == T.self {
			return try decode(Date.self, forKey: key) as! T
		} else if URL.self == T.self {
			return try decode(URL.self, forKey: key) as! T
		} else if String.self == T.self {
			return try decode(String.self, forKey: key) as! T
		} else if Int.self == T.self {
			return try decode(Int.self, forKey: key) as! T
		} else if Double.self == T.self {
			return try decode(Double.self, forKey: key) as! T
		} else if Bool.self == T.self {
			return try decode(Bool.self, forKey: key) as! T
		} else if UUID.self == T.self {
			return try decode(UUID.self, forKey: key) as! T
		} else {
			let stringValue = try decode(String.self, forKey: key)
			
			if let uuid = UUID(uuidString: stringValue) {
				if SQLiteDecoder.isRegisteredID(T.self) {
					return try JSONDecoder().decode(T.self, from: JSONEncoder().encode(uuid))
				}
				
				if let key = SQLiteDecoder.registeredPrimaryKey(T.self) {
					let decoder = SQLiteDecoder(_database)

					let recordType = "\(T.self)".lowercased()
					let sql = "SELECT * FROM \"\(recordType)\" WHERE \(key)=:id;"
					return try decoder.decode(T.self, using: sql,
						arguments: ["id": .text(stringValue)])
				}
			}

			guard let jsonData = stringValue.data(using: .utf8) else {
				throw SQLiteDecoder.Error.invalidJSON(stringValue)
			}
			return try jsonDecoder.decode(T.self, from: jsonData)
		}
	}
	func decode(_ type: Data.Type, forKey key: K) throws -> Data {
		guard let value = _row[key.stringValue]?.dataValue else {
			throw SQLiteDecoder.Error.missingValueForKey(key.stringValue)
		}
		return value
	}
	func decode(_ type: Date.Type, forKey key: K) throws -> Date {
		let string = try decode(String.self, forKey: key)
		if let date = PreciseDateFormatter.date(from: string) {
			return date
		} else {
			throw SQLiteDecoder.Error.invalidDate(string)
		}
	}
	func decode(_ type: URL.Type, forKey key: K) throws -> URL {
		let string = try decode(String.self, forKey: key)
		if let url = URL(string: string) {
			return url
		} else {
			throw SQLiteDecoder.Error.invalidURL(string)
		}
	}
	func decode(_ type: UUID.Type, forKey key: K) throws -> UUID {
		let string = try decode(String.self, forKey: key)
		if let uuid = UUID(uuidString: string) {
			return uuid
		} else {
			throw SQLiteDecoder.Error.invalidUUID(string)
		}
	}
	
	func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
		fatalError("_KeyedContainer does not support nested containers.")
	}

	func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
		fatalError("_KeyedContainer does not support nested containers.")
	}

	func superDecoder() throws -> Swift.Decoder {
		fatalError("_KeyedContainer does not support nested containers.")
	}

	func superDecoder(forKey key: K) throws -> Swift.Decoder {
		fatalError("_KeyedContainer does not support nested containers.")
	}
}

private let jsonDecoder: JSONDecoder = {
	let decoder = JSONDecoder()
	decoder.dataDecodingStrategy = .base64
	decoder.dateDecodingStrategy = .custom { (decoder) throws -> Date in
		let container = try decoder.singleValueContainer()
		let dateAsString = try container.decode(String.self)
		guard let date = PreciseDateFormatter.date(from: dateAsString) else {
			throw SQLiteDecoder.Error.invalidDate(dateAsString)
		}
		return date
	}
	return decoder
}()

public extension SQLiteDecoder {
	enum Error: LocalizedError {
		case incorrectNumberOfResults(Int)
		case missingValueForKey(String)
		case emptyResult
		case invalidDate(String)
		case invalidURL(String)
		case invalidUUID(String)
		case invalidJSON(String)
	}
}
public extension SQLiteDecoder.Error {
	var failureReason: String? {
		switch self {
		case .incorrectNumberOfResults: return "Incorrect number of results"
		case .missingValueForKey: return "Missing value for key"
		case .emptyResult: return "Empty result (Single-value decoding)"
		case .invalidDate: return "Invalid Date"
		case .invalidURL: return "Invalid URL"
		case .invalidUUID: return "Invalid UUID"
		case .invalidJSON: return "Invalid JSON"
		}
	}

	var recoverySuggestion: String? {
		switch self {
		case let .incorrectNumberOfResults(number): return "\(number)"
		case .emptyResult: return nil
		case let .missingValueForKey(string): return "`\(string)`"
		case let .invalidDate(string): return "`\(string)`"
		case let .invalidURL(string): return "`\(string)`"
		case let .invalidUUID(string): return "`\(string)`"
		case let .invalidJSON(string): return "`\(string)`"
		}
	}
	var errorDescription: String? {
		NSLocalizedString("SQLite Decoder error", comment: "")
	}
}
