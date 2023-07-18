import Foundation
import UIKit

class MarvelApiService {
    let hash = HashTS()
    let itemsPerPage = 10

    func fetchData(page: Int, completion: @escaping (SeriesResponse?) -> ()) {
        
        hash.generateHash(timestamp: hash.timestamp, privateKey: hash.privateKey, publicKey: hash.publicKey)

        let offset = page * itemsPerPage
        let urlString = "\(hash.apiUrl)&offset=\(offset)&limit=\(itemsPerPage)"
        guard let sourcesURL = URL(string: urlString) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: sourcesURL) { (data, urlResponse, error) in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let empData = try jsonDecoder.decode(SeriesResponse.self, from: data)
                    completion(empData)
                    print(empData)
                } catch {
                    print("Error decoding data: \(error)")
                    completion(nil)
                }
            }
        }.resume()
    }
}
