import Foundation

struct SeriesResponse: Codable {
    let code: Int
    let status: String
    var data: SeriesData
}
struct SeriesData: Codable {
    let offset: Int
    let limit: Int
    let total: Int
    let count: Int
    var results: [Series]
}
struct Series: Codable {
    let id: Int
    let title: String
    let startYear: Int
    let endYear: Int?
    let rating: String
    let thumbnail: Thumbnail
}
struct Thumbnail: Codable {
    let path: String
    let `extension`: String
}
