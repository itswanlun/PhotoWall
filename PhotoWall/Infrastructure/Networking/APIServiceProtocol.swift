import Foundation

protocol APIServiceProtocol {
    func getRandomPhoto(page: Int, perPage: Int, completionHandler: @escaping (Result<[PhotoItem], NetworkError>) -> Void)
    func getSearchPhoto(page: Int, perPage: Int, keyword: String, completionHandler: @escaping (Result<[PhotoItem], NetworkError>) -> Void)
}
