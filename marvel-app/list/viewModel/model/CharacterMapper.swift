//
//  CharacterMapper.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 17/05/2022.
//

import Foundation

class CharacterMapper {
    static func map(characterResponse: CharacterResponse) -> [CharacterModel] {
        var characters: [CharacterModel] = []
        characterResponse.data.results?.forEach({
            characters.append(CharacterModel(name: $0.name, characterDescription: $0.description,
                                             imagePath: $0.thumbnail?.path ?? "",
                                             imageExtension: $0.thumbnail?.thumbnailExtension ?? ""))
        })
        return characters
    }
}
