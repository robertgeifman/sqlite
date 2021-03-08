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

// MARK: - KeyedEncodingContainer
public extension KeyedEncodingContainer {
	mutating func encode<T: Entity>(_ value: EntityID<T>?, forKey key: Key) throws {
		if let value = value { try self.encode(value.uuid.uuidString, forKey: key) }
	}

	mutating func encode<T: Entity>(_ value: [EntityID<T>]?, forKey key: Key) throws {
		if let list = value { try self.encode(list.map { $0.uuid.uuidString }, forKey: key) }
	}
}
