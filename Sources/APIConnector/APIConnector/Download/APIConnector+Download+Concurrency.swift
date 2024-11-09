//
//  APIConnector+Download+Concurrency.swift
//  
//
//  Created by Joonghoo Im on 2022/07/02.
//

/*
extension APIConnector {
    func download<Parameters>(resource: any APIResource,
                              parameters: Parameters,
                              encoder: ParameterEncoder = JSONParameterEncoder.default) async throws -> URL where Parameters: Encodable {
        
        
        let fullURL = resource.baseURL.appendingPathComponent(resource.endpoint)
        
        return session.download(fullURL,
                                method: resource.httpMethod,
                                parameters: parameters,
                                encoder: encoder,
                                headers: headers)
          .validate(retriableStatusCode: (401...401))
          .serializingDownloadedFileURL()
        
    }
}
*/
/*
 //
 //  APIClient+Download+Concurrency.swift
 //  t1-traveler-iOS
 //
 //  Created by chorim.i on 2022/02/28.
 //  Copyright © 2022 Kakao Insurance Corp. All rights reserved.
 //

 import Alamofire

 // MARK: - Download + Concurrency
 extension APIClient {
   func download<Parameters>(resource: APIResource,
                             parameters: Parameters,
                             encoder: ParameterEncoder = JSONParameterEncoder.default) async throws -> URL where Parameters: Encodable {
     return try await serializing(resource: resource,
                                  parameters: parameters,
                                  encoder: encoder)
       .value(resource, statusCode: validStatusCode)
   }
   
   func download(resource: APIResource,
                 encoder: ParameterEncoder = JSONParameterEncoder.default) async throws -> URL {
     let parameters = resource.httpMethod == .get ? nil : EmptyParameters()
     return try await serializing(resource: resource,
                                  parameters: parameters,
                                  encoder: encoder)
       .value(resource, statusCode: validStatusCode)
   }
 }

 // MARK: serializingDownload
 extension APIClient {
   fileprivate func serializing<Parameters>(resource: APIResource,
                                            parameters: Parameters?,
                                            encoder: ParameterEncoder = JSONParameterEncoder.default) -> DownloadTask<URL> where Parameters: Encodable {
     let fullURL = resource.baseURL.appendingPathComponent(resource.endpoint)
     
     return session.download(fullURL,
                             method: resource.httpMethod,
                             parameters: parameters,
                             encoder: encoder,
                             headers: headers)
       .validate(retriableStatusCode: (401...401))
       .serializingDownloadedFileURL()
   }
 }

 */
