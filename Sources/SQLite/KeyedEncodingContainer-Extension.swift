//
//  Created by Robert Geifman on 28/01/2020.
//  Copyright © 2020 Robert Geifman. All rights reserved.
//

import Foundation
import FoundationAdditions

// MARK: - KeyedEncodingContainer
public extension KeyedEncodingContainer {
	@available(*, unavailable)
	mutating func encode<T>(_ value: T, forKey key: Key) throws
		where T: Sequence, T.Element: Encodable & SQLiteSerializable {
//		print("\(type(of: self)).encode \(type(of: value)) for key: \(key)")
//		guard let actualContainer = self else {
//			return try encode(value as Encodable, forKey: key)
//		}
//		let ids = value.map { $0.id }
//		let recordType = T.Element.recordType
	}

	mutating func encode<T: Entity>(_ value: EntityID<T>?, forKey key: Key) throws {
//		print("\(type(of: self)).encode \(type(of: value)) for key: \(key)")
		if let value = value { try self.encode(value.uuid.uuidString, forKey: key) }
	}

	mutating func encode<T: Entity>(_ value: [EntityID<T>]?, forKey key: Key) throws {
		print("\(type(of: self)).encode \(type(of: value)) for key: \(key)")
		if let list = value { try self.encode(list.map { $0.uuid.uuidString }, forKey: key) }
	}
}
