import Foundation
import UIKit
import Alamofire

struct UnsplashApiKey {
    let accessKey: String
    let secretKey: String
}

struct PhotoParameters: Encodable {
    let page: Int
    let clientID: String
    let perPage: Int
    let query: String
    
    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case perPage = "per_page"
        case query
        case page
    }
}

class APIService {
    static let shared = APIService()
    private init() { }
    
    func getRandomPhoto(page: Int, perPage: Int, completionHandler: @escaping (Result<[PhotoItem], NetworkError>) -> Void) {
        let parameters = PhotoParameters(page: page,
                                         clientID: apiKey.accessKey,
                                         perPage: perPage,
                                         query: "dog")
        
                AF.request("https://api.unsplash.com/photos",
                           method: .get,
                           parameters: parameters)
                    .responseDecodable(of: [PhotoItem].self) { response in
                        switch response.result {
                        case .success(let photoResult):
                            if !photoResult.isEmpty {
                                completionHandler(Result.success(photoResult))
                            }
                        case .failure(let error):
                            print("❌", error)
                        }
                    }
        
//        AF.request("https://api.unsplash.com/search/photos",
//                   method: .get,
//                   parameters: parameters)
//          .responseDecodable(of: PhotoResult.self) { response in
//                switch response.result {
//                case .success(let photoResult):
//                    if !photoResult.results.isEmpty {
//                        //self.dataSource = photoResult.results
//                        completionHandler(Result.success(photoResult.results))
//                    }
//                case .failure(let error):
//                    print("❌", error)
//                    completionHandler(Result.failure(NetworkError.unknownError))
//                }
//            }
    }
    
    func getSearchPhoto(page: Int, perPage: Int, keyword: String, completionHandler: @escaping (Result<[PhotoItem], NetworkError>) -> Void) {
        let parameters = PhotoParameters(page: page,
                                         clientID: apiKey.accessKey,
                                         perPage: perPage,
                                         query: keyword)
        
        AF.request("https://api.unsplash.com/search/photos",
                   method: .get,
                   parameters: parameters)
          .responseDecodable(of: PhotoResult.self) { response in
                switch response.result {
                case .success(let photoResult):
                    if !photoResult.results.isEmpty {
                        //self.dataSource = photoResult.results
                        completionHandler(Result.success(photoResult.results))
                    }
                case .failure(let error):
                    print("❌", error)
                    completionHandler(Result.failure(NetworkError.unknownError))
                }
            }
    }
}
