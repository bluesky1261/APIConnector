//
//  APIConnector+Monitor.swift
//  
//
//  Created by Joonghoo Im on 2022/07/02.
//
import Foundation

public protocol ResponseTrackable {
    associatedtype Failure: Error
    var response: HTTPURLResponse? { get }
    var error: Failure? { get }
    var data: Data? { get }
    var fileURL: URL? { get }
}

extension DataResponse: ResponseTrackable {
    public var fileURL: URL? {
        return nil
    }
}

extension DownloadResponse: ResponseTrackable {
    public var data: Data? {
        guard let fileURL = fileURL else { return nil }
        return try? Data(contentsOf: fileURL)
    }
}

open class APIConnectorMonitor: @unchecked Sendable {
    private var duration: [UUID: TimeInterval] = [:]
    private let configuration: APIConnectorConfigurable
    private let logger: APIConnectorLogger?
    
    init(
        configuration: APIConnectorConfigurable = APIConnectorConfig(),
        logger: APIConnectorLogger? = nil
    ) {
        self.configuration = configuration
        self.logger = logger
    }
    
    private func startLogging(_ request: Request) {
        duration[request.id] = Date().timeIntervalSince1970
        
        let httpHeaders: [String: String] = {
            guard var lastRequest = request.request else { return [:] }
            let httpAdditionalHeaders = self.configuration.sessionConfiguration.httpAdditionalHeaders as? [String: String] ?? [:]
            
            var mutable = lastRequest.headers.dictionary
            mutable.merge(httpAdditionalHeaders, uniquingKeysWith: { $1 })
            
            return mutable
        }()
        
        // TODO:  API별로 별도의 Signature로 관리되도록 개선
        var requestLog = "[API] ➡️ \(request.httpMethod) \(request.httpPath)\n"
        requestLog += "URL: \(request.httpFullPath)\n"
        requestLog += "Request Headers: \(httpHeaders)\n"
        
        if let httpBody = request.httpBody {
            requestLog += "Body: \(httpBody.toPrettyPrintedString)\n"
        }
        
        logger?.startLogging(requestLog, isError: request.hasError, file: #file, function: #function, line: #line)
    }
    
    private func endLogging<T>(_ request: Request, response: T?) where T: ResponseTrackable {
        let millisecondsToRespond: String = {
            guard let millisecondsToRespond = self.millisecondsToRespond(at: request.id) else {
                return "[Unknown]"
            }
            
            return "[\(millisecondsToRespond)ms]"
        }()
        
        let hasError = !configuration.validStatusCode.contains(request.statusCode) || request.hasError
        
        var requestLog = "[API] \(hasError ? "🛑" : "✅") \(request.httpMethod) \(millisecondsToRespond) \(request.httpPath)\n"
        requestLog += "URL: \(request.httpFullPath)\n"
        requestLog += "Status Code: \(request.statusCode)\n"
        requestLog += "Response Headers: \(request.httpHeaders)\n"
        
        if let data = response?.data {
            requestLog += "Raw Data: \(data)\n"
            requestLog += "JSON Data: \(data.toPrettyPrintedString)"
        }
        
        if let fileURL = response?.fileURL {
            requestLog += "File URL: \(fileURL)\n"
        }
        
        if let error = response?.error {
            requestLog += "Error Reason: \(error.localizedDescription)\n"
        }
        
        logger?.endLogging(requestLog, isError: hasError, file: #file, function: #function, line: #line)
    }
    
    private func endLogging(_ request: Request) {
        endLogging(request, response: Optional<EmptyResponse>.none)
    }
    
    private func millisecondsToRespond(at uuid: UUID) -> Int? {
        guard let duration = duration[uuid] else { return nil }
        defer {
            self.duration[uuid] = nil
        }
        
        return Int(((Date().timeIntervalSince1970 - duration) * 1_000.0).rounded())
    }
}

// MARK: - EventMonitor
extension APIConnectorMonitor: EventMonitor {
    // MARK: Request & Download Start
    public func request(_ request: Request,
                 didResumeTask task: URLSessionTask) {
        startLogging(request)
    }
    
    // MARK: DataRequest
    public func request<Value>(_ request: DataRequest,
                        didParseResponse response: DataResponse<Value, AFError>) {
        endLogging(request, response: response)
    }
    
    public func request(_ request: DataRequest,
                 didParseResponse response: DataResponse<Data?, AFError>) {
        endLogging(request, response: response)
    }
    
    // MARK: DownloadRequest
    public func request(_ request: DownloadRequest,
                 didParseResponse response: DownloadResponse<URL?, AFError>) {
        endLogging(request, response: response)
    }
    
    public func request<Value>(_ request: DownloadRequest,
                        didParseResponse response: DownloadResponse<Value, AFError>) {
        endLogging(request, response: response)
    }
    
    public func request(_ request: Request,
                 didFailToCreateURLRequestWithError error: AFError) {
        endLogging(request)
    }
    
    public func request(_ request: Request,
                 didFailTask task: URLSessionTask,
                 earlyWithError error: AFError) {
        endLogging(request)
    }
    
    public func request(_ request: Request,
                 didFailToAdaptURLRequest initialRequest: URLRequest,
                 withError error: AFError) {
        endLogging(request)
    }
    
    // MARK: Validation
    public func request(_ request: DataRequest,
                 didValidateRequest urlRequest: URLRequest?,
                 response: HTTPURLResponse,
                 data: Data?,
                 withResult result: Request.ValidationResult) {
        if case .failure = result {
            var message = "[API] 🛑 DataRequest Validation 에러 발생.\n"
            message += "URL: \(request)\n"
            message += "데이터: \(data?.toPrettyPrintedString ?? "")"
            
            logger?.validationError(message)
        }
    }
    
    public func request(_ request: DownloadRequest,
                 didValidateRequest urlRequest: URLRequest?,
                 response: HTTPURLResponse,
                 fileURL: URL?,
                 withResult result: Request.ValidationResult) {
        if case .failure = result {
            var message = "[API] 🛑 DownloadRequest Validation 에러 발생.\n"
            message += "URL: \(request)\n"
            message += "파일 경로: \(fileURL?.absoluteURL.absoluteString ?? "")"
            
            logger?.validationError(message)
        }
    }
}

// MARK: - APIConnectorMonitor + APIConnectorLogger
extension APIConnectorMonitor: APIConnectorLogger {
    public func startLogging(_ logMessage: String, isError: Bool, file: String, function: String, line: UInt) {
        logger?.startLogging(logMessage, isError: isError, file: file, function: function, line: line)
    }
    
    public func endLogging(_ logMessage: String, isError: Bool, file: String, function: String, line: UInt) {
        logger?.endLogging(logMessage, isError: isError, file: file, function: function, line: line)
    }
    
    public func validationError(_ errorMessage: String) {
        logger?.validationError(errorMessage)
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

fileprivate extension Alamofire.Request {
    var hasError: Bool {
        return error != nil
    }
    
    var httpMethod: String {
        return request?.httpMethod ?? "N/A"
    }
    
    var httpPath: String {
        return request?.url?.path ?? "N/A"
    }
    
    var httpFullPath: String {
        return request?.url?.absoluteString ?? "N/A"
    }
    
    var httpBody: Data? {
        return request?.httpBody
    }
    
    var statusCode: Int {
        return response?.statusCode ?? 0
    }
    
    var httpHeaders: HTTPHeaders {
        return response?.headers ?? [:]
    }
}

private class EmptyResponse: ResponseTrackable {
    var response: HTTPURLResponse? { nil }
    var error: Error? { nil }
    var data: Data? { nil }
    var fileURL: URL? { nil }
}
