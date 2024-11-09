//
//  APIConnector+Logger.swift
//  
//
//  Created by Joonghoo Im on 2022/07/02.
//

public protocol APIConnectorLogger {
    func startLogging(_ logMessage: String, isError: Bool, file: String, function: String, line: UInt)
    func endLogging(_ logMessage: String, isError: Bool, file: String, function: String, line: UInt)
    func validationError(_ errorMessage: String)
}
