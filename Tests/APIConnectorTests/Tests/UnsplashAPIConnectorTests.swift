import XCTest
@testable import APIConnector

final class UnsplashAPIConnectorTests: XCTestCase {
    let apiConnector = APIConnector.shared
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testTopicService() async throws {
        // Given
        let request = TopicModel.Request(page: 1)
        
        // When
        let response = try await apiConnector.request(resource: UnsplashAPIResouces.topic, parameters: request, responseModel: [TopicModel.Response].self)
        
        print("testTopicService Response: \(response)")
        
        // Then
        XCTAssertTrue(response.count > 0)
    }
}
