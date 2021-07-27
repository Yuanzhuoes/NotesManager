//
//  SQLite.swift
//  test
//
//  Created by 李远卓 on 2021/6/26.
//
import Foundation
import SQLite3
// 缓存
var notes: [SQLNote]?
// error
enum SQLiteError: Error {
    case openDatabase(message: String)
    case prepare(message: String)
    case step(message: String)
    case bind(message: String)
    case other(message: String)
}
// table structures
struct SQLNote {
    let id: String
    let tag: String // 可以为空字符串
    let content: String
    let status: Int
}
protocol SQLTable {
    static var createStatement: String { get }
}
// how to modify the table?
extension SQLNote: SQLTable {
  static var createStatement: String {
    return """
    CREATE TABLE SQLNote(
        Id TEXT PRIMARY KEY NOT NULL,
        Tag TEXT,
        Content TEXT,
        Status BOOLEAN
    );
    """
  }
}
// my database
class SQLiteDatabase {
    // swift type of c pointer
    private let dbPointer: OpaquePointer?
    // computed property
    var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
      } else {
        return "No error message provided from sqlite."
      }
    }
    private init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    deinit {
        sqlite3_close(dbPointer)
    }
    // connect and open the database
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer?
        if sqlite3_open(path, &db) == SQLITE_OK {
            return SQLiteDatabase(dbPointer: db)
        } else {
            // always close database at last
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String(cString: errorPointer)
                throw SQLiteError.openDatabase(message: message)
            } else {
                throw SQLiteError.openDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
}
// singleton
class DBManager {
    private var db: SQLiteDatabase?
    // 隐藏单例
    private static let manager = DBManager()
    // 只暴露指针
    static let db: SQLiteDatabase? = manager.db
    private init () {
        let url = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dbPath = (url as NSString).appendingPathComponent("myNote.db")
        db = try? SQLiteDatabase.open(path: dbPath)
    }
}
// another singleton
// class DBManager {
//    let db: SQLiteDatabase?
//    static let manager = DBManager()
//    private init () {
//        let url = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        let dbPath = (url as NSString).appendingPathComponent("myNote.db")
//        db = try? SQLiteDatabase.open(path: dbPath)
//    }
// }
// wrap prepare statement
extension SQLiteDatabase {
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.prepare(message: errorMessage)
        }
        return statement
    }
}
// create database
extension SQLiteDatabase {
    func createTable(table: SQLTable.Type) throws {
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        defer {
            sqlite3_finalize(createTableStatement)
        }
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }
        print("\(table) table created.")
    }
}
// insert
extension SQLiteDatabase {
    func insertNote(myNote: SQLNote) throws {
        let insertSql = "INSERT INTO SQLNote (Id, Tag, Content, Status) VALUES (?, ?, ?, ?);"
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
          sqlite3_finalize(insertStatement)
        }
        // bint true data to the placeholder, index start from 1 in the SQL
        let id = myNote.id as NSString
        let tag = myNote.tag as NSString
        let content = myNote.content as NSString
        guard
            sqlite3_bind_text(insertStatement, 1, id.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 2, tag.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 3, content.utf8String, -1, nil) == SQLITE_OK &&
                sqlite3_bind_int(insertStatement, 4, Int32(myNote.status)) == SQLITE_OK
        else {
            throw SQLiteError.bind(message: errorMessage)
        }
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }
        print("Successfully inserted row.")
    }
}
// delete
extension SQLiteDatabase {
    func deleteNote (nid: String) throws {
        let deleteSQL = "DELETE FROM SQLNote WHERE Id = ?;"
        let deleteStatement = try prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(deleteStatement)
        }
        let id = nid as NSString
        guard
            sqlite3_bind_text(deleteStatement, 1, id.utf8String, -1, nil) == SQLITE_OK
        else {
            throw SQLiteError.bind(message: errorMessage)
        }
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }
        print("Successfully delete row.")
    }
}
// update
extension SQLiteDatabase {
    func updateNote (myNote: SQLNote) throws {
        let updateSQL = "UPDATE SQLNote SET Tag = ?, Content = ?, Status = ? WHERE Id = ?;"
        let updateStatement = try prepareStatement(sql: updateSQL)
        defer {
          sqlite3_finalize(updateStatement)
        }
        let id = myNote.id as NSString
        let tag = myNote.tag as NSString
        let content = myNote.content as NSString
        guard
            sqlite3_bind_text(updateStatement, 1, tag.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(updateStatement, 2, content.utf8String, -1, nil) == SQLITE_OK &&
                sqlite3_bind_int(updateStatement, 3, Int32(myNote.status)) == SQLITE_OK &&
                sqlite3_bind_text(updateStatement, 4, id.utf8String, -1, nil) == SQLITE_OK
        else {
            throw SQLiteError.bind(message: errorMessage)
        }
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }
        print("Successfully update row.")
    }
}
// query with nid
extension SQLiteDatabase {
    func queryNote(nid: String) throws -> SQLNote? {
        let querySql = "SELECT * FROM SQLNote WHERE Id = ?;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        defer {
            sqlite3_finalize(queryStatement)
        }
        let nid = nid as NSString
        guard sqlite3_bind_text(queryStatement, 1, nid.utf8String, -1, nil) == SQLITE_OK else {
            throw SQLiteError.bind(message: errorMessage)
        }
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            throw SQLiteError.step(message: errorMessage)
        }
        // get id, index start from zero, and id is not null
        guard let queryResultCol0 = sqlite3_column_text(queryStatement, 0) else {
            print("nid is nil.")
            return nil
        }
        // get values
        guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
            print("tag is nil.")
            return nil
        }
        guard let queryResultCol2 = sqlite3_column_text(queryStatement, 2) else {
            print("content is nil.")
            return nil
        }
        let status = sqlite3_column_int(queryStatement, 3)
        // cast data and return
        let id = String(cString: queryResultCol0) as String
        let tag = String(cString: queryResultCol1) as String
        let content = String(cString: queryResultCol2) as String
        return SQLNote(id: id, tag: tag, content: content, status: Int(status))
    }
}
// insert all notes
extension SQLiteDatabase {
    func insertAllNotesToDB(notes: [ServerDescription.Items]) {
        for note in notes {
            let id = note.id
            let tag = note.title
            let content = note.content
            let status = note.isPublic == true ? 1 : 0
            do {
                try DBManager.db?.insertNote(myNote: SQLNote(id: id!, tag: tag!, content: content!, status: status))
            } catch {
                print(DBManager.db?.errorMessage as Any)
            }
        }
    }
}
// select from offset to limit
extension SQLiteDatabase {
    func queryAllSQLNotes() throws -> [SQLNote] {
        let selectSQL = "SELECT * FROM SQLNote"
        let selectStatement = try prepareStatement(sql: selectSQL)
        var notesArray: [SQLNote] = [] //
        defer {
          sqlite3_finalize(selectStatement)
        }
        while sqlite3_step(selectStatement) == SQLITE_ROW {
            guard let queryResultCol0 = sqlite3_column_text(selectStatement, 0) else {
                print("id nil")
                return []
            }
            guard let queryResultCol1 = sqlite3_column_text(selectStatement, 1) else {
                print("tag nil")
                return []
            }
            guard let queryResultCol2 = sqlite3_column_text(selectStatement, 2) else {
                print("content nil")
                return []
            }
            let status = sqlite3_column_int(selectStatement, 3)
            let id = String(cString: queryResultCol0) as String
            let tag = String(cString: queryResultCol1) as String
            let content = String(cString: queryResultCol2) as String
            notesArray.append(SQLNote(id: id, tag: tag, content: content, status: Int(status))) //
        }
        return notesArray
    }
}
// count
extension SQLiteDatabase {
    func count () -> Int {
        let countSQL = "SELECT count(*) FROM SQLNote;"
        var count: Int = 0
        let countStatement = try? prepareStatement(sql: countSQL)
        defer {
            sqlite3_finalize(countStatement)
        }
        while sqlite3_step(countStatement) == SQLITE_ROW {
            count = Int(sqlite3_column_int(countStatement, 0))
        }
        return count
    }
}
