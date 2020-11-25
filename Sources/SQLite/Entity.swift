//
//  Created by Robert Geifman on 31/12/2019.
//  Copyright © 2019 Robert Geifman. All rights reserved.
//

import Foundation

// MARK: - Entity
public protocol Entity: AnySerializable, Identifiable, Equatable
	where ID: TypedEntityID {
    associatedtype Keys: CodingKey & RawRepresentable
    
	static var transferSize: Int { get }
}

public extension Entity {
	static var transferSize: Int { MemoryLayout<Self>.size }
	var id: AnyEntityID { id }
//	var id: UUIDString { id.uuidString }

	static func == (a: Self, b: Self) -> Bool { a.id == b.id }
}

public extension Entity {
	mutating func append<T: Entity>(_ element: EntityID<T>, in keyPath: WritableKeyPath<Self, [EntityID<T>]?>) {
		if var array = self[keyPath: keyPath] {
			array.append(element)
			self[keyPath: keyPath] = array
			return
		}
		var array = [EntityID<T>]()
		array.append(element)
		self[keyPath: keyPath] = array
	}
	
	mutating func remove<T: Entity>(_ element: EntityID<T>, in keyPath: WritableKeyPath<Self, [EntityID<T>]?>) {
		guard var array = self[keyPath: keyPath] else { return }
		array.removeAll { element == $0 }
		self[keyPath: keyPath] = array
	}
}
