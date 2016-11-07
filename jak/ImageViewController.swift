import Foundation
import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var imageview: UIImageView!
    
    func setImage(_ img: UIImage) {
        self.imageview = UIImageView(image: img)
        self.imageview.isUserInteractionEnabled = true
        self.imageview.contentMode = .scaleAspectFit
    }
}
