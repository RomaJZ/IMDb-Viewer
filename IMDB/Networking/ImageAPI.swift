//
//  ImageAPI.swift
//  IMDB
//
//  Created by Roma Filipenko on 02.07.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit

//MARK: Movie Poster Size URLs

enum ImageSize: String {
    case small = "https://image.tmdb.org/t/p/w154/"
    case original = "https://image.tmdb.org/t/p/original/"
}

class ImageAPI {
    
    //MARK: Cache For Posters
    
    private let cacheKey = "PosterCache"
    
    private func posterCache(urlString: String, poster: UIImage) {
        
        
        let path = NSTemporaryDirectory().appending(UUID().uuidString)
        let url = URL(fileURLWithPath: path)
        
        let data = poster.jpegData(compressionQuality: 1)
        try? data?.write(to: url)
        
        var dict = UserDefaults.standard.object(forKey: cacheKey) as? [String:String]
        if dict == nil {
            dict = [:]
        }
        dict![urlString] = path
        
        UserDefaults.standard.set(dict, forKey: cacheKey)
    }
    
    //MARK: Movie Poster Loading
    
    private func path(posterPath: String, size: ImageSize) -> URL {
        return URL(string: size.rawValue)!.appendingPathComponent(posterPath)
    }
    
    var posterUrl: String?
    
   func loadPoster(posterPath: String?, size: ImageSize, completion: @escaping (Result<UIImage, Error>) -> Void) {
    
        guard let posterPath = posterPath else { return }
    
        if let dict = UserDefaults.standard.object(forKey: cacheKey) as? [String:String] {
            if let path = dict[posterPath] {
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    
                    guard let poster = UIImage(data: data) else { return }
                    completion(.success(poster))
                    return
                }
            }
        }
        
        let url = path(posterPath: posterPath, size: size)
        let request = URLRequest(url: url)
    
        posterUrl = posterPath
    
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                completion(.failure(APIError.badResponce))
                return
            }
                
            guard let posterData = try? Data(contentsOf: url) else {
                completion(.failure(APIError.badData))
                return
            }
            
            guard let poster = UIImage(data: posterData) else {
                completion(.failure(APIError.badImage))
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                if self?.posterUrl == posterPath {
                    self?.posterCache(urlString: posterPath, poster: poster)
                    completion(.success(poster))
                }
            }
        }.resume()
    }
}
