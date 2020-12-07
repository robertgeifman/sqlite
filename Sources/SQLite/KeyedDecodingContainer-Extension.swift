//
//  Created by Robert Geifman on 28/01/2020.
//  Copyright © 2020 Robert Geifman. All rights reserved.
//

import Foundation

// MARK: - KeyedDecodingContainer
public extension KeyedDecodingContainer {
	@available(*, unavailable)
	func decode<T: Decodable>(_ key: Key, as type: T.Type = T.self) throws -> T
		where T: Sequence, T.Element: Encodable & SQLiteSerializable {
		try decode(type, forKey: key)
	}
	func decode<T: Entity>(_ key: Key, as type: T.Type = T.self) throws -> EntityID<T> {
//		print("KeyedDecodingContainer.decode EntityID<\(type)> for key: \(key)")
		let value = try decode(UUIDString.self, forKey: key)
		return try EntityID(uuidString: value)
	}
	func decodeIfPresent<T: Entity>(_ key: Key, as type: T.Type = T.self) throws -> EntityID<T>? {
		if let value = try decodeIfPresent(UUIDString.self, forKey: key) {
			return EntityID(fromDecodedString: value)
		}
		return nil
	}
}
