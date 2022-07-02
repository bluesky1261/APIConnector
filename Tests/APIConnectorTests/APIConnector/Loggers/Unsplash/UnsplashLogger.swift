//
//  UnsplashLogger.swift
//  
//
//  Created by Joonghoo Im on 2022/07/02.
//

import Foundation
import APIConnector

final class UnsplashMonitor: APIConnectorLogger {
    func startLogging(_ logMessage: String, isError: Bool, file: String, function: String, line: UInt) {
        if isError {
            Logger.error(logMessage, fileName: file, line: line, funcName: function)
        } else {
            Logger.info(logMessage, fileName: file, line: line, funcName: function)
        }
    }
    
    func endLogging(_ logMessage: String, isError: Bool, file: String, function: String, line: UInt) {
        if isError {
            Logger.error(logMessage, fileName: file, line: line, funcName: function)
        } else {
            Logger.info(logMessage, fileName: file, line: line, funcName: function)
        }
    }
    
    func validationError(_ errorMessage: String) {
        Logger.error(errorMessage)
    }
}
