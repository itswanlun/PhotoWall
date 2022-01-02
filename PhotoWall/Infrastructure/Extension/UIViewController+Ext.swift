import Foundation
import UIKit

extension UIViewController {
    func showMessage(title: String?, message: String?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
}
