//
//  GetHerosUseCase.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 16/05/2022.
//

import RxSwift

protocol GetCharactersUseCaseProtocol {
    func execute(nameStartsWith: String?, limit: Int, offset: Int) -> Observable<CharacterResponse>
}

class GetCharactersUseCase: GetCharactersUseCaseProtocol {

    private var repository: CharactersRepositoryProtocol

    init(repository: CharactersRepositoryProtocol = CharactersRepository()) {
        self.repository = repository
    }

    func execute(nameStartsWith: String?, limit: Int, offset: Int) -> Observable<CharacterResponse> {
        repository.getCharacters(nameStartsWith: nameStartsWith, limit: limit, offset: offset)
    }

}
