import Foundation
import UIKit

class ReachabilityObserver {
    
    fileprivate static let INSTANCE = ReachabilityObserver()
    
    fileprivate let reachabilityInstance = Reachability()!
    
    fileprivate init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: ReachabilityChangedNotification, object: reachabilityInstance)
        
        do {
            try reachabilityInstance.startNotifier()
        } catch {
            print("Notifier could not be started!")
        }
    }
    
    static func reachability() -> Reachability {
        return self.INSTANCE.reachabilityInstance
    }
    
    static func isConnected() -> Bool {
        return reachability().isReachable
    }
    
    static func showNoConnectionAlert(_ viewController: UIViewController) {
        let alert = UIAlertController(title: "No internet connection", message: "You have no active internet connection. Some actions are only available while having an active internet connection.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        if reachability.isReachable {
            hideAlert()
        } else {
            showAlert()
        }
    }
    
    fileprivate func showAlert() {
        UIApplication.shared.statusBarStyle = .lightContent
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor.red
        }
    }

    fileprivate func hideAlert() {
        UIApplication.shared.statusBarStyle = .default
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor(red: 120.0/255.0, green: 144.0/255.0, blue: 156.0/255.0, alpha: 0)
        }
    }
}
