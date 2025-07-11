//
//  APIConnector+Download.swift
//  
//
//  Created by Joonghoo Im on 2022/07/02.
//

/*
 //
 //  APIClient+Download.swift
 //  t1-traveler-iOS
 //
 //  Created by chorim.i on 2022/02/28.
 //  Copyright © 2022 Kakao Insurance Corp. All rights reserved.
 //

 import Alamofire
 import RxSwift

 // MARK: - Download + Rx
 extension APIClient {
   func download<Parameters>(resource: APIResource,
                             parameters: Parameters,
                             encoder: ParameterEncoder = JSONParameterEncoder.default) -> Observable<URL> where Parameters: Encodable {
     let fullURL = resource.baseURL.appendingPathComponent(resource.endpoint)
     
     return Observable.create { observable in
       let request = self.session.download(fullURL,
                                           method: resource.httpMethod,
                                           parameters: parameters,
                                           encoder: encoder,
                                           headers: self.headers)
         .validate(retriableStatusCode: (401...401))
         .responseURL(completionHandler: self.factory(resource, observable: observable))

       return Disposables.create {
         request.cancel()
       }
     }
   }
   
   func download(resource: APIResource,
                 encoder: ParameterEncoder = JSONParameterEncoder.default) -> Observable<URL> {
     let fullURL = resource.baseURL.appendingPathComponent(resource.endpoint)
     let parameters = resource.httpMethod == .get ? nil : EmptyParameters()

     return Observable.create { observable in
       let request = self.session.download(fullURL,
                                           method: resource.httpMethod,
                                           parameters: parameters,
                                           encoder: encoder,
                                           headers: self.headers)
         .validate(retriableStatusCode: (401...401))
         .responseURL(completionHandler: self.factory(resource, observable: observable))
       
       return Disposables.create {
         request.cancel()
       }
     }
   }
 }

 // MARK: Download Handler Factory
 extension APIClient {
   fileprivate typealias AFDownloadResponseHandler = (AFDownloadResponse<URL>) -> Void
   fileprivate func factory(_ resource: APIResource,
                            observable: AnyObserver<URL>) -> AFDownloadResponseHandler {
     let completionHandler: (AFDownloadResponseHandler) = { dataResponse in
       guard let urlResponse = dataResponse.response else {
         if let error = dataResponse.error {
           if error.isSessionTaskError, case .sessionTaskFailed(let error) = error, (error as NSError).code == NSURLErrorTimedOut {
             observable.onError(APIClientError.unreached)
           } else {
             observable.onError(APIClientError.unknown(error))
           }
         } else {
           // 에러가 났는데 에러가 없을 수 있나?
           // 그래도 혹시 모르니 초기화 에러로 던진다
           Logger.error("🚨 HTTPURLResponse 생성 실패 🚨\n\(dataResponse)")
           observable.onError(APIClientError.initialize)
         }
         return
       }
       
       guard let fileURL = dataResponse.fileURL else {
         observable.onError(APIClientError.noData)
         return
       }
       
       guard self.validStatusCode.contains(urlResponse.statusCode) else {
         // 유효한 상태 코드 값이 아니라면
         // 에러 메세지(서버) 디코딩 후 에러 반환한다
         do {
           let data = try Data(contentsOf: fileURL)
           let error = try resource.decodeError(data: data)
           observable.onError(APIClientError.http((error, urlResponse)))
         } catch let error {
           observable.onError(APIClientError.decode(error))
         }
         return
       }
       
       switch dataResponse.result {
       case .success(let value):
         observable.onNext(value)
         observable.onCompleted()
         
       case .failure(let error):
         observable.onError(APIClientError.unknown(error))
       }
     }
     return completionHandler
   }
 }

 */
