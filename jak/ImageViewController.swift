import Foundation
import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    fileprivate var img:UIImage?
    
    override func viewDidLoad() {
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 0.01
        self.scrollView.maximumZoomScale = 3.0
        
        self.imageview.image = img
        self.imageview.isUserInteractionEnabled = true
        self.imageview.contentMode = .scaleAspectFit
        self.imageview.center = self.scrollView.center
        self.imageview.frame = CGRect(x: 0, y: 0, width: img!.size.width, height: img!.size.height)
        
        self.scrollView.indicatorStyle = .white
        self.scrollView.contentSize = imageview.bounds.size
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageview
    }
    
    func setImage(_ img: UIImage) {
        self.img = img
    }
}
