//
//  APIConnectorValidator.swift
//
//
//  Created by Joonghoo Im on 2023/03/04.
//

import Alamofire
import Foundation

public protocol APIConnectorValidator {
    /// Validate for Request
    func validate<S: Sequence>(retriableStatusCode: S,
                               resource: APIResource,
                               request: URLRequest?,
                               response: HTTPURLResponse,
                               data: Data?) -> DataRequest.ValidationResult where S.Iterator.Element == Int
    /// Validate for Download
    func validate<S: Sequence>(retriableStatusCode: S,
                               resource: APIResource,
                               request: URLRequest?,
                               response: HTTPURLResponse,
                               fileUrl: URL?) -> DataRequest.ValidationResult where S.Iterator.Element == Int
}

// MARK: - APIClientValidatorImpl
final class APIConnectorValidatorImpl: APIConnectorValidator {
    func validate<S: Sequence>(retriableStatusCode: S,
                               resource: APIResource,
                               request: URLRequest?,
                               response: HTTPURLResponse,
                               data: Data?) -> DataRequest.ValidationResult where S.Iterator.Element == Int {
        // 재시도가 필요한 응답 코드일 때
        if retriableStatusCode.contains(response.statusCode) {
            // RequestRetrier가 작동할 수 있게 실패를 반환한다
            let reason: AFError.ResponseValidationFailureReason = .unacceptableStatusCode(code: response.statusCode)
            return .failure(AFError.responseValidationFailed(reason: reason))
        } else {
            return .success(())
        }
    }
    
    func validate<S: Sequence>(retriableStatusCode: S,
                               resource: APIResource,
                               request: URLRequest?,
                               response: HTTPURLResponse,
                               fileUrl: URL?) -> DataRequest.ValidationResult where S.Iterator.Element == Int {
        // 재시도가 필요한 응답 코드일 때
        if retriableStatusCode.contains(response.statusCode) {
            // RequestRetrier가 작동할 수 있게 실패를 반환한다
            let reason: AFError.ResponseValidationFailureReason = .unacceptableStatusCode(code: response.statusCode)
            return .failure(AFError.responseValidationFailed(reason: reason))
        } else {
            return .success(())
        }
    }
}

// MARK: - DataRequest
extension DataRequest {
    func validate<S: Sequence>(retriableStatusCode: S,
                               resource: APIResource,
                               validator: APIConnectorValidator) -> Self where S.Iterator.Element == Int {
        validate { request, response, data in
            validator.validate(retriableStatusCode: retriableStatusCode, resource: resource, request: request, response: response, data: data)
        }
    }
}

// MARK: - DownloadRequest
extension DownloadRequest {
    func validate<S: Sequence>(retriableStatusCode: S,
                               resource: APIResource,
                               validator: APIConnectorValidator) -> Self where S.Iterator.Element == Int {
        validate { request, response, fileUrl in
            validator.validate(retriableStatusCode: retriableStatusCode, resource: resource, request: request, response: response, fileUrl: fileUrl)
        }
    }
}
