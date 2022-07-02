//
//  APIConnector+Logger.swift
//  
//
//  Created by Joonghoo Im on 2022/07/02.
//

import Foundation
import Alamofire

public protocol APIConnectorLogger: AnyObject {
    func startLogging(_ logMessage: String, isError: Bool, file: String, function: String, line: UInt)
    func endLogging(_ logMessage: String, isError: Bool, file: String, function: String, line: UInt)
    func validationError(_ errorMessage: String)
}
