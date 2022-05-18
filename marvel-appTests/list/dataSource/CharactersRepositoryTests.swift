//
//  CharactersRepositoryTests.swift
//  marvel-appTests
//
//  Created by Fabrizio Sposetti on 18/05/2022.
//

import XCTest
import RxSwift
import Alamofire
import OHHTTPStubs

@testable import marvel_app

class CharactersRepositoryTests: BaseRepositoryRemoteTest {

    private var disposeBag = DisposeBag()

    func test_getCharacters_ok() {
        // Given
        let character = CharacterEntity(name: "name", description: "description", thumbnail: nil)
        let response = CharacterResponse(code: 200, data: CharacterData(offset: 0, limit: 20, total: 1, count: 20,
                                                                        results: [character]))

        let apiManager: NetworkApiClient = initRemote()
        let repository: CharactersRepository = CharactersRepository(apiManager: apiManager)

        //When
        let call = repository.getCharacters(limit: 20, offset: 20)

        ServiceTestMock.createStub(data: response)
        let expectation = self.expectation(description: "OK")

        call.subscribe(onNext: { response in
            // Then
            XCTAssertNotNil(response)
            expectation.fulfill()
        }).disposed(by: disposeBag)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_getCharacters_fail() {
        // Given
        let character = CharacterEntity(name: "name", description: "description", thumbnail: nil)
        let response = CharacterResponse(code: 200, data: CharacterData(offset: 0, limit: 20, total: 1, count: 20,
                                                                        results: [character]))
        let apiManager: NetworkApiClient = initRemote()
        let repository: CharactersRepository = CharactersRepository(apiManager: apiManager)

        //When
        let call = repository.getCharacters(limit: 20, offset: 20)
        ServiceTestMock.createStub(data: response, statusCode: 500)
        let expectation = self.expectation(description: "OK")

        call.subscribe(onError: { response in
            // Then
            XCTAssertNotNil(response)
            expectation.fulfill()
        }).disposed(by: disposeBag)

        waitForExpectations(timeout: 10, handler: nil)
    }

}

class BaseRepositoryRemoteTest: XCTestCase {
    private var disposeBag = DisposeBag()

    func initRemote<RemoteType>() -> RemoteType where RemoteType: NetworkApiClient {
        let sessionManager = ServiceTestMock.createSessionManager()
        return RemoteType.init(manager: sessionManager)
    }
    
}

class ServiceTestMock: NSObject {

    public static func createSessionManager() -> Session {
        let configuration = URLSessionConfiguration.default
        HTTPStubs.setEnabled(true, for: configuration)
        configuration.urlCache = nil
        return Session(configuration: configuration)
    }

    public static func createStub<T> (data: T?, statusCode: Int = 200) where T: Codable {
        if let emptyData = Data(base64Encoded: "") {
            let encodedData = try? JSONEncoder().encode(data)
            stub(condition: { _ in return true }, response: { _ -> HTTPStubsResponse in
                return HTTPStubsResponse(data: encodedData ?? emptyData, statusCode: Int32(statusCode), headers: nil)
            })
        } else {
            assertionFailure()
        }
    }

}
