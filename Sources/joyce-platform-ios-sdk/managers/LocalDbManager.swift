//
//  LocalDbManager.swift
//  Joyce Studios
//
//  Created by billkim on 2023/12/17.
//

import Foundation
import GRDB

// https://github.com/groue/GRDB.swift#executing-updates

class LocalDbManager {
    static let shared = LocalDbManager()
    private var dbQueue: DatabaseQueue?
    
    private let rootPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let dbName = "database.sqlite3"
    
    init() {
        let dbPath = rootPath.appendingPathComponent(dbName)
        LogManager.shared.pushLog(log: "dbPath : \(dbPath)")
        
        self.dbQueue = try! createDB(path: dbPath.absoluteString)
    }
    
    func clearAll() {
        do {
            try self.dbQueue?.erase()
        } catch {
            
        }
    }
    
    func deleteDb() {
        do {
            let dbPath = LocalDbManager.shared.rootPath.appendingPathComponent(dbName)
            try FileManager.default.removeItem(at: dbPath)
        } catch {
            
        }
    }
    
    func getDbQueue() -> DatabaseQueue? {
        return self.dbQueue
    }
    
    func createDB(path: String) throws -> DatabaseQueue {
        let dbQueue = try DatabaseQueue(path: path)
        
        return dbQueue
    }
    
    func createTable(path: String, tableName: String, query: String) throws {
        try self.dbQueue?.write { db in
            try db.execute(sql: """
                                CREATE TABLE \(tableName) (\(query))
                                """)
        }
    }
    
    func deleteTable(path: String, tableName: String) throws {
        try self.dbQueue?.write { db in
            try db.execute(sql: """
                                DROP TABLE \(tableName))
                                """)
        }
    }
}
