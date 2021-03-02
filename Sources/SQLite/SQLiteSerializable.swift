//
//  Created by Robert Geifman on 02/09/2020.
//  Copyright © 2020 Robert Geifman. All rights reserved.
//
//	"Telling a programmer there’s already a library to do X
// 		is like telling a songwriter there’s already a song about love.”
//																		 				- Pete Cordell
//

import Foundation
import FoundationAdditions

// MARK: - SQLiteSerializable
public protocol SQLiteSerializable: AnySerializable {
//    static var primaryKey: String { get }
    static var deleteTable: SQL { get }
    static var createTable: SQL { get }
    static var upsert: SQL { get }
    static var fetch: SQL { get }
    static var delete: SQL { get }
    static var fetchAll: SQL { get }

    var id: AnyEntityID { get }
}

public extension SQLiteSerializable {
    static var deleteTable: SQL {
		"DROP TABLE IF EXISTS :table;"
	}
	static func deleteTable(in database: SQLite.Database) throws {
		try database.execute(raw: deleteTable.replacingOccurrences(of: ":table", with: recordType))
	}
	static func createTable(in database: SQLite.Database) throws {
		try database.execute(raw: createTable.replacingOccurrences(of: ":table", with: recordType))
	}
}
