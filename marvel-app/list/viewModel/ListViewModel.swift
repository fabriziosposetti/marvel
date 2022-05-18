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
        let loadingMoreCharacters: Observable<Bool>
        let error: Observable<Void>
        let successfullyLoaded: Observable<Void>
    }

    // MARK: - Private
    private var disposeBag = DisposeBag()
    private var onCharactersLoad = PublishSubject<[CharacterModel]>()
    private var onLoading = PublishSubject<Bool>()
    private var onLoadingMoreCharacters = PublishSubject<Bool>()
    private var onError =  PublishSubject<Void>()
    private var onSuccessfullLoading =  PublishSubject<Void>()
    private var characters: [CharacterModel] = []
    private var limit: Int = 20
    private var offset: Int = 0
    private var totalCharacters: Int = 0

    // MARK: - Private: UseCases
    private var getCharactersUseCase: GetCharactersUseCaseProtocol

    init(getCharactersUseCase: GetCharactersUseCaseProtocol = GetCharactersUseCase()) {
        self.getCharactersUseCase = getCharactersUseCase
        self.output = Output(characters: onCharactersLoad.asObservable(),
                             loading: onLoading.asObservable(),
                             loadingMoreCharacters: onLoadingMoreCharacters.asObservable(),
                             error: onError.asObservable(),
                             successfullyLoaded: onSuccessfullLoading.asObservable())
    }

    func getCharacters(showMidIndicator: Bool) {
        let useCase = getCharactersUseCase.execute(limit: limit, offset: offset)
        showMidIndicator ? onLoading.onNext(true) : onLoadingMoreCharacters.onNext(true)

        useCase.subscribe(onNext: { [weak self] response in
            guard let self = self else { return }
            showMidIndicator ? self.onLoading.onNext(false) : self.onLoadingMoreCharacters.onNext(false)
            self.handleCharactersResponse(response: response)
        }, onError: { [weak self] _ in
            guard let self = self else { return }
            self.onError.onNext(())
        }).disposed(by: disposeBag)
    }

    private func handleCharactersResponse(response: CharacterResponse) {
        let newCharacters = CharacterMapper.map(characterResponse: response)
        characters.append(contentsOf: newCharacters)
        totalCharacters = response.data?.total ?? 0
        offset += response.data?.count ?? 0
        onCharactersLoad.onNext(self.characters)
        onSuccessfullLoading.onNext(())
    }

    func isLastCell(row: Int) -> Bool {
        return (row + 1) == self.characters.count
    }

    func hasNextPage() -> Bool {
        return characters.count < totalCharacters
    }

}
