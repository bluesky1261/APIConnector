//
//  APIConnectorError.swift
//  
//
//  Created by Joonghoo Im on 2022/05/15.
//
import Foundation

// MARK: - APIErrorDecodable
public protocol APIErrorDecodable: Error & Decodable {
    var errorMessage: String? { get }
}

// MARK: - APIConnectorError
public enum APIConnectorError: Error {
    case http(APIErrorDecodable, HTTPURLResponse)
    case decode(Swift.DecodingError?)
    case noData
    case emptyUrl
    case unreached
    case unAuthorized
    case urlResponse(AFError?)
    case initialize
    case canceledByUser
    case noValue
    case unknown(AFError)
}

// MARK: - Extension: LocalizedError
extension APIConnectorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .http(responseError, response):
            return "서버 통신시 에러가 발생하였습니다.\n응답코드: \(response.statusCode)\n메세지: \(responseError.errorMessage ?? "")"
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
        case .emptyUrl:
            return "파일 다운로드 / 업로드시 수신된 Url이 존재하지 않습니다."
        case .unreached:
            return "서버 통신에 실패하였습니다. 네트워크 상태를 확인바랍니다."
        case .unAuthorized:
            return "인증되지 않은 사용자입니다."
        case let .urlResponse(error):
            return "URL Response에서 에러가 발생하였습니다. 메세지: \(error?.localizedDescription ?? "없음.")"
        case .initialize:
            return "통신 초기화시 에러가 발생하였습니다. 요청 정보를 확인해주세요."
        case .canceledByUser:
            return "사용자에 의해 요청이 취소되었습니다."
        case .noValue:
            return "디코딩된 최종 결과 데이터가 존재하지 않습니다."
        case let .unknown(error):
            return "알 수 없는 에러가 발생하였습니다. 메세지: \(error.localizedDescription)"
        }
    }
}
