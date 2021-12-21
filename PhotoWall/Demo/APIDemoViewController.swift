//import UIKit
//import Alamofire
//
//struct UnsplashApiKey {
//    let accessKey: String
//    let secretKey: String
//}
//
//struct PhotoParameters: Encodable {
//    let page: Int
//    let clientID: String
//    let perPage: Int
//    let query: String
//    
//    enum CodingKeys: String, CodingKey {
//        case clientID = "client_id"
//        case perPage = "per_page"
//        case query, page
//    }
//}
//
//class APIDemoViewController: UIViewController {
//    var dataSource: [PhotoItem] = [] {
//        didSet {
//            printItem()
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.view.backgroundColor = .systemPink
//        
//        print("🐵 Start")
//        
////        AF.request("https://www.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1", method: .get)
////            .response { response in
////                debugPrint(response)
////            }
//        
//        let parameters = PhotoParameters(page: 1,
//                                         clientID: apiKey.accessKey,
//                                         perPage: 5,
//                                         query: "dog")
//        
//        AF.request("https://api.unsplash.com/search/photos",
//                   method: .get,
//                   parameters: parameters)
//            .responseDecodable(of: PhotoResult.self) { response in
//                switch response.result {
//                case .success(let photoResult):
//                    if !photoResult.results.isEmpty {
//                        self.dataSource = photoResult.results
//                    }
//                case .failure(let error):
//                    print("❌", error)
//                }
//            }
//        
//        AF.request("https://api.unsplash.com/photos",
//                   method: .get,
//                   parameters: parameters)
//            .responseDecodable(of: [PhotoItem].self) { response in
//                switch response.result {
//                case .success(let photoResult):
//                    if !photoResult.isEmpty {
//                        self.dataSource = photoResult
//                    }
//                case .failure(let error):
//                    print("❌", error)
//                }
//            }
//    }
//
//    func printItem() {
//        for (index, item) in dataSource.enumerated() {
//            print(index, ": ", item.id, " / ", item.urls.regular, "\n")
//        }
//    }
//}
