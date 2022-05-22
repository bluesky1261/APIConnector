//
//  APIConnector+DataTask.swift
//  
//
//  Created by Joonghoo Im on 2022/05/22.
//

import Foundation
import Alamofire

// MARK: - DataTask
extension DataTask {
    func value<Resource>(resource: Resource, statusCode: Range<Int> = (200..<400)) async throws -> Value where Resource: APIResource {
        let response = await self.response
        
        if let error = response.error {
            if error.isSessionTaskError, (error as NSError).code == NSURLErrorTimedOut {
                throw APIConnectorError.timeout
            } else if error.isResponseSerializationError {
                throw APIConnectorError.decode(error)
            } else if error.isResponseValidationError {
                throw APIConnectorError.unAuthorized
            }
        }
        
        guard let urlResponse = response.response else {
            throw APIConnectorError.noResponse
        }
        
        guard let data = response.data else {
            throw APIConnectorError.noData
        }
        
        guard statusCode.contains(urlResponse.statusCode) else {
            var decodedError: APIConnectorErrorDecodable?
            do {
                decodedError = try resource.decodeError(data: data)
            } catch let error {
                throw APIConnectorError.decode(error)
            }
            
            guard let decodedError = decodedError else {
                throw APIConnectorError.unknown()
            }
            throw APIConnectorError.http(decodedError, urlResponse)
        }
        
        return try await value
    }
}

/*
 public struct DataTask<Value> {
     /// `DataResponse` produced by the `DataRequest` and its response handler.
     public var response: DataResponse<Value, AFError> {
         get async {
             if shouldAutomaticallyCancel {
                 return await withTaskCancellationHandler {
                     self.cancel()
                 } operation: {
                     await task.value
                 }
             } else {
                 return await task.value
             }
         }
     }

     /// `Result` of any response serialization performed for the `response`.
     public var result: Result<Value, AFError> {
         get async { await response.result }
     }

     /// `Value` returned by the `response`.
     public var value: Value {
         get async throws {
             try await result.get()
         }
     }

     private let request: DataRequest
     private let task: Task<DataResponse<Value, AFError>, Never>
     private let shouldAutomaticallyCancel: Bool

     fileprivate init(request: DataRequest, task: Task<DataResponse<Value, AFError>, Never>, shouldAutomaticallyCancel: Bool) {
         self.request = request
         self.task = task
         self.shouldAutomaticallyCancel = shouldAutomaticallyCancel
     }

     /// Cancel the underlying `DataRequest` and `Task`.
     public func cancel() {
         task.cancel()
     }

     /// Resume the underlying `DataRequest`.
     public func resume() {
         request.resume()
     }

     /// Suspend the underlying `DataRequest`.
     public func suspend() {
         request.suspend()
     }
 }

 @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
 extension DataRequest {
     /// Creates a `DataTask` to `await` a `Data` value.
     ///
     /// - Parameters:
     ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
     ///                                enclosing async context is cancelled. Only applies to `DataTask`'s async
     ///                                properties. `false` by default.
     ///   - dataPreprocessor:          `DataPreprocessor` which processes the received `Data` before completion.
     ///   - emptyResponseCodes:        HTTP response codes for which empty responses are allowed. `[204, 205]` by default.
     ///   - emptyRequestMethods:       `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
     ///
     /// - Returns: The `DataTask`.
     public func serializingData(automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
                                 dataPreprocessor: DataPreprocessor = DataResponseSerializer.defaultDataPreprocessor,
                                 emptyResponseCodes: Set<Int> = DataResponseSerializer.defaultEmptyResponseCodes,
                                 emptyRequestMethods: Set<HTTPMethod> = DataResponseSerializer.defaultEmptyRequestMethods) -> DataTask<Data> {
         serializingResponse(using: DataResponseSerializer(dataPreprocessor: dataPreprocessor,
                                                           emptyResponseCodes: emptyResponseCodes,
                                                           emptyRequestMethods: emptyRequestMethods),
                             automaticallyCancelling: shouldAutomaticallyCancel)
     }

     /// Creates a `DataTask` to `await` serialization of a `Decodable` value.
     ///
     /// - Parameters:
     ///   - type:                      `Decodable` type to decode from response data.
     ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
     ///                                enclosing async context is cancelled. Only applies to `DataTask`'s async
     ///                                properties. `false` by default.
     ///   - dataPreprocessor:          `DataPreprocessor` which processes the received `Data` before calling the serializer.
     ///                                `PassthroughPreprocessor()` by default.
     ///   - decoder:                   `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
     ///   - emptyResponseCodes:        HTTP status codes for which empty responses are always valid. `[204, 205]` by default.
     ///   - emptyRequestMethods:       `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
     ///
     /// - Returns: The `DataTask`.
     public func serializingDecodable<Value: Decodable>(_ type: Value.Type = Value.self,
                                                        automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
                                                        dataPreprocessor: DataPreprocessor = DecodableResponseSerializer<Value>.defaultDataPreprocessor,
                                                        decoder: DataDecoder = JSONDecoder(),
                                                        emptyResponseCodes: Set<Int> = DecodableResponseSerializer<Value>.defaultEmptyResponseCodes,
                                                        emptyRequestMethods: Set<HTTPMethod> = DecodableResponseSerializer<Value>.defaultEmptyRequestMethods) -> DataTask<Value> {
         serializingResponse(using: DecodableResponseSerializer<Value>(dataPreprocessor: dataPreprocessor,
                                                                       decoder: decoder,
                                                                       emptyResponseCodes: emptyResponseCodes,
                                                                       emptyRequestMethods: emptyRequestMethods),
                             automaticallyCancelling: shouldAutomaticallyCancel)
     }

     /// Creates a `DataTask` to `await` serialization of a `String` value.
     ///
     /// - Parameters:
     ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
     ///                                enclosing async context is cancelled. Only applies to `DataTask`'s async
     ///                                properties. `false` by default.
     ///   - dataPreprocessor:          `DataPreprocessor` which processes the received `Data` before calling the serializer.
     ///                                `PassthroughPreprocessor()` by default.
     ///   - encoding:                  `String.Encoding` to use during serialization. Defaults to `nil`, in which case
     ///                                the encoding will be determined from the server response, falling back to the
     ///                                default HTTP character set, `ISO-8859-1`.
     ///   - emptyResponseCodes:        HTTP status codes for which empty responses are always valid. `[204, 205]` by default.
     ///   - emptyRequestMethods:       `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
     ///
     /// - Returns: The `DataTask`.
     public func serializingString(automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
                                   dataPreprocessor: DataPreprocessor = StringResponseSerializer.defaultDataPreprocessor,
                                   encoding: String.Encoding? = nil,
                                   emptyResponseCodes: Set<Int> = StringResponseSerializer.defaultEmptyResponseCodes,
                                   emptyRequestMethods: Set<HTTPMethod> = StringResponseSerializer.defaultEmptyRequestMethods) -> DataTask<String> {
         serializingResponse(using: StringResponseSerializer(dataPreprocessor: dataPreprocessor,
                                                             encoding: encoding,
                                                             emptyResponseCodes: emptyResponseCodes,
                                                             emptyRequestMethods: emptyRequestMethods),
                             automaticallyCancelling: shouldAutomaticallyCancel)
     }

     /// Creates a `DataTask` to `await` serialization using the provided `ResponseSerializer` instance.
     ///
     /// - Parameters:
     ///   - serializer:                `ResponseSerializer` responsible for serializing the request, response, and data.
     ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
     ///                                enclosing async context is cancelled. Only applies to `DataTask`'s async
     ///                                properties. `false` by default.
     ///
     /// - Returns: The `DataTask`.
     public func serializingResponse<Serializer: ResponseSerializer>(using serializer: Serializer,
                                                                     automaticallyCancelling shouldAutomaticallyCancel: Bool = false)
         -> DataTask<Serializer.SerializedObject> {
         dataTask(automaticallyCancelling: shouldAutomaticallyCancel) {
             self.response(queue: .singleEventQueue,
                           responseSerializer: serializer,
                           completionHandler: $0)
         }
     }

     /// Creates a `DataTask` to `await` serialization using the provided `DataResponseSerializerProtocol` instance.
     ///
     /// - Parameters:
     ///   - serializer:                `DataResponseSerializerProtocol` responsible for serializing the request,
     ///                                response, and data.
     ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
     ///                                enclosing async context is cancelled. Only applies to `DataTask`'s async
     ///                                properties. `false` by default.
     ///
     /// - Returns: The `DataTask`.
     public func serializingResponse<Serializer: DataResponseSerializerProtocol>(using serializer: Serializer,
                                                                                 automaticallyCancelling shouldAutomaticallyCancel: Bool = false)
         -> DataTask<Serializer.SerializedObject> {
         dataTask(automaticallyCancelling: shouldAutomaticallyCancel) {
             self.response(queue: .singleEventQueue,
                           responseSerializer: serializer,
                           completionHandler: $0)
         }
     }

     private func dataTask<Value>(automaticallyCancelling shouldAutomaticallyCancel: Bool,
                                  forResponse onResponse: @escaping (@escaping (DataResponse<Value, AFError>) -> Void) -> Void)
         -> DataTask<Value> {
         let task = Task {
             await withTaskCancellationHandler {
                 self.cancel()
             } operation: {
                 await withCheckedContinuation { continuation in
                     onResponse {
                         continuation.resume(returning: $0)
                     }
                 }
             }
         }

         return DataTask<Value>(request: self, task: task, shouldAutomaticallyCancel: shouldAutomaticallyCancel)
     }
 */
