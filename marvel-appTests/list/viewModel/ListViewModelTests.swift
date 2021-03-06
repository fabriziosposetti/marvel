//
//  ListViewModelTests.swift
//  marvel-appTests
//
//  Created by Fabrizio Sposetti on 18/05/2022.
//

import XCTest
import RxSwift
@testable import marvel_app

class ListViewModelTests: XCTestCase {

    private var disposeBag = DisposeBag()

    func test_loadCharacters_ok() {
        // given
        let getCharactersUseCaseMock = GetCharactersUseCaseMock(success: true)
        let viewModel = ListViewModel(getCharactersUseCase: getCharactersUseCaseMock)

        let expectation = self.expectation(description: "OK")

        viewModel.output.characters.subscribe(onNext: { response in
            // then
            XCTAssertFalse(viewModel.hasNextPage())
            XCTAssertTrue(response.first?.name == "name")
            XCTAssertTrue(viewModel.isLastCell(row: 0))
            expectation.fulfill()
        }).disposed(by: disposeBag)

        // when
        viewModel.getCharacters(showMidIndicator: true)
        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_loadCharacters_fail() {
        // given
        let getCharactersUseCaseMock = GetCharactersUseCaseMock(success: false)
        let viewModel = ListViewModel(getCharactersUseCase: getCharactersUseCaseMock)

        let expectation = self.expectation(description: "OK")

        viewModel.output.error.subscribe(onNext: { response in
            // then
            expectation.fulfill()
        }).disposed(by: disposeBag)

        // when
        viewModel.getCharacters(showMidIndicator: true)
        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_search_ok() {
        // given
        let getCharactersUseCaseMock = GetCharactersUseCaseMock(success: true)
        let viewModel = ListViewModel(getCharactersUseCase: getCharactersUseCaseMock)
        viewModel.initSearchMode()

        let expectation = self.expectation(description: "OK")

        viewModel.output.characters.subscribe(onNext: { response in
            // then
            XCTAssertFalse(viewModel.hasNextPage())
            XCTAssertTrue(response.first?.name == "name")
            expectation.fulfill()
        }).disposed(by: disposeBag)

        // when
        viewModel.search(query: "na")
        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_search_fail() {
        // given
        let getCharactersUseCaseMock = GetCharactersUseCaseMock(success: false)
        let viewModel = ListViewModel(getCharactersUseCase: getCharactersUseCaseMock)

        let expectation = self.expectation(description: "OK")

        viewModel.output.error.subscribe(onNext: { response in
            // then
            expectation.fulfill()
        }).disposed(by: disposeBag)

        // when
        viewModel.search(query: "na")
        waitForExpectations(timeout: 10, handler: nil)
    }

}

class GetCharactersUseCaseMock: GetCharactersUseCaseProtocol {
    private var success: Bool

    init(success: Bool) {
        self.success = success
    }

    func execute(nameStartsWith: String?, limit: Int, offset: Int) -> Observable<CharacterResponse> {
        return success ? CharactersTestHelper.getCharacterResponse() : Observable.error(ErrorResult(type: .failure))
    }
    
}
