//
//  Created by Robert Geifman on 28/01/2020.
//  Copyright © 2020 Robert Geifman. All rights reserved.
//
//	"Telling a programmer there’s already a library to do X
// 		is like telling a songwriter there’s already a song about love.”
//																		 				- Pete Cordell
//

import Foundation
import FoundationAdditions

// MARK: - KeyedDecodingContainer
public extension KeyedDecodingContainer {
	func decode<T: Entity>(_ key: Key, as type: T.Type = T.self) throws -> EntityID<T> {
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
