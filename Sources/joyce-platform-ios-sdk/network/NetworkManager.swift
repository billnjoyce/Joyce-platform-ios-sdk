//
//  NetworkManager.swift
//  Joyce Studios
//
//  Created by billkim on 2024/04/25.
//

import Foundation
import Alamofire

public class NetworkManager: NSObject {
    private static let instance = NetworkManager()
    
    @objc static let shared = NetworkManager()
    
    public func initManager() {

    }

    public func requestGet(url: String, headers: HTTPHeaders = [:], completion: @escaping ClosureStringVoid) {
        AF.request(url,
                   method: .get,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
            switch response.result {
            case .success(let data):
                completion("0")
            case .failure(let error):
                completion(response.error?.localizedDescription ?? "-1")
            }
        }
    }
}




