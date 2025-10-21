//
//  APIConnectorConfig.swift
//  
//
//  Created by Joonghoo Im on 2023/03/04.
//
import Foundation

public protocol APIConnectorConfigurable {
    /// URLSessionConfiguration
    var sessionConfiguration: URLSessionConfiguration { get }
    
    /// 유효한 Status Code 범위
    var validStatusCode: Range<Int> { get }
    /// 재처리 시도 Status Code 범위
    var retriableStatusCode: Range<Int> { get }
    
    /// Request Timeout
    var requestTimeOut: TimeInterval { get }
    /// Request Cache Policy
    var cachePolicy: URLRequest.CachePolicy { get }
    /// Cache Memory 용량
    var cacheMemCapacity: Int { get }
    /// Cache Disk 용량
    var cacheDiskCapacity: Int { get }
    /// URLSessionConfiguration에 사용될 헤더
    var headers: HTTPHeaders { get }
}

// MARK: AppNetworkConfig - 실제 Network 설정
public final class APIConnectorConfig: APIConnectorConfigurable {
    public var sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
    
    public var validStatusCode: Range<Int>
    public var retriableStatusCode: Range<Int>
    
    public var requestTimeOut: TimeInterval
    public var cachePolicy: URLRequest.CachePolicy
    public var cacheMemCapacity: Int
    public var cacheDiskCapacity: Int
    
    public var headers: HTTPHeaders
    
    public init(
        sessionConfiguration: URLSessionConfiguration = .default,
        validStatusCode: Range<Int> = 200..<400,
        retriableStatusCode: Range<Int> = 401..<402,
        requestTimeOut: TimeInterval = 10,
        cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad,
        cacheMemCapacity: Int = 100_000_000,
        cacheDiskCapacity: Int = 100_000_000,
        headers: HTTPHeaders = [.defaultAcceptEncoding, .defaultAcceptLanguage, .defaultUserAgent]
    ) {
        self.sessionConfiguration = sessionConfiguration
        self.validStatusCode = validStatusCode
        self.retriableStatusCode = retriableStatusCode
        self.requestTimeOut = requestTimeOut
        self.cachePolicy = cachePolicy
        self.cacheMemCapacity = cacheMemCapacity
        self.cacheDiskCapacity = cacheDiskCapacity
        self.headers = headers
    }
}

// MARK: - Fluent Builder (체이닝)
public extension APIConnectorConfig {
    @discardableResult
    func withSessionConfiguration(_ config: URLSessionConfiguration) -> Self {
        self.sessionConfiguration = config
        return self
    }

    @discardableResult
    func withValidStatusCode(_ range: Range<Int>) -> Self {
        self.validStatusCode = range
        return self
    }

    @discardableResult
    func withRetriableStatusCode(_ range: Range<Int>) -> Self {
        self.retriableStatusCode = range
        return self
    }

    @discardableResult
    func withTimeout(_ seconds: TimeInterval) -> Self {
        self.requestTimeOut = seconds
        return self
    }

    @discardableResult
    func withCachePolicy(_ policy: URLRequest.CachePolicy) -> Self {
        self.cachePolicy = policy
        return self
    }

    @discardableResult
    func withCache(memory: Int? = nil, disk: Int? = nil) -> Self {
        if let memory { self.cacheMemCapacity = memory }
        if let disk { self.cacheDiskCapacity = disk }
        return self
    }

    @discardableResult
    func withHeaders(_ headers: HTTPHeaders) -> Self {
        self.headers = headers
        return self
    }

    /// Header 추가(같은 키가 있으면 교체)
    @discardableResult
    func addHeader(name: String, value: String) -> Self {
        var h = self.headers
        if h.value(for: name) != nil {
            h.update(name: name, value: value)
        } else {
            h.add(name: name, value: value)
        }
        self.headers = h
        return self
    }
}

// MARK: StubAPIConnectorConfig - 테스트용 Network 설정
/*
final class StubAPIConnectorConfig: APIConnectorConfigurable {
    var sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
    
    let validStatusCode: Range<Int> = 200..<400
    let retriableStatusCode: Range<Int> = 401..<402
    
    let requestTimeOut: TimeInterval = 30
    let cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
    let cacheMemCapacity = 100_000_000
    let cacheDiskCapacity = 100_000_000
}
*/
