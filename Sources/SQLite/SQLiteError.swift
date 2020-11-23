import Foundation
import SQLite3

public enum SQLiteError: LocalizedError {
	case onInternalError(String)
	case onOpen(Int32, String)
	case onClose(Int32)
	case onPrepareStatement(Int32, String)
	case onGetParameterIndex(String)
	case onBindParameter(Int32, Int32, SQLiteValue)
	case onStep(Int32, String)
	case onWrite(Array<SQLiteRow>)
	case onGetColumnType(Int32)
	case onCreateFunction(String, Int32)
	case onRemoveFunction(String, Int32)
	case onGetColumnInTable(String)
	case onGetIndexInTable(String)
	case onGetSQL
	case onInvalidTableName(String)
	case onDecodingRow(String)
	case onInvalidDecodingType(String)
	case onInvalidSelectStatementColumnCount
	case onObserveWithoutColumnMetadata
	case onSubscribeWithoutDatabase
}

extension SQLiteError: CustomStringConvertible {
	public var failureReason: String? {
		switch self {
		case .onInternalError: return "Internal error"
		case .onOpen(let code, _): return "Could not open database: \(string(for: code))"
		case .onClose(let code): return "Could not close database: \(string(for: code))"
		case .onPrepareStatement(let code, _): return "Could not prepare statement - \(string(for: code))"
		case .onGetParameterIndex: return "Could not get index for parameter"
		case .onBindParameter(let code, _, _): return "Could not bind value to index: \(string(for: code))"
		case .onStep(let code, _): return "Could not execute SQL - \(string(for: code))"
		case .onWrite(let result): return "Write returned results: `\(result)`"
		case .onGetColumnType(_): return "Invalid column type"
		case .onCreateFunction(_, let code): return "Could not create function: \(string(for: code))"
		case .onRemoveFunction(_, let code): return "Could not remove function: \(string(for: code))"
		case .onGetColumnInTable: return "Could not get column in table"
		case .onGetIndexInTable: return "Could not get index in table"
		case .onGetSQL: return "Could not get SQL for prepared statement"
		case .onInvalidTableName: return "Invalid table name"
		case .onDecodingRow: return "Could not decode value"
		case .onInvalidDecodingType: return "Could not decode value of type"
		case .onInvalidSelectStatementColumnCount: return "A SELECT statement must contain at least one result column"
		case .onObserveWithoutColumnMetadata: return "Could not observe database because SQLite was not compiled with SQLITE_ENABLE_COLUMN_METADATA"
		case .onSubscribeWithoutDatabase: return "Could not subscribe because the SQLite database has been deallocated"
		}
	}
	public var recoverySuggestion: String? {
		switch self {
		case .onInternalError: return nil
		case .onOpen(_, let path): return path
		case .onClose(_): return nil
		case .onPrepareStatement(_, let sql): return sql
		case .onGetParameterIndex(let parameterName): return parameterName
		case .onBindParameter(_, let index, let value): return "value: \(value), index: \(index)"
		case .onStep(_, let sql): return sql
		case .onWrite: return nil
		case .onGetColumnType(let type): return "type: `\(type)`"
		case .onCreateFunction(let functionName, _): return functionName
		case .onRemoveFunction(let functionName, _): return functionName
		case .onGetColumnInTable(let error): return error
		case .onGetIndexInTable(let error): return error
		case .onGetSQL: return nil
		case .onInvalidTableName(let tableName): return tableName
		case .onDecodingRow(let valueName): return valueName
		case .onInvalidDecodingType(let typeDescription): return typeDescription
		case .onInvalidSelectStatementColumnCount: return nil
		case .onObserveWithoutColumnMetadata: return nil
		case .onSubscribeWithoutDatabase: return nil
		}
	}
	public var errorDescription: String? {
		NSLocalizedString("Database error", comment: "")
	}
	public var description: String {
		switch self {
		case .onInternalError(let error): return "Internal error: `\(error)`"
		case .onOpen(let code, let path): return "Could not open database at `\(path)`: \(string(for: code))"
		case .onClose(let code): return "Could not close database: \(string(for: code))"
		case .onPrepareStatement(let code, let sql): return "Could not prepare statement for `\(sql)`: \(string(for: code))"
		case .onGetParameterIndex(let parameterName): return "Could not get index for `\(parameterName)`"
		case .onBindParameter(let code, let index, let value): return "Could not bind \(value) to \(index): \(string(for: code))"
		case .onStep(let code, let sql): return "Could not execute SQL `\(sql)`: \(string(for: code))"
		case .onWrite(let result): return "Write returned results: `\(result)`"
		case .onGetColumnType(let type): return "Invalid column type: \(type)"
		case .onCreateFunction(let name, let code): return "Could not create function `\(name)`: \(string(for: code))"
		case .onRemoveFunction(let name, let code): return "Could not remove function `\(name)`: \(string(for: code))"
		case .onGetColumnInTable(let error): return "Could not get column in table: \(error)"
		case .onGetIndexInTable(let error): return "Could not get index in table: \(error)"
		case .onGetSQL: return "Could not get SQL for prepared statement"
		case .onInvalidTableName(let tableName): return "`\(tableName)` is not a valid table name"
		case .onDecodingRow(let valueName): return "Could not decode value for `\(valueName)`"
		case .onInvalidDecodingType(let typeDescription): return "Could not decode value of type `\(typeDescription)`"
		case .onInvalidSelectStatementColumnCount: return "A SELECT statement must contain at least one result column"
		case .onObserveWithoutColumnMetadata: return "Could not observe database because SQLite was not compiled with SQLITE_ENABLE_COLUMN_METADATA"
		case .onSubscribeWithoutDatabase: return "Could not subscribe because the SQLite database has been deallocated"
		}
	}

	func string(for code: Int32) -> String { String(cString: sqlite3_errstr(code)) }
}
