//
//  Content.swift
//  TVMOVIE
//
//  Created by Dumveloper on 2023/04/03.
//

import Foundation


struct Content: Decodable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterURL: String
    let vote: String
    let releaseDate: String
    
    init(tv: TV) {
        self.id = tv.id
        self.title = tv.name
        self.overview = tv.overview
        self.posterURL = tv.posterURL
        self.vote = tv.vote
        self.releaseDate = tv.firstAirDate
    }
    
    init(movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview
        self.posterURL = movie.posterURL
        self.vote = movie.vote
        self.releaseDate = movie.releaseDate
    }
    
}
