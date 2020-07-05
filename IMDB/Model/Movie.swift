//
//  Movie.swift
//  IMDB
//
//  Created by Roma Filipenko on 02.07.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit

struct MoviesResponse: Codable {
    
    let page: Int
    let totalPages: Int
    let totalResults: Int
    let results: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case totalPages = "total_pages"
        case totalResults = "total_results"
        case results = "results"
    }
}

struct Movie: Codable {
    
    let id: Int
    let name: String
    let description: String?
    let posterURL: String?
    let releaseDate: String?
    let genres: [Genres]?
    let credits: Credits?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case name = "original_title"
        case description = "overview"
        case posterURL = "poster_path"
        case releaseDate = "release_date"
        case genres = "genres"
        case credits = "credits"
    }
}

struct Genres: Codable {
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
    }
}
