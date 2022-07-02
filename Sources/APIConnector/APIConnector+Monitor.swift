//
//  APIConnector+Monitor.swift
//  
//
//  Created by Joonghoo Im on 2022/07/02.
//

import Foundation
import Alamofire

protocol ResponseTrackable {
    associatedtype Failure: Error
    var response: HTTPURLResponse? { get }
    var error: Failure? { get }
    var data: Data? { get }
    var fileURL: URL? { get }
}

extension DataResponse: ResponseTrackable {
    var fileURL: URL? {
        return nil
    }
}

extension DownloadResponse: ResponseTrackable {
    var data: Data? {
        guard let fileURL = fileURL else { return nil }
        return try? Data(contentsOf: fileURL)
    }
}

final class APIConnectorMonitor {
    private var duration: [UUID: TimeInterval] = [:]
    
    private let key: String
    private let logger: APIConnectorLogger?
    
    init(key: String,
         logger: APIConnectorLogger? = nil) {
        self.key = key
        self.logger = logger
    }
    
    func startLogging(_ request: Request) {
        duration[request.id] = Date().timeIntervalSince1970
        
        let headers: [String: String] = request.request?.headers.dictionary ?? [:]
        let isError = request.request == nil
        
        var requestLog = "[\(key)] ➡️ \(request.request?.httpMethod ?? "N/A") \(request.request?.url?.path ?? "")\n"
        requestLog += "URL: " + (request.request?.url?.absoluteString ?? "N/A") + "\n"
        
        requestLog += "Request Headers: " + String(describing: headers) + "\n"
        requestLog += "Body: " + String(describing: request.request?.httpBody?.toPrettyPrintedString)
        
        logger?.startLogging(requestLog, isError: isError, file: #file, function: #function, line: #line)
    }
    
    func endLogging<T>(_ request: Request, response: T) where T: ResponseTrackable {
        var responseTime: String = "[?ms]"
        
        responseTime = "[\(Int(((Date().timeIntervalSince1970 - duration[request.id]!) * 1_000.0).rounded()))ms]"
        duration[request.id] = nil
        
        let statusCode = response.response?.statusCode ?? 0
        let isError = !(APIConnector.validStatusCode).contains(statusCode) || response.error != nil
        
        var requestLog = "[\(key)] \(isError ? "🛑" : "✅") \(request.request?.httpMethod ?? "N/A") \(responseTime) \(request.request?.url?.path ?? "")\n"
        requestLog += "URL: " + (request.request?.url?.absoluteString ?? "N/A") + "\n"
        requestLog += "Status Code: " + String(describing: statusCode) + "\n"
        requestLog += "Response Headers: " + String(describing: response.response?.headers) + "\n"
        
        if let data = response.data {
            requestLog += "Raw Data: " + "\(data)" + "\n"
        }
        
        if let fileURL = response.fileURL {
            requestLog += "File URL: " + "\(fileURL)" + "\n"
        }
        
        if let error = response.error {
            requestLog += "Error Reason: \(error.localizedDescription) \n"
        }
        
        requestLog += "JSON Data: \(response.data?.toPrettyPrintedString ?? "nil")"
        
        logger?.endLogging(requestLog, isError: isError, file: #file, function: #function, line: #line)
    }
}

// MARK: - EventMonitor
extension APIConnectorMonitor: EventMonitor {
    // MARK: Request & Download Start
    func request(_ request: Request,
                 didResumeTask task: URLSessionTask) {
        startLogging(request)
    }
    
    // MARK: DataRequest
    func request<Value>(_ request: DataRequest,
                        didParseResponse response: DataResponse<Value, AFError>) {
        endLogging(request, response: response)
    }
    
    func request(_ request: DataRequest,
                 didParseResponse response: DataResponse<Data?, AFError>) {
        endLogging(request, response: response)
    }
    
    // MARK: DownloadRequest
    func request(_ request: DownloadRequest,
                 didParseResponse response: DownloadResponse<URL?, AFError>) {
        endLogging(request, response: response)
    }
    
    func request<Value>(_ request: DownloadRequest,
                        didParseResponse response: DownloadResponse<Value, AFError>) {
        endLogging(request, response: response)
    }
    
    // MARK: Validation
    func request(_ request: DataRequest,
                 didValidateRequest urlRequest: URLRequest?,
                 response: HTTPURLResponse,
                 data: Data?,
                 withResult result: Request.ValidationResult) {
        if case .failure = result {
            var message = "[\(key)] 🛑 DataRequest Validation 에러 발생.\n"
            message += "URL: \(request)\n"
            message += "데이터: \(data?.toPrettyPrintedString ?? "")"
            
            logger?.validationError(message)
        }
    }
    
    func request(_ request: DownloadRequest,
                 didValidateRequest urlRequest: URLRequest?,
                 response: HTTPURLResponse,
                 fileURL: URL?,
                 withResult result: Request.ValidationResult) {
        if case .failure = result {
            var message = "[\(key)] 🛑 DownloadRequest Validation 에러 발생.\n"
            message += "URL: \(request)\n"
            message += "파일 경로: \(fileURL?.absoluteURL.absoluteString ?? "")"
            
            logger?.validationError(message)
        }
    }
}

// MARK: - Data+PrettyPrintedString
fileprivate extension Data {
    var toPrettyPrintedString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) else { return nil }
        return String(decoding: data, as: UTF8.self)
    }
}
