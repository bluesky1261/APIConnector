import XCTest
import Alamofire
@testable import APIConnector

final class UnsplashAPIConnectorTests: XCTestCase {
    let apiConnector = APIConnector.shared
    let clientID = "hb2G6bTs1Jr0gChHCR6-HOUnQt-58aNqZo4wD4mXQVw"
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func test_테스트성공() async throws {
        // Given
        let request = TopicModel.Request(page: 1)
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Client-ID ".appending(clientID))
        
        // When
        let response = try await apiConnector.request(resource: UnsplashAPIResouces.topic,
                                                      parameters: request,
                                                      responseModel: [TopicModel.Response].self,
                                                      encoder: .urlEncodedForm,
                                                      additionalHeader: headers)
        
        // Then
        XCTAssertTrue(response.count > 0)
    }
    
    func test_인증에러() async throws {
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
            guard let apiClientError = error as? APIConnectorError else {
                XCTAssert(false, "APIConnector Error 미발생.")
                return
            }
            
            guard case .unAuthorized = apiClientError else {
                XCTAssert(false, "인증 에러가가 아닌 다음 에러 발생. 에러: \(apiClientError.errorDescription ?? "")")
                return
            }
        })
    }
    
    
    func test_디코딩에러() async throws {
        let request = TopicModel.Request(page: 1)
        
        // When
        // Then
        await XCTAssertThrowsError(try await apiConnector.request(resource: UnsplashAPIResouces.topic,
                                                                  parameters: request,
                                                                  responseModel: [TopicModel.Request].self,
                                                                  encoder: .urlEncodedForm),
                                   "디코딩 에러 발생",
                                   { error in
            guard let apiClientError = error as? APIConnectorError else {
                XCTAssert(false, "APIConnector Error 미발생.")
                return
            }
            
            guard case .decode = apiClientError else {
                XCTAssert(false, "디코딩 에러가 아닌 다음 에러 발생, 에러: \(apiClientError.errorDescription ?? "")")
                return
            }
        })
    }
}
