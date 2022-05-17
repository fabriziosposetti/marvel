//
//  NetworkApiClientConfig.swift
//  marvel-app
//
//  Created by Fabrizio Sposetti on 17/05/2022.
//

import Foundation
import Alamofire

final class NetworkApiClientConfig: NSObject {

    var baseUrl: String =  "http://gateway.marvel.com/v1/public"
    var queryItems: [String: String]?
    var path: String = ""
    var httpMethod: HTTPMethod?

    func addQueryItem(key: String, value: String) {
        if queryItems == nil {
            queryItems = [:]
        }

        queryItems?[key] = value
    }
    
}
