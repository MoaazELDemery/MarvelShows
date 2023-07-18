import Foundation

class SelectedResponce: Codable {
    let code: Int
    let status: String
    let attributionText: String
    let attributionHTML: String
    let etag: String
    let data: SelectedData
}
struct SelectedData: Codable {
    let offset: Int
    let limit: Int
    let total: Int
    let count: Int
    let results: [SelectedSeries]
}
struct SelectedSeries: Codable {
    let id: Int
    let title: String
    let startYear: Int
    let endYear: Int
    let rating: String
    let type: String
    let thumbnail: SelectedThumbnail
    let creators: CreatorList
}
struct SelectedThumbnail: Codable {
    let path: String
    let `extension`: String
}
struct CreatorList: Codable {
    let items: [Creator]
}
struct Creator: Codable {
    let name: String
}
