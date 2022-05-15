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
enum APIConnectorError: Error {
    case http((APIConnectorErrorDecodable, HTTPURLResponse))
    case decode(Error)
    case noData
    case unreached
    case initialize
    case unknown(AFError)
}

// MARK: - Extension: LocalizedError
extension APIConnectorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .http((errorDecodable, response)):
            return "서버 통신시 에러가 발생하였습니다.\n응답코드: \(response.statusCode)\n메세지: \(errorDecodable.errorMessage ?? "")"
        case let .decode(error):
            return "Decoding 에러가 발생했습니다. 메세지: \(error.localizedDescription)"
        case .noData:
            return "서버에서 전송된 데이터가 없습니다."
        case .unreached:
            return "서버 통신에 실패하였습니다. 네트워크 상태를 확인바랍니다."
        case .initialize:
            return "통신 초기화시 에러가 발생하였습니다. 요청 정보를 확인해주세요."
        case let .unknown(error):
            return "알 수 없는 에러 발생. 메세지: \(error.localizedDescription)"
        }
    }
}
