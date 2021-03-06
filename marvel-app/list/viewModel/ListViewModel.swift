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
        let midLoading: Observable<Bool>
        let error: Observable<Void>
        let footerLoading: Observable<Bool>
        let successfullyLoaded: Observable<Void>
    }

    // MARK: - Private
    private var disposeBag = DisposeBag()
    private var onCharactersLoad = PublishSubject<[CharacterModel]>()
    private var onLoading = PublishSubject<Bool>()
    private var onFooterLoading = PublishSubject<Bool>()
    private var onSuccessfullLoading =  PublishSubject<Void>()
    private var onError =  PublishSubject<Void>()
    private var characters: [CharacterModel] = []
    private var charactersSearched: [CharacterModel] = []
    private var limit: Int = 30
    private var offset: Int = 0
    private var totalCharacters: Int = 0
    private var totalCharactersSearched: Int = 0
    private var isSearching = false
    private var loadingMoreSearchResults = false
    private var nameStartWith: String?

    // MARK: - Private: UseCases
    private var getCharactersUseCase: GetCharactersUseCaseProtocol

    init(getCharactersUseCase: GetCharactersUseCaseProtocol = GetCharactersUseCase()) {
        self.getCharactersUseCase = getCharactersUseCase
        self.output = Output(characters: onCharactersLoad.asObservable(),
                             midLoading: onLoading.asObservable(),
                             error: onError.asObservable(),
                             footerLoading: onFooterLoading.asObservable(),
                             successfullyLoaded: onSuccessfullLoading.asObservable())
    }

    func getCharacters(showMidIndicator: Bool) {
        let useCase = getCharactersUseCase.execute(nameStartsWith: nil, limit: limit, offset: offset)
        showMidIndicator ? onLoading.onNext(true) : onFooterLoading.onNext(true)
        useCase.subscribe(onNext: { [weak self] response in
            guard let self = self else { return }
            showMidIndicator ? self.onLoading.onNext(false) : self.onFooterLoading.onNext(false)
            self.handleCharactersResponse(response: response, searchResponse: false)
        }, onError: { [weak self] error in
            guard let self = self else { return }
            self.onError.onNext(())
        }).disposed(by: disposeBag)
    }

    func getMoreCharacters() {
        getCharacters(showMidIndicator: false)
    }

    func initSearchMode() {
        isSearching = true
        offset = 0
    }

    func search(query: String?) {
        nameStartWith = query
        let useCase = getCharactersUseCase.execute(nameStartsWith: query, limit: limit, offset: offset)
        onLoading.onNext(true)
        useCase.subscribe(onNext: { [weak self] response in
            guard let self = self else { return }
            self.onLoading.onNext(false)
            self.handleCharactersResponse(response: response, searchResponse: true)
        }, onError: { [weak self] error in
            guard let self = self else { return }
            self.onError.onNext(())
        }).disposed(by: disposeBag)
    }

    func getMoreSearchResults() {
        loadingMoreSearchResults = true
        search(query: nameStartWith)
    }

    func showInitialResults() {
        isSearching = false
        if !(characters.isEmpty) {
            onCharactersLoad.onNext(characters)
        }
    }

    func isLastCell(row: Int) -> Bool {
        return isSearching ? row + 1 == charactersSearched.count  : row + 1 == characters.count
    }

    func hasNextPage() -> Bool {
        return isSearching ? charactersSearched.count < totalCharactersSearched : characters.count < totalCharacters
    }

    private func handleCharactersResponse(response: CharacterResponse, searchResponse: Bool) {
        if searchResponse {
            handleSearchResponse(response: response)
        } else {
            handleNormalResponse(response: response)
        }
    }

    private func handleSearchResponse(response: CharacterResponse) {
        let newCharacters = CharacterMapper.map(characterResponse: response)
        if loadingMoreSearchResults {
            charactersSearched.append(contentsOf: newCharacters)
            loadingMoreSearchResults = false
        } else {
            charactersSearched = newCharacters
        }
        offset += response.data.count
        totalCharactersSearched = response.data.total
        onCharactersLoad.onNext(charactersSearched)
        onSuccessfullLoading.onNext(())
    }

    private func handleNormalResponse(response: CharacterResponse) {
        let newCharacters = CharacterMapper.map(characterResponse: response)
        characters.append(contentsOf: newCharacters)
        totalCharacters = response.data.total
        offset += response.data.count
        onCharactersLoad.onNext(characters)
        onSuccessfullLoading.onNext(())
    }

}

