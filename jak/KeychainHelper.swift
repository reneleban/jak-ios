import Foundation

enum JakKeychain: String {
    
    case TOUCH_ID_ENABLED = "touchid-enabled"
    case SERVICE_TOKEN = "service-token"
    case DEFAULT_BOARD = "default-board"
}

class JakKeychainHelper {
    
    static let keychain = KeychainSwift()
    
    static func deleteAllKeychainProperties() {
        keychain.delete(JakKeychain.TOUCH_ID_ENABLED.rawValue)
        keychain.delete(JakKeychain.SERVICE_TOKEN.rawValue)
        keychain.delete(JakKeychain.DEFAULT_BOARD.rawValue)
    }
}
