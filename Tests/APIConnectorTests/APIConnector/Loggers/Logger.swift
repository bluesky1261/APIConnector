//
//  Logger.swift
//  
//
//  Created by Joonghoo Im on 2022/07/02.
//

import Foundation

class Logger {
    enum LogEventType: String {
        case error  = "‼️ " // 오류발생시 출력 - en) Output in case of error
        case info   = "ℹ️ " // 정보형 출력 - en) Informational output
        case trace  = "💬 " // 일반 trace 로그 -en) General trace log
        case hot    = "🔥 " // 중요한 로그를 확인할때 이용 - en) Used to check important logs
    }

    class func log(_ message: Any, logType: LogEventType = .trace, full: Bool = true,
                   fileName: String = #file,
                   line: UInt = #line,
                   funcName: String = #function) {
        #if DEBUG
        if full {
            print("\(logType.rawValue)[\(Date().logString())][\(sourceFileName(filePath: fileName))]:\(line) - \(funcName) -> \(message)")
        } else {
            print("[\(Date().logString())] \(message)")
        }
        #endif
    }

    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

extension Logger {
    class func error(_ message: Any, fileName: String = #file, line: UInt = #line, funcName: String = #function) {
        log(message, logType: .error, fileName: fileName, line: line, funcName: funcName)
    }

    class func info(_ message: Any, fileName: String = #file, line: UInt = #line, funcName: String = #function) {
        log(message, logType: .info, fileName: fileName, line: line, funcName: funcName)
    }

    class func trace(_ message: Any, fileName: String = #file, line: UInt = #line, funcName: String = #function) {
        log(message, logType: .trace, fileName: fileName, line: line, funcName: funcName)
    }

    class func hot(_ message: Any, fileName: String = #file, line: UInt = #line, funcName: String = #function) {
        log(message, logType: .hot, fileName: fileName, line: line, funcName: funcName)
    }

    class func short(_ message: Any, fileName: String = #file, line: UInt = #line, funcName: String = #function) {
        log(message, logType: .info, full: false, fileName: fileName, line: line, funcName: funcName)
    }
}
