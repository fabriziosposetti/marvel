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
    private var characters: [CharacterModel] = []
    private var limit: Int = 20
    private var offset: Int = 0
    private var totalCharacters: Int = 0

    // MARK: - Private: UseCases
    private var getCharactersUseCase: GetCharactersUseCaseProtocol

    init(getCharactersUseCase: GetCharactersUseCaseProtocol = GetCharactersUseCase()) {
        self.getCharactersUseCase = getCharactersUseCase
        self.output = Output(characters: onCharactersLoad.asObservable(),
                             loading: onLoading.asObservable())
    }

    func getCharacters() {
        let useCase = getCharactersUseCase.execute(limit: limit, offset: offset)
        onLoading.onNext(true)
        useCase.subscribe(onNext: { [weak self] response in
            guard let self = self else { return }
            self.onLoading.onNext(false)
            let newCharacters = CharacterMapper.map(characterResponse: response)
            self.characters.append(contentsOf: newCharacters)
            self.totalCharacters = response.data?.total ?? 0
            self.offset += response.data?.count ?? 0
            self.onCharactersLoad.onNext(self.characters)
        }).disposed(by: disposeBag)
    }

    func isLastCell(row: Int) -> Bool {
        return (row + 1) == self.characters.count
    }

    func hasNextPage() -> Bool {
        return characters.count < totalCharacters
    }

}
