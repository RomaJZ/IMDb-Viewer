//
//  Endpoint.swift
//  IMDB
//
//  Created by Roma Filipenko on 02.07.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation

protocol Endpoint {
    
    var method: String { get }
    var baseUrl: String { get }
    var path: String { get }
    var urlParameters: [URLQueryItem] { get }
}

extension Endpoint {
    
    var urlComponent: URLComponents {
        var urlComponent = URLComponents(string: baseUrl)
        urlComponent?.path = path
        urlComponent?.queryItems = urlParameters
        urlComponent?.queryItems?.append( URLQueryItem(name: "api_key", value: "\(MovieAPI.apiKey)") )
        return urlComponent!
    }
    
    var request: URLRequest {
        
        var request = URLRequest(url: urlComponent.url!)
        request.httpMethod = method
        
        return request
    }
}

enum MovieEndpoint: Endpoint {
    
    case trending (page: Int)
    case movie (id: Int)
    case credits (id: Int)
    case search (page: Int, query: String)
    
    var method: String {
        return "GET"
    }

    var baseUrl: String {
        return MovieAPI.baseUrl
    }

    var path: String {
        switch self {
        case .trending:
            return "/3/trending/movie/week"
        case .movie(let id):
            return "/3/movie/\(id)"
        case .credits(let id):
            return "/3/movie/\(id)/credits"
        case .search:
            return "/3/search/movie"
        }
    }

    var urlParameters: [URLQueryItem] {
        switch self {
            case .trending(let page):
                return [
                    URLQueryItem(name: "page", value: "\(page)")
                    ]
            case .movie:
                return []
            case .credits:
                return []
            case .search(let page, let query):
                return [
                    URLQueryItem(name: "query", value: "\(query)"),
                    URLQueryItem(name: "page", value: "\(page)")
                    ]
        }
    }
}
