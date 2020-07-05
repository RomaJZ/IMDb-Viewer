//
//  MovieAPI.swift
//  IMDB
//
//  Created by Roma Filipenko on 02.07.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation

//MARK: APIError

enum APIError: Error {
    
    case badResponce, jsonDecoder, badData, badImage
}

class MovieAPI {
    
    //MARK: Base URL & API key
    
    static let baseUrl = "https://api.themoviedb.org"
    static let apiKey = "eee7620f876039138efc3e46c5935bfe"
    
    //MARK: Movies Fetching
    
    func fetchTrendingMovies(page: Int, query: String? = nil, completion: @escaping (Result<MoviesResponse, Error>) -> Void) {
        var endpoint: MovieEndpoint
        
        if query == nil {
            endpoint = MovieEndpoint.trending(page: page)
        } else {
            endpoint = MovieEndpoint.search(page: page, query: query!)
        }
        
        let request = endpoint.request
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                completion(.failure(APIError.badResponce))
                return
            }
            
            guard let moviesResponse = try? JSONDecoder().decode(MoviesResponse.self, from: data!) else {
                completion(.failure(APIError.jsonDecoder))
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(moviesResponse))
            }
        }.resume()
    }
    
    //MARK: Movie Info Loading
    
    func fetchMovie(id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        
        let endpoint = MovieEndpoint.movie(id: id)
        let request = endpoint.request
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                completion(.failure(APIError.badResponce))
                return
            }
            
            guard let movie = try? JSONDecoder().decode(Movie.self, from: data!) else {
                completion(.failure(APIError.jsonDecoder))
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(movie))
            }
        }.resume()
    }
    
    func fetchCredits(id: Int, completion: @escaping (Result<Credits, Error>) -> Void) {
        
        let endpoint = MovieEndpoint.credits(id: id)
        let request = endpoint.request
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                completion(.failure(APIError.badResponce))
                return
            }
            
            guard let credits = try? JSONDecoder().decode(Credits.self, from: data!) else {
                completion(.failure(APIError.jsonDecoder))
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(credits))
            }
        }.resume()
    }
}

