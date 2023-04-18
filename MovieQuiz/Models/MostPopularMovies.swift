import Foundation
struct MostPopularMovies {
    let errorMessgae: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie {
    let title: String
    let rating: String
    let imageURL: URL
}
