//
//  APIConnector.swift
//
//
//  Created by Joonghoo Im on 2022/05/15.
//

import Foundation

public final class APIConnector {
    private(set) public var session: Session
    
    public var configuration: APIConnectorConfigurable
    public var interceptor: RequestInterceptor
    public var validator: APIConnectorValidator
    
    public var headers: HTTPHeaders = HTTPHeaders()
    
    /// Custom APIClient 설정을 사용하는 Initializer. Configuration, Interceptor, Validator를 모두 커스텀 구현하도록 강제함.
    public init(configuration: APIConnectorConfigurable,
                interceptor: any APIConnectorInterceptor,
                validator: APIConnectorValidator,
                eventLogger: APIConnectorLogger & EventMonitor) {
        configuration.sessionConfiguration.headers = configuration.headers
        configuration.sessionConfiguration.waitsForConnectivity = true
        configuration.sessionConfiguration.urlCache = URLCache(memoryCapacity: configuration.cacheMemCapacity,
                                                               diskCapacity: configuration.cacheDiskCapacity)
        
        // Timeout시 Rx를 통한 Unreached Error로 처리하기 위해 주석 처리
        configuration.sessionConfiguration.timeoutIntervalForRequest = configuration.requestTimeOut
        configuration.sessionConfiguration.timeoutIntervalForResource = configuration.requestTimeOut
        
        self.configuration = configuration
        
        self.interceptor = interceptor
        self.validator = validator
        var eventMonitors = [EventMonitor]()
#if DEBUG
        eventMonitors.append(eventLogger)
#endif
        self.session = Session(configuration: configuration.sessionConfiguration,
                               interceptor: interceptor,
                               eventMonitors: eventMonitors)
    }
    
    /// 기본 APIClient 설정을 사용하는 Initializer
    public convenience init(eventLogger: APIConnectorLogger & EventMonitor) {
        let configuration = APIConnectorConfig()
        let interceptor = APIClientInterceptorImpl()
        let validator = APIConnectorValidatorImpl()
        
        self.init(configuration: configuration, interceptor: interceptor, validator: validator, eventLogger: eventLogger)
    }
}

// MARK: - APIConnector + EmptyParameter
extension APIConnector {
    struct EmptyParameters: Encodable {}
}

// MARK: - Public Functions
extension APIConnector {
    public func cancelAllRequests() {
        session.cancelAllRequests()
    }
    
    /// APIResource에 정의된 Additional Header 값과 APIClient에 정의된 Header값을 머지하는 함수
    func makeRequestHeader(resource: APIResource) -> HTTPHeaders? {
        var headerForRequest: HTTPHeaders?
        
        if let additionalHeaders = resource.additionalHeaders {
            headerForRequest = additionalHeaders
            self.headers.forEach({ header in
                /// AdditionalHeader에 정의되어 있는 Header값 중, APIClient에 존재하는 값은 APIClient에 있는 기본 값을 무시한다.
                guard headerForRequest?.value(for: header.name) == nil else { return }
                headerForRequest?.add(header)
            })
        } else {
            headerForRequest = self.headers
        }
        
        return headerForRequest
    }
}
