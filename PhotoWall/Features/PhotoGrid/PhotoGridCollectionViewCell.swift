import UIKit
import SnapKit

class PhotoGridCollectionViewCell: UICollectionViewCell {
    lazy var photoImageView: UIImageView = {
        translatesAutoresizingMaskIntoConstraints = false
        let photoImageView = UIImageView()
        return photoImageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoGridCollectionViewCell {
    private func setupUI() {
        contentView.addSubview(photoImageView)
        photoImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
    }
}
