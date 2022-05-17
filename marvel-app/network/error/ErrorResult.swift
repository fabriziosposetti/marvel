//
//  ErrorResult.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 17/05/2022.
//

import Foundation

class ErrorResult: Swift.Error {
    
    private var type: ErrorType

    init(type: ErrorType) {
        self.type = type
    }
}

enum ErrorType {
    case internetConnectionError
    case failure
    case forbidden
    case timeout
}
