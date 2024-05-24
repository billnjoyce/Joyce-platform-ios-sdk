//
//  LogManager.swift
//  Joyce Studios
//
//  Created by billkim on 2023/09/19.
//

import Foundation

struct LogInfo {
    var dates: String = ""
    var log: String = ""
    
    func toString() -> String {
        return "[\(dates)] \(log)"
    }
}

class BaseRepository: NSObject {
    
}

class LogRepository: BaseRepository {
    private var logs: [LogInfo]?
    
    func pushLog(log: String) {
        if !LogManager.shared.getDebugMode() {
            return
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dates = formatter.string(from: date)
        
        let logInfo: LogInfo = LogInfo(dates: dates, log: log)
        logs?.append(logInfo)
        
        NSLog(logInfo.toString())
    }
    
    func clearLogs() {
        logs?.removeAll()
    }
    
    func getLogs() -> String {
        var ret = ""
        
        logs?.forEach({ logInfo in
            let text = logInfo.toString()
            ret += "\(text)\n"
        })
        
        return ret
    }
}

@objc
public class BaseUsecase: NSObject {
    let repository: BaseRepository
    
    init(repository: BaseRepository) {
        self.repository = repository
    }
}

class LogUsecase: BaseUsecase {
    func pushLog(log: String) {
        let repository: LogRepository = self.repository as! LogRepository
        repository.pushLog(log: log)
    }
    
    func clearLogs() {
        let repository: LogRepository = self.repository as! LogRepository
        repository.clearLogs()
    }
    
    func getLogs() -> String {
        let repository: LogRepository = self.repository as! LogRepository
        return repository.getLogs()
    }
}

public class LogManager: NSObject {
    private static let instance = LogManager()
    
    @objc static let shared = LogManager()
    
    private var repository: LogRepository?
    
    private var isDebugMode = true
    
    override init() {
        repository = LogRepository()
    }
    
    public func setDebugMode(isDebugMode: Bool) {
        self.isDebugMode = isDebugMode
    }
    
    public func getDebugMode() -> Bool {
        return self.isDebugMode
    }
    
    @objc (pushLog:)
    public func pushLog(log: String) {
        if (repository == nil) {
            return
        }
        
        if Util.isAppstoreBuild() {
            return
        }
        
        let usecase = LogUsecase(repository: repository!)
        usecase.pushLog(log: log)
    }
    
    @objc
    public func clearLogs() {
        if (self.repository == nil) {
            return
        }
        
        let usecase = LogUsecase(repository: self.repository!)
        usecase.clearLogs()
    }
    
    @objc
    public func getLogs() -> String {
        if (self.repository == nil) {
            return ""
        }
        
        let usecase = LogUsecase(repository: self.repository!)
        return usecase.getLogs()
    }
}




