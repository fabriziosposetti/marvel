//
//  NetworkApiClient.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 16/05/2022.
//

import Alamofire
import RxSwift

class NetworkApiClient {

    // MARK: Private
    private let manager: Session

    required init(manager: Session = Session.default) {
        self.manager = manager
    }

    public func call<TEntity>(config: NetworkApiClientConfig) -> Observable<TEntity> where TEntity: Codable {
        let request = createHttpRequest(config: config)

        return Observable.create({ observer -> Disposable in
            self.manager.request(request).validate()
                .responseData( completionHandler: { [weak self] response in
                    switch response.result {
                    case .success:
                        if let data = response.data, let result: TEntity = self?.decode(data: data) {
                            observer.onNext(result)
                            observer.onCompleted()
                        } else {
                            observer.onError(ErrorResult(type: .failure))
                        }
                    case .failure:
                        let errorCode = response.response?.statusCode ?? 500
                        switch errorCode {
                        //forbidden
                        case 401...403:
                            observer.onError(ErrorResult(type: .forbidden))

                        default:
                            observer.onError(ErrorResult(type: .failure))
                        }
                    }
                })
            return Disposables.create()
        }).share()
    }

    private func decode<TEntity>(data: Data) -> TEntity? where TEntity: Codable {
        return try? JSONDecoder().decode(TEntity.self, from: data)
    }

    private func createHttpRequest(config: NetworkApiClientConfig) -> URLRequest {
        let urlPathComplete = String(format: "%@%@",
                                     config.baseUrl,
                                     config.path)

        var urlComponents = URLComponents(string: urlPathComplete)

        if let queryItems = config.queryItems {
            urlComponents?.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        let request = URLRequest(url: (urlComponents?.url)!)
        return request
    }

}
