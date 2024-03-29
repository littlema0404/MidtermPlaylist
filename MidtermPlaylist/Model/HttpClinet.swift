//
//  HttpClinet.swift
//  MidtermPlaylist
//
//  Created by littlema on 2019/8/23.
//  Copyright © 2019 littema. All rights reserved.
//

import Foundation

enum RestAPIError: Error {
    case clientError
    case serverError
    case unexpectedError
    case decodeError
}

enum HttpMethod: String {
    case GET
    case POST
}

enum HttpHeaderKey: String {
    case contentType = "Content-Type"
    case authorization = "Authorization"
}

enum HttpHeaderValue: String {
    case formData = "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW"
}

protocol RestAPIRequest {
    var header: [String: String] { get }
    var body: Data? { get }
    var method: String { get }
    var url: String { get }
}

extension RestAPIRequest {
    func makeRequest() -> URLRequest {
        let urlString = url
        let urlObject = URL(string: urlString)!
        
        var request = URLRequest(url: urlObject)
        
        request.allHTTPHeaderFields = header
        request.httpMethod = method
        request.httpBody = body

        return request
    }
}

class HttpClinet {
    static let shared = HttpClinet()
    
    private let decoder = JSONDecoder()
    
    func request(_ request: URLRequest, completion: @escaping (Result<Data, RestAPIError>) -> Void) {
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { return }
            
            let httpResponse = response as! HTTPURLResponse
            
            let statusCode = httpResponse.statusCode
            
            switch statusCode {
            case 200..<300: completion(Result.success(data!))
            case 300..<400: completion(Result.failure(RestAPIError.clientError))
            case 400..<500: completion(Result.failure(RestAPIError.serverError))
            case 500..<600: completion(Result.failure(RestAPIError.unexpectedError))
            default: completion(Result.failure(RestAPIError.unexpectedError))
            }
        }.resume()
    
    }
    
}
