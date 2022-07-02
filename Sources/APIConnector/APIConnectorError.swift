//
//  APIConnectorError.swift
//  
//
//  Created by Joonghoo Im on 2022/05/15.
//

import Alamofire
import Foundation

// MARK: - APIConnectorErrorDecodable
public protocol APIConnectorErrorDecodable: Error & Decodable {
    var errorMessage: String? { get }
}

// MARK: - APIConnectorError
public enum APIConnectorError: Error {
    case http(APIConnectorErrorDecodable, HTTPURLResponse)
    case decode(Swift.DecodingError?)
    case noData
    case noResponse
    case unAuthorized
    case timeout
    case unknown(AFError? = nil)
}

// MARK: - Extension: LocalizedError
extension APIConnectorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .http(errorDecodable, response):
            return "서버 통신시 에러가 발생하였습니다.\n응답코드: \(response.statusCode)\n메세지: \(errorDecodable.errorMessage ?? "")"
        case let .decode(decodingError):
            switch decodingError {
            case let .typeMismatch(type, context):
                return "Decoding시 타입 에러가 발생하였습니다. 타입: \(type), CodingPath: \(context.codingPath), 에러 내용: \(context.debugDescription)"
            case let .valueNotFound(value, context):
                return "Decoding시 값을 찾을 수 없습니다. 값: \(value), CodingPath: \(context.codingPath), 에러 내용: \(context.debugDescription)"
            case let .keyNotFound(key, context):
                return "Decoding시 키를 찾을 수 없습니다. 키: \(key), CodingPath: \(context.codingPath), 에러 내용: \(context.debugDescription)"
            case let .dataCorrupted(context):
                return "Decoding 데이터가 손상되었습니다. CodingPath: \(context.codingPath), 에러 내용: \(context.debugDescription)"
            default:
                return "Decoding 에러가 발생하였습니다."
            }
        case .noData:
            return "서버에서 전송된 데이터가 없습니다."
        case .noResponse:
            return "서버 응답 데이터가 존재하지 않습니다."
        case .unAuthorized:
            return "서버 데이터 접근 권한이 부족합니다."
        case .timeout:
            return "서버 통신시 Timeout이 발생하였습니다. 네트워크 상태를 확인바랍니다."
        case let .unknown(error):
            return "알 수 없는 에러 발생. 메세지: \(error?.localizedDescription ?? "")"
        }
    }
}
