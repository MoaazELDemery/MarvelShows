import Foundation
import UIKit

class MarvelApiService {
    let hash = HashTS()
    var offset = 0
    
    func fetchData(offset: Int, completion: @escaping (SeriesResponse?) -> ()) {
        
        hash.generateHash(timestamp: hash.timestamp, privateKey: hash.privateKey, publicKey: hash.publicKey)

        let urlString = "\(hash.apiUrl)&offset=\(offset)"
        print("urlString = \(urlString)")
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
