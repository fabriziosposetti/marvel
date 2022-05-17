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
        characterResponse.data?.results?.forEach({
            let url = ("\($0.thumbnail?.path ?? "")/landscape_large.\($0.thumbnail?.thumbnailExtension ?? "")")
            characters.append(CharacterModel(name: $0.name, thumbnailUrl: url))
        })
        return characters
    }
}
