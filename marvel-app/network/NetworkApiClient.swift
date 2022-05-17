//
//  NetworkApiClient.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 16/05/2022.
//

import Alamofire
import RxSwift
import CryptoKit

class NetworkApiClient {

    private let manager: Session

    required init(manager: Session = Session.default) {
        self.manager = manager
    }

    public func call<TEntity>() -> Observable<TEntity> where TEntity: Codable {
        let request = createHttpRequest()

        return Observable.create({ observer -> Disposable in

            self.manager.request(request).validate()
                .responseData( completionHandler: { [weak self] response in
                    switch response.result {
                    case .success:
                        if let data = response.data, let result: TEntity = self?.decode(data: data) {
                            observer.onNext(result)
                            observer.onCompleted()
                        } else {
//                            observer.onError(ErrorResult(type: .failure))
                        }
                    case .failure:
                        print("handleFailure")
                        // handleFailure(observer, response: response)
                    }
                })

            return Disposables.create()
        }).share()
    }

    private func decode<TEntity>(data: Data) -> TEntity? where TEntity: Codable {
        do {
           return try JSONDecoder().decode(TEntity.self, from: data)
        } catch let error {
            print(error)
        }
        return try? JSONDecoder().decode(TEntity.self, from: data)
    }

    private func createHttpRequest() -> URLRequest {
//        let dict: KeyDict = self.getKeys()
        let ts = "thesoer"
        let hash = md5Hash(string: "\(ts)\("2e8b0747968ca3fb4c2fd43c072de5606bc77f5c")\("6df01e61332aced9ac1cb6ff8fba713e")")


        let queryItems = [URLQueryItem(name: "apikey", value: "6df01e61332aced9ac1cb6ff8fba713e"),
                          URLQueryItem(name: "hash", value: "\(hash)"),
                          URLQueryItem(name: "ts", value: "\(ts)")]

        var urlComps = URLComponents(string: "http://gateway.marvel.com/v1/public/characters")!

        urlComps.queryItems = queryItems

        let url = (urlComps.url!)
        let request = URLRequest(url: url)
        return request
    }

    func md5Hash(string: String) -> String {
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }

}
