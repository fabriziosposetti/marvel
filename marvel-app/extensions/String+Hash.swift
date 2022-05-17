//
//  String+Hash.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 17/05/2022.
//

import Foundation
import CryptoKit

extension String {

    func md5Hash() -> String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }

    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }

}
