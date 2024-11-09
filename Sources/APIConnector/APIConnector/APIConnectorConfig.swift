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
final class APIConnectorConfig: APIConnectorConfigurable {
    var sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
    
    let validStatusCode: Range<Int> = 200..<400
    let retriableStatusCode: Range<Int> = 401..<402
    
    let requestTimeOut: TimeInterval = 10
    let cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
    let cacheMemCapacity = 100_000_000
    let cacheDiskCapacity = 100_000_000
    
    let headers: HTTPHeaders = [.defaultAcceptEncoding,
                                .defaultAcceptLanguage,
                                .defaultUserAgent]
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
