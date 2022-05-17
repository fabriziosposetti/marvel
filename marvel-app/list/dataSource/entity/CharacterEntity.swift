//
//  HeroEntity.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 16/05/2022.
//

import Foundation

// MARK: - CharacterResponse
struct CharacterResponse: Codable {
    let code: Int?
    let data: CharacterData?
}

// MARK: - HerosResponse
struct CharacterData: Codable {
    let offset, limit, total, count: Int?
    let results: [CharacterEntity]?
}

// MARK: - HeroEntity
struct CharacterEntity: Codable {
    let name: String
    let description: String
}

