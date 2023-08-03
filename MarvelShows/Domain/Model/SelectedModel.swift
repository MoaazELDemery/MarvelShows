import Foundation

class SelectedResponce: Codable {
    let code: Int
    let status: String
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
    let endYear: Int
    let creators: CreatorList
}
struct CreatorList: Codable {
    let items: [Creator]
}
struct Creator: Codable {
    let name: String
}
