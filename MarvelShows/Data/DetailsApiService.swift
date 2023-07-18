import Foundation
import UIKit

class DetailsApiService {
    let hash = HashTS()

    func fetchData(seriesId: Int? = nil, completion : @escaping (SelectedResponce?) -> ()) {
        
        hash.generateHash(timestamp: hash.timestamp, privateKey: hash.privateKey, publicKey: hash.publicKey, seriesId: seriesId)

        let sourcesURL = URL(string: hash.selectedApiUrl)!

        URLSession.shared.dataTask(with: sourcesURL) { [weak self] (data, urlResponse, error) in
            if let data = data {
                
                let jsonDecoder = JSONDecoder()
                
                do {
                    let empData = try jsonDecoder.decode(SelectedResponce.self, from: data)
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
