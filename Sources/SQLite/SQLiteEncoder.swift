import Foundation
import FoundationAdditions

// MARK: - SQLiteEncoder
public final class SQLiteEncoder {
	private let _database: Database

	public init(_ database: Database) {
		_database = database
	}

	public func encode<T: Encodable>(_ value: T, using sql: SQL, arguments: SQLiteArguments = [:]) throws {
		let encoder = _SQLiteEncoder(_database)
		if let array = value as? Array<Encodable> {
			do {
                try _database.withTransaction { db in
					for element in array {
						try element.encode(to: encoder)
						var elementArguments = encoder.encodedArguments
						for (key, value) in arguments {
							elementArguments[key] = value
						}
                        try db.write(sql, arguments: encoder.encodedArguments)
					}
				}
			} catch {
				throw SQLiteEncoder.Error.transactionFailed
			}
		} else if let dictionary = value as? Dictionary<AnyHashable, Encodable> {
			throw SQLiteEncoder.Error.invalidType(dictionary)
		} else {
			try value.encode(to: encoder)
			var elementArguments = encoder.encodedArguments
			for (key, value) in arguments {
				elementArguments[key] = value
			}
			try _database.write(sql, arguments: elementArguments)
		}
	}
}

// MARK: - internal implementation
private class _SQLiteEncoder: Swift.Encoder {
	let _database: Database
	let _storage = _KeyedStorage()
	var codingPath: Array<CodingKey> = []
	var userInfo: [CodingUserInfoKey : Any] = [:]
	var encodedArguments: SQLiteArguments { _storage.arguments }

	init(_ database: Database) {
		_database = database
	}

	func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
		_storage.reset()
		return KeyedEncodingContainer(_KeyedContainer<Key>(storage: _storage, database: _database))
	}
	func unkeyedContainer() -> UnkeyedEncodingContainer {
		fatalError("_SQLiteEncoder doesn't support unkeyed encoding")
	}
	func singleValueContainer() -> SingleValueEncodingContainer {
		fatalError("_SQLiteEncoder doesn't support single value encoding")
	}
}

private struct _KeyedContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
	typealias Key = K
	let codingPath: Array<CodingKey> = []
	let _database: Database
	var _storage: _KeyedStorage

	init(storage: _KeyedStorage, database: Database) {
		self._storage = storage
		self._database = database
	}

	mutating func encode<T>(entity: T, forKey key: K) throws where T: Encodable {
//		print("\(type(of: self)).encode Serializable for key: \(key)")
		guard let entity = entity as? Encodable & SQLiteSerializable else {
			throw SQLiteEncoder.Error.invalidType(T.self)
		}
		let encoder = _SQLiteEncoder(_database)
		try entity.encode(to: encoder)
		let entityType = type(of: entity)
		let sql = entityType.upsert.replacingOccurrences(of: ":table", with: entityType.recordType)
		try _database.write(sql, arguments: encoder.encodedArguments)
		_storage[key.stringValue] = .text(entity.id.uuidString)
	}
	mutating func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
		if let data = value as? Data {
			try encode(data, forKey: key)
		} else if let date = value as? Date {
			try encode(date, forKey: key)
		} else if let url = value as? URL {
			try encode(url, forKey: key)
		} else if let uuid = value as? UUID {
			try encode(uuid, forKey: key)
		} else if let id = value as? AnyEntityID {
			try encode(id, forKey: key)
		} else if nil != value as? Encodable & SQLiteSerializable {
			try encode(entity: value, forKey: key)
		} else {
			// print("\(type(of: self)).decode as JSON for key: \(key)")
			let jsonData = try jsonEncoder.encode(value)
			guard let jsonText = String(data: jsonData, encoding: .utf8) else {
				throw SQLiteEncoder.Error.invalidJSON(jsonData)
			}
			_storage[key.stringValue] = .text(jsonText)
		}
	}
	mutating func encode(_ value: String, forKey key: K) throws {
		_storage[key.stringValue] = .text(value)
	}
	mutating func encode(_ value: Data, forKey key: K) throws {
		_storage[key.stringValue] = .data(value)
	}
	mutating func encode(_ value: Date, forKey key: K) throws {
		let string = PreciseDateFormatter.string(from: value)
		_storage[key.stringValue] = .text(string)
	}
	mutating func encode(_ value: URL, forKey key: K) throws {
		_storage[key.stringValue] = .text(value.absoluteString)
	}
	mutating func encode(_ value: UUID, forKey key: K) throws {
		_storage[key.stringValue] = .text(value.uuidString)
	}
	mutating func encode(_ value: AnyEntityID, forKey key: K) throws {
		_storage[key.stringValue] = .text(value.uuidString)
	}
	mutating func encode(_ value: Bool, forKey key: K) throws {
		_storage[key.stringValue] = .integer(value ? 1 : 0)
	}
	mutating func encode(_ value: Int, forKey key: K) throws {
		_storage[key.stringValue] = .integer(Int64(value))
	}
	mutating func encode(_ value: Int8, forKey key: K) throws {
		_storage[key.stringValue] = .integer(Int64(value))
	}
	mutating func encode(_ value: Int16, forKey key: K) throws {
		_storage[key.stringValue] = .integer(Int64(value))
	}
	mutating func encode(_ value: Int32, forKey key: K) throws {
		_storage[key.stringValue] = .integer(Int64(value))
	}
	mutating func encode(_ value: Int64, forKey key: K) throws {
		_storage[key.stringValue] = .integer(value)
	}
	mutating func encode(_ value: UInt, forKey key: K) throws {
		_storage[key.stringValue] = .integer(Int64(value))
	}
	mutating func encode(_ value: UInt8, forKey key: K) throws {
		_storage[key.stringValue] = .integer(Int64(value))
	}
	mutating func encode(_ value: UInt16, forKey key: K) throws {
		_storage[key.stringValue] = .integer(Int64(value))
	}
	mutating func encode(_ value: UInt32, forKey key: K) throws {
		_storage[key.stringValue] = .integer(Int64(value))
	}
	mutating func encode(_ value: UInt64, forKey key: K) throws {
		guard value < Int64.max else { throw SQLiteEncoder.Error.invalidValue(value) }
		_storage[key.stringValue] = .integer(Int64(value))
	}
	mutating func encode(_ value: Float, forKey key: K) throws {
		_storage[key.stringValue] = .double(Double(value))
	}
	mutating func encode(_ value: Double, forKey key: K) throws {
		_storage[key.stringValue] = .double(value)
	}
	mutating func encodeNil(forKey key: K) throws {
		_storage[key.stringValue] = .null
	}

	mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
		fatalError("_KeyedContainer does not support nested containers.")
	}

	mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
		fatalError("_KeyedContainer does not support nested containers.")
	}

	mutating func superEncoder() -> Swift.Encoder {
		fatalError("_KeyedContainer does not support nested containers.")
	}

	mutating func superEncoder(forKey key: K) -> Swift.Encoder {
		fatalError("_KeyedContainer does not support nested containers.")
	}
}

private class _KeyedStorage {
	private var _elements = SQLiteArguments()

	var arguments: SQLiteArguments { _elements }

	func reset() {
		_elements.removeAll(keepingCapacity: true)
	}

	subscript(key: String) -> SQLiteValue? {
		get { _elements[key] }
		set { _elements[key] = newValue }
	}
}

private let jsonEncoder: JSONEncoder = {
	let encoder = JSONEncoder()
	encoder.dataEncodingStrategy = .base64
	encoder.dateEncodingStrategy = .custom({ (date, encoder) throws in
		let dateAsString = PreciseDateFormatter.string(from: date)
		var container = encoder.singleValueContainer()
		try container.encode(dateAsString)
	})
	return encoder
}()

public extension SQLiteEncoder {
	enum Error: LocalizedError {
		case invalidType(Any)
		case invalidValue(Any)
		case invalidJSON(Data)
		case transactionFailed
	}
}

public extension SQLiteEncoder.Error {
	var failureReason: String? {
		switch self {
		case .invalidType: return "Invalid type"
		case .invalidValue: return "Invalid value"
		case .invalidJSON: return "Invalid JSON"
		case .transactionFailed: return "Transaction failed"
		}
	}

	var recoverySuggestion: String? {
		switch self {
		case let .invalidType(value): return "`\(value)`"
		case let .invalidValue(value): return "`\(value)`"
		case .invalidJSON: return nil
		case .transactionFailed: return nil
		}
	}
	var errorDescription: String? {
		NSLocalizedString("SQLite Encoder error", comment: "")
	}
}
