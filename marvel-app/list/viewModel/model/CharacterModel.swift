//
//  HeroModel.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 16/05/2022.
//

import Foundation

struct CharacterModel {
    let name: String
    let characterDescription: String
    let imagePath: String
    let imageExtension: String

    func getStandarLargeUrlImage() -> String {
        let url = ("\(imagePath)/standard_large.\(imageExtension)")
        return url
    }
    
    func getLandscapeLargeUrlImage() -> String {
        let url = ("\(imagePath)/landscape_large.\(imageExtension)")
        return url
    }

}
