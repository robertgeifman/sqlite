//
//  Created by Robert Geifman on 28/01/2020.
//  Copyright © 2020 Robert Geifman. All rights reserved.
//

import Foundation

// MARK: - UUIDString
public typealias UUIDString = String

// MARK: - AnyEntityID
public protocol AnyEntityID {
	var uuid: UUID { get }
}

public extension AnyEntityID {
	var uuidString: UUIDString { uuid.uuidString }
}

// MARK: - EntityID
public protocol TypedEntityID: AnyEntityID, Hashable {
	associatedtype T: Entity
}

// MARK: - EntityID
public struct EntityID<T: Entity>: TypedEntityID {
	public let uuid: UUID
}

public extension EntityID {
	enum Error: LocalizedError {
		case nilID(entityName: String)
		case nilObject(entityName: String)
		case invalidUUIDString
	}

	static var recordType: String { T.recordType }
	var recordType: String { T.recordType }
	
	init(_ uuid: UUID = UUID()) { self.uuid = uuid }
	
	init(uuidString: UUIDString) throws {
		guard let uuid = UUID(uuidString: uuidString) else { throw Error.invalidUUIDString }
		self.uuid = uuid
	}
	
	init?(fromDecodedString value: UUIDString?) {
		guard let value = value, !value.isEmpty,
			let uuid = UUID(uuidString: value) else { return nil }
		self.uuid = uuid
	}
}

extension EntityID: CustomStringConvertible {
	public var description: String { "\(T.recordType).ID: \(uuid.uuidString)" }
}

extension EntityID: Hashable {
	public static func == (a: Self, b: Self) -> Bool { a.uuid == b.uuid }
	public func hash(into hasher: inout Hasher) { uuid.hash(into: &hasher) }
}
/*
extension EntityID {
	enum Keys: String, CodingKey, CaseIterable {
		case uuidString, recordType
	}
}
*/
extension EntityID: Decodable where T: Decodable {
	public init(from decoder: Decoder) throws {
		self.uuid = try .init(from: decoder)
	}
}
extension EntityID: Encodable where T: Encodable {
	public func encode(to encoder: Encoder) throws {
		try uuid.encode(to: encoder)
	}
}
