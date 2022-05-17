//
//  HerosRepository.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 16/05/2022.
//
import RxSwift

protocol CharactersRepositoryProtocol {
    func getCharacters() -> Observable<CharacterResponse>
}

class CharactersRepository: CharactersRepositoryProtocol {

    private var apiManager: NetworkApiClient

    init(apiManager: NetworkApiClient = NetworkApiClient()) {
        self.apiManager = apiManager
    }

    func getCharacters() -> Observable<CharacterResponse> {
        let config = NetworkApiClientConfig()
        let ts = "thesoer"
        let publicKey = "6df01e61332aced9ac1cb6ff8fba713e"
        let privateKey = "2e8b0747968ca3fb4c2fd43c072de5606bc77f5c"
        let tsAndKeys = "\(ts)\(privateKey)\(publicKey)"

        config.path = "/characters"
        config.httpMethod = .get
        config.addQueryItem(key: "apikey", value: "6df01e61332aced9ac1cb6ff8fba713e")
        config.addQueryItem(key: "hash", value: "\(tsAndKeys.md5Hash())")
        config.addQueryItem(key: "ts", value: "\(ts)")
        
        return apiManager.call(config: config)
    }

}
