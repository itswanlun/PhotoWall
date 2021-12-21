import UIKit
import SnapKit

class PhotoDetailViewController: UIViewController {
    
    var url: URL?
    lazy var photoImageView: UIImageView = {
        let photoImageView = UIImageView()
        return photoImageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
    }
    
    
}

extension PhotoDetailViewController {
    private func setupUI() {
        view.addSubview(photoImageView)
        
        photoImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }
        
        if let url = url {
            photoImageView.setImage(url: url)
        }
        
    }
}
