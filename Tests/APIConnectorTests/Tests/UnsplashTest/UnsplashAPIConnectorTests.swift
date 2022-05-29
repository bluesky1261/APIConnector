import XCTest
import Alamofire
@testable import APIConnector

final class UnsplashAPIConnectorTests: XCTestCase {
    let apiConnector = APIConnector.shared
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func test_테스트성공() {
        // Given
        let request = TopicModel.Request(page: 1)
        var response: [TopicModel.Response] = [TopicModel.Response]()
        
        // When
        let expectation = expectation(description: "request")
        apiConnector.request(resource: UnsplashAPIResouces.topic,
                             parameters: request,
                             responseModel: [TopicModel.Response].self,
                             encoder: .urlEncodedForm,
                             completion: { result in
            switch result {
            case .success(let data):
                response = data
            case .failure(_):
                ()
            }
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5)
        // Then
        XCTAssertTrue(response.count > 0)
    }

    func test_인증에러() {
        // Given
        let request = TopicModel.Request(page: 1)
        var authError: Error?
        
        // When
        let expectation = expectation(description: "request")
        apiConnector.request(resource: UnsplashAPIResouces.invalidAuthorization,
                             parameters: request,
                             responseModel: [TopicModel.Response].self,
                             encoder: .urlEncodedForm,
                             completion: { result in
            switch result {
            case .success(_):
                ()
            case .failure(let error):
                authError = error
            }
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5)
        
        // Then
        guard let apiConncetorAuthError = authError as? APIConnectorError else {
            XCTAssert(false, "APIConnector Error 미발생.")
            return
        }
        
        guard case .unAuthorized = apiConncetorAuthError else {
            XCTAssert(false, "인증 에러가 아닌 다음 에러 발생. 에러: \(apiConncetorAuthError.errorDescription ?? "")")
            return
        }
    }
    
    func test_디코딩에러() {
        // Given
        let request = TopicModel.Request(page: 1)
        var decodeError: Error?
        
        // When
        let expectation = expectation(description: "request")
        apiConnector.request(resource: UnsplashAPIResouces.topic,
                             parameters: request,
                             responseModel: [TopicModel.Request].self,
                             encoder: .urlEncodedForm,
                             completion: { result in
            switch result {
            case .success(_):
                ()
            case .failure(let error):
                decodeError = error
            }
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5)
        
        // Then
        guard let apiConncetorDecodeError = decodeError as? APIConnectorError else {
            XCTAssert(false, "APIConnector Error 미발생.")
            return
        }
        
        guard case .decode = apiConncetorDecodeError else {
            XCTAssert(false, "디코딩 에러가 아닌 다음 에러 발생. 에러: \(apiConncetorDecodeError.errorDescription ?? "")")
            return
        }
    }
    
    func test_인증에러_재처리성공() {
        // Given
        let unsplashInterceptor = UnsplashInterceptor(targetRetryCount: 1)
        let unsplashApiconnector = APIConnector(interceptor: unsplashInterceptor)
    
        let request = TopicModel.Request(page: 1)
        var response: [TopicModel.Response] = [TopicModel.Response]()
        
        // When
        let expectation = expectation(description: "request")
        unsplashApiconnector.request(resource: UnsplashAPIResouces.invalidAuthorization,
                                     parameters: request,
                                     responseModel: [TopicModel.Response].self,
                                     encoder: .urlEncodedForm,
                                     completion: { result in
            switch result {
            case .success(let data):
                response = data
            case .failure(_):
                ()
            }
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5)
        
        // Then        
        XCTAssertEqual(unsplashInterceptor.retryCount, 1)
        XCTAssertTrue(response.count > 0)
    }
}
