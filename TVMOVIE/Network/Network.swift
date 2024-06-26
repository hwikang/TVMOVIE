//
//  Network.swift
//  TVMOVIE
//
//  Created by Dumveloper on 2023/02/28.
//

import Foundation
import RxSwift
import RxAlamofire

class Network<T:Decodable> {

    private let endpoint: String
    private let queue: ConcurrentDispatchQueueScheduler
    init(_ endpoint: String) {
        self.endpoint = endpoint
        self.queue = ConcurrentDispatchQueueScheduler(qos: .background)
    }
    func getItemList(path: String, isEnglish: Bool = false, page: Int? = nil, query: String? = nil) -> Observable<T> {
        var fullPath = "\(endpoint)\(path)?api_key=\(APIKEY)&language=\(isEnglish ? "en" : "ko")"
        if let page = page {
            fullPath += "&page=\(page)"
        }
        if let query = query?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            fullPath += "&query=\(query)"
        }
        print(fullPath)
        return RxAlamofire.data(.get, fullPath)
            .observe(on: queue)
            .debug()
            .map { data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            }
    }
    
}

