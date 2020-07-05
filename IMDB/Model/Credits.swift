//
//  MovieResponse.swift
//  IMDB
//
//  Created by Roma Filipenko on 02.07.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation

struct Credits: Codable {
    
    let cast: [Cast]
    let crew: [Crew]
    
    enum CodingKeys: String, CodingKey {
        case cast = "cast"
        case crew = "crew"
    }
}

struct Cast: Codable {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
    }
}

struct Crew: Codable {
    let name: String
    let job: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case job = "job"
    }
}
