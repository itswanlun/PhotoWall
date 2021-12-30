import Foundation

struct PhotoResult: Codable {
    let total, totalPages: Int
    let results: [PhotoItem]

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

struct PhotoItem: Codable {
    let id: String
    let urls: Urls
}

// MARK: - Urls
struct Urls: Codable {
    let raw, full, regular, small: String
    let thumb: String
}
