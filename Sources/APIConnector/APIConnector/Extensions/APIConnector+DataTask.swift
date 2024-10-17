//
//  APIConnector+DataTask.swift
//  
//
//  Created by Joonghoo Im on 2023/03/04.
//

import Alamofire
import Foundation

extension DataTask {
    func value(_ resource: APIResource,
               statusCode: Range<Int>) async throws -> Value {
        let dataResponse = await response
        
        if let error = dataResponse.error {
            if error.isSessionTaskError,
               case .sessionTaskFailed(let sessionError) = error,
               (sessionError as NSError).code == NSURLErrorTimedOut {
                throw APIConnectorError.unreached
            } else if error.isResponseValidationError {
                throw APIConnectorError.unAuthorized
            } else if error.isExplicitlyCancelledError {
                throw APIConnectorError.canceledByUser
            }
        }
        
        // HTTPURLResponse 검증
        guard let urlResponse = dataResponse.response else {
            if let error = dataResponse.error {
                throw APIConnectorError.urlResponse(error)
            } else {
                throw APIConnectorError.urlResponse(nil)
            }
        }
        
        /// HTTP Status 유효한 상태 코드 에러 처리
        guard statusCode.contains(urlResponse.statusCode) else {
            var errorDecodable: APIErrorDecodable?
            
            /// 데이터 검증 - HTTP Code가 정상 응답이 아닌 경우만 체크. 정상인 경우에 응답값이 없을 수 있기 때문
            guard let data = dataResponse.data else { throw APIConnectorError.noData }
            
            /// 에러 메세지 디코딩
            do {
                errorDecodable = try resource.decodeError(data: data)
            } catch let error {
                if let decodingError = error as? Swift.DecodingError {
                    throw APIConnectorError.decode(decodingError)
                } else {
                    throw APIConnectorError.decode(nil)
                }
            }
            
            guard let errorDecodable = errorDecodable else {
                throw APIConnectorError.decode(nil)
            }
            throw APIConnectorError.http(errorDecodable, urlResponse)
        }
        
        /// HTTP 응답 정상 - 데이터 디코딩 에러 처리
        if let error = dataResponse.error,
           case let AFError.responseSerializationFailed(reason: reason) = error,
           case let AFError.ResponseSerializationFailureReason.decodingFailed(error: decodingFailedError) = reason,
           let decodingError = decodingFailedError as? Swift.DecodingError {
            throw APIConnectorError.decode(decodingError)
        } else {
            do {
                return try await value
            } catch {
                throw APIConnectorError.noValue
            }
        }
    }
}
