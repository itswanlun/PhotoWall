import Foundation

class FakeAPIService: APIServiceProtocol {
    static let shared = FakeAPIService()
    private init() { }
    
    func getRandomPhoto(page: Int, perPage: Int, completionHandler: @escaping (Result<[PhotoItem], NetworkError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [unowned self] in
            let result = self.captureItems(data: randomPhotos, page: page - 1, perPage: perPage)
            
            DispatchQueue.main.async {
                completionHandler(Result.success(result))
            }
        }
    }
    
    func getSearchPhoto(page: Int, perPage: Int, keyword: String, completionHandler: @escaping (Result<[PhotoItem], NetworkError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [unowned self] in
            let result = self.captureItems(data: dogPhotos.results, page: page - 1, perPage: perPage)
            
            DispatchQueue.main.async {
                completionHandler(Result.success(result))
            }
        }
    }
    
    private func captureItems(data: [PhotoItem], page: Int, perPage: Int) -> [PhotoItem] {
        let start = perPage * page
        var end = start + perPage
        end = (end > data.count) ? data.count : end
        
        guard start < data.count else {
            return []
        }
        
        return Array(data[start..<end])
    }
}
