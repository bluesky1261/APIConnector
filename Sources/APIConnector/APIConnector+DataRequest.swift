//
//  APIConnector+Request.swift
//  
//
//  Created by Joonghoo Im on 2022/05/15.
//

import Foundation
import Alamofire

extension DataRequest {
    public func validate<S>(retriableStatusCode: S) -> Self
    where S: Sequence, S.Iterator.Element == Int {
        validate { [unowned self] _, response, _ in
            self.validate(retriableStatusCode: retriableStatusCode, response: response)
        }
    }
}

// MARK: - Fileprivate Extension
fileprivate extension DataRequest {
    func validate<S>(retriableStatusCode: S,
                                 response: HTTPURLResponse) -> ValidationResult
    where S: Sequence, S.Iterator.Element == Int {
        if retriableStatusCode.contains(response.statusCode) {
            return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode)))
        } else {
            return .success(())
        }
    }
}
