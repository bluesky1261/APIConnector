import Foundation
import Alamofire

public struct APIConnector {
    private let configuration: URLSessionConfiguration
    private(set) var validStatusCode: Range<Int> = 200..<400
    
    // MARK: - Public Variables
    public private(set) var session: Session
    public static let shared: APIConnector = APIConnector()

    /// APIConnector Initializer
    public init(configuration: URLSessionConfiguration? = nil) {
        if let configuration = configuration {
            self.configuration = configuration
            self.session = Session(configuration: configuration)
        } else {
            self.configuration = URLSessionConfiguration.default
            self.configuration.headers = [
                .defaultAcceptEncoding,
                .defaultAcceptLanguage,
                .defaultUserAgent
            ]
            
            self.session = Session(configuration: self.configuration)
        }
    }
    
    /// Cancel All Requests
    public func cancelAllRequests() {
        session.cancelAllRequests()
    }
}
