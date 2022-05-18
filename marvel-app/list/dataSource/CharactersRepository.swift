//
//  HerosRepository.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 16/05/2022.
//
import RxSwift

struct KeyDict {
    let publicKey: String!
    let privateKey: String!
}

protocol CharactersRepositoryProtocol {
    func getCharacters(nameStartsWith: String?, limit: Int, offset: Int) -> Observable<CharacterResponse>
}

class CharactersRepository: CharactersRepositoryProtocol {

    private var apiManager: NetworkApiClient

    init(apiManager: NetworkApiClient = NetworkApiClient()) {
        self.apiManager = apiManager
    }

    func getCharacters(nameStartsWith: String?, limit: Int, offset: Int) -> Observable<CharacterResponse> {
        let dict: KeyDict = self.getKeys()
        let config = NetworkApiClientConfig()
        let ts = "thesoer"
        let publicKey = dict.publicKey ?? ""
        let privateKey =  dict.privateKey ?? ""
        let tsAndKeys = "\(ts)\(privateKey)\(publicKey)"

        config.path = "/characters"
        config.httpMethod = .get
        config.addQueryItem(key: "apikey", value: publicKey)
        config.addQueryItem(key: "hash", value: "\(tsAndKeys.md5Hash())")
        config.addQueryItem(key: "ts", value: "\(ts)")
        config.addQueryItem(key: "limit", value: "\(limit)")
        config.addQueryItem(key: "offset", value: "\(offset)")

        if let nameStartsWith = nameStartsWith {
            config.addQueryItem(key: "nameStartsWith", value: nameStartsWith)
        }

        return apiManager.call(config: config)
    }

    func getKeys() -> KeyDict {
        var keys: NSDictionary?
        if let path = Bundle.main.path(forResource: "ApiKeys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)!
        }

        if let data = keys {
            return KeyDict(publicKey: (data["publicKey"] as! String), privateKey: (data["privateKey"] as! String))
        } else {
            return KeyDict(publicKey: "", privateKey: "")
        }
    }

}
