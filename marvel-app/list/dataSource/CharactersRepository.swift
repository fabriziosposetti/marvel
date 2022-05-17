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
        return apiManager.call()
    }
    
}
