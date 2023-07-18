import Foundation
import CommonCrypto

class HashTS {
    var apiUrl: String = ""
    var selectedApiUrl: String = ""
    let timestamp = String(Date().timeIntervalSince1970)
    let publicKey = "22de5b580fb132f1e70c3ef1a25ec310"
    let privateKey = "e47593a9f1dc1210c04110a13eea1f72ee829919"
    var series: SeriesResponse?
    var seriesId: Int?

    func generateHash(timestamp: String, privateKey: String, publicKey: String, seriesId: Int? = nil) -> String {
        let hashInput = timestamp + privateKey + publicKey
        let data = hashInput.data(using: .utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_MD5($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hash = digest.map { String(format: "%02hhx", $0) }.joined()
        let urlString = "https://gateway.marvel.com/v1/public/series?ts=\(timestamp)&apikey=\(publicKey)&hash=\(hash)"
        let detailUrlString = "https://gateway.marvel.com/v1/public/series/\(seriesId ?? 0)?ts=\(timestamp)&apikey=\(publicKey)&hash=\(hash)"
        apiUrl = urlString
        selectedApiUrl = detailUrlString
        print(apiUrl)
        print(selectedApiUrl)

        return hash
    }
}
