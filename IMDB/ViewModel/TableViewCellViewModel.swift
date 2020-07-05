//
//  TableViewCellViewModel.swift
//  IMDB
//
//  Created by Roma Filipenko on 02.07.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit

class TableViewCellViewModel {
    
    private var movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    var name: String {
        return movie.name
    }
    
    var description: String {
        return movie.description ?? ""
    }
    
    var posterUrl: String? {
        return movie.posterURL ?? nil
    }
}
