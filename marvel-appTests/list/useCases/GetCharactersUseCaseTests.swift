//
//  marvel_appTests.swift
//  marvel-appTests
//
//  Created by Fabrizio Sposetti on 16/05/2022.
//

import XCTest
import RxSwift
@testable import marvel_app

class GetCharactersUseCaseTests: XCTestCase {

    private var disposeBag = DisposeBag()

    func test_execute_ok() {
        // given
        let mockRepository = CharactersRepositoryMock()
        let useCase = GetCharactersUseCase(repository: mockRepository)

        // when
        let result = useCase.execute(limit: 20, offset: 20)
        let expectation = self.expectation(description: "OK")
        result.subscribe(onNext: { response in
            // then
            XCTAssertTrue(response.data?.results?.first?.name == "name")
            expectation.fulfill()
        }).disposed(by: disposeBag)

        waitForExpectations(timeout: 10, handler: nil)
    }

}

class CharactersRepositoryMock: CharactersRepositoryProtocol {

    func getCharacters(limit: Int, offset: Int) -> Observable<CharacterResponse> {
        return CharactersTestHelper.getCharacterResponse()
    }

}

class CharactersTestHelper {
    static func getCharacterResponse() -> Observable<CharacterResponse> {
        let character = CharacterEntity(name: "name", description: "description", thumbnail: nil)
        return Observable.just(CharacterResponse(code: 200, data: CharacterData(offset: 0, limit: 20,
                                                                                total: 1, count: 20, results: [character])))
    }
}
