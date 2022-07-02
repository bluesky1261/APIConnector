//
//  UnsplashAPIConnectorConcurrencyTests.swift
//  
//
//  Created by Joonghoo Im on 2022/05/29.
//

import XCTest
import Alamofire
@testable import APIConnector

final class UnsplashAPIConnectorConcurrencyTests: XCTestCase {
    let apiConnector = APIConnector.shared
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func test_Concurrency_테스트성공() async throws {
        // Given
        let request = TopicModel.Request(page: 1)
        
        // When
        let response = try await apiConnector.request(resource: UnsplashAPIResouces.topic,
                                                      parameters: request,
                                                      responseModel: [TopicModel.Response].self,
                                                      encoder: .urlEncodedForm)
        
        // Then
        XCTAssertTrue(response.count > 0)
    }
    
    func test_Concurrency_인증에러() async throws {
        // Given
        let request = TopicModel.Request(page: 1)
        
        // When
        // Then
        await XCTAssertThrowsError(try await apiConnector.request(resource: UnsplashAPIResouces.invalidAuthorization,
                                                                  parameters: request,
                                                                  responseModel: [TopicModel.Response].self,
                                                                  encoder: .urlEncodedForm),
                                   "인증 에러 발생",
                                   { error in
            guard let apiConnectorError = error as? APIConnectorError else {
                XCTAssert(false, "APIConnector Error 미발생.")
                return
            }
            
            guard case .unAuthorized = apiConnectorError else {
                XCTAssert(false, "인증 에러가 아닌 다음 에러 발생. 에러: \(apiConnectorError.errorDescription ?? "")")
                return
            }
        })
    }
    
    
    func test_Concurrency_디코딩에러() async throws {
        let request = TopicModel.Request(page: 1)
        
        // When
        // Then
        await XCTAssertThrowsError(try await apiConnector.request(resource: UnsplashAPIResouces.topic,
                                                                  parameters: request,
                                                                  responseModel: [TopicModel.Request].self,
                                                                  encoder: .urlEncodedForm),
                                   "디코딩 에러 발생",
                                   { error in
            guard let apiConnectorError = error as? APIConnectorError else {
                XCTAssert(false, "APIConnector Error 미발생.")
                return
            }
            
            guard case .decode = apiConnectorError else {
                XCTAssert(false, "디코딩 에러가 아닌 다음 에러 발생. 에러: \(apiConnectorError.errorDescription ?? "")")
                return
            }
            
            XCTAssertEqual("Decoding시 키를 찾을 수 없습니다. 키: CodingKeys(stringValue: \"page\", intValue: nil), CodingPath: [_JSONKey(stringValue: \"Index 0\", intValue: 0)], 에러 내용: No value associated with key CodingKeys(stringValue: \"page\", intValue: nil) (\"page\").", apiConnectorError.errorDescription)
        })
    }
    
    func test_Concurrency_인증에러_재처리성공() async throws {
        // Given
        let unsplashInterceptor = UnsplashInterceptor(targetRetryCount: 1)
        let unsplashApiconnector = APIConnector(interceptor: unsplashInterceptor)
    
        let request = TopicModel.Request(page: 1)
        
        // When
        let response = try await unsplashApiconnector.request(resource: UnsplashAPIResouces.invalidAuthorization,
                                                              parameters: request,
                                                              responseModel: [TopicModel.Response].self,
                                                              encoder: .urlEncodedForm)
        // Then
        XCTAssertEqual(unsplashInterceptor.retryCount, 1)
        XCTAssertTrue(response.count > 0)
    }
}
