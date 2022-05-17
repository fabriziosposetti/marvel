//
//  ListViewModel.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 16/05/2022.
//

import RxSwift

class ListViewModel {

    // MARK: - Outputs
    var output: Output

    struct Output {
        let characters: Observable<[CharacterModel]>
        let loading: Observable<Bool>
    }

    // MARK: - Private
    private var disposeBag = DisposeBag()
    private var onCharactersLoad = PublishSubject<[CharacterModel]>()
    private var onLoading = PublishSubject<Bool>()
    private var heros: [CharacterModel] = []

    // MARK: - Private: UseCases
    private var getCharactersUseCase: GetCharactersUseCaseProtocol

    init(getCharactersUseCase: GetCharactersUseCaseProtocol = GetCharactersUseCase()) {
        self.getCharactersUseCase = getCharactersUseCase
        self.output = Output(characters: onCharactersLoad.asObservable(),
                             loading: onLoading.asObservable())
    }

    func getCharacters() {
        let useCase = getCharactersUseCase.execute()
        onLoading.onNext(true)
        useCase.subscribe(onNext: { [weak self] response in
            guard let strongSelf = self else { return }
            strongSelf.onLoading.onNext(false)
            let characters = CharacterMapper.map(characterResponse: response)
            strongSelf.onCharactersLoad.onNext(characters)

        }).disposed(by: disposeBag)

    }

}

class CharacterMapper {
    static func map(characterResponse: CharacterResponse) -> [CharacterModel] {
        var characters: [CharacterModel] = []
        characterResponse.data?.results?.forEach({
            characters.append(CharacterModel(name: $0.name, description: $0.description))
        })
        return characters
    }
}
