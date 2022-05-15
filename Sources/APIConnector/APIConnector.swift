import Foundation
import Alamofire

public struct APIConnector {
    private let configuration: URLSessionConfiguration
    private(set) var validStatusCode: Range<Int> = 200..<400
    
    public private(set) var session: Session
    public static let shared: APIConnector = APIConnector()

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
    
    public func cancelAllRequests() {
        session.cancelAllRequests()
    }
}
