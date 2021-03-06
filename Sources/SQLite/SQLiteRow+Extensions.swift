import Foundation

extension Dictionary where Dictionary.Key == String, Dictionary.Value == SQLiteValue {
    public func optionalValue<V>(for key: CodingKey) -> V? {
        return try? value(for: key)
    }

    public func optionalValue<V>(for key: String) -> V? {
        return try? value(for: key)
    }

    public func value<V>(for key: CodingKey) throws -> V {
        return try self.value(for: key.stringValue)
    }

    public func value<V>(for key: String) throws -> V {
        if String.self == V.self {
            guard let value = self[key]?.stringValue else { throw SQLiteError.onDecodingRow(key) }
            return value as! V
        } else if Int.self == V.self {
            guard let value = self[key]?.intValue else { throw SQLiteError.onDecodingRow(key) }
            return value as! V
        } else if Bool.self == V.self {
            guard let value = self[key]?.boolValue else { throw SQLiteError.onDecodingRow(key) }
            return value as! V
        } else if Double.self == V.self {
            guard let value = self[key]?.doubleValue else { throw SQLiteError.onDecodingRow(key) }
            return value as! V
        } else if Data.self == V.self {
            guard let value = self[key]?.dataValue else { throw SQLiteError.onDecodingRow(key) }
            return value as! V
        } else if Int64.self == V.self {
            guard let value = self[key]?.int64Value else { throw SQLiteError.onDecodingRow(key) }
            return value as! V
        } else if Optional<String>.self == V.self {
            return self[key]?.stringValue as! V
        } else if Optional<Int>.self == V.self {
            return self[key]?.intValue as! V
        } else if Optional<Bool>.self == V.self {
            return self[key]?.boolValue as! V
        } else if Optional<Double>.self == V.self {
            return self[key]?.doubleValue as! V
        } else if Optional<Data>.self == V.self {
            return self[key]?.dataValue as! V
        } else if Optional<Int64>.self == V.self {
            return self[key]?.int64Value as! V
        } else {
            throw SQLiteError.onInvalidDecodingType(String(describing: V.self))
        }
    }
}
