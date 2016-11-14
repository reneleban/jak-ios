import Foundation

#if DEBUG
    enum Services: String {
        case LOGIN = "http://localhost:10030/"
        case BOARD = "http://localhost:10000/"
        case LIST = "http://localhost:10010/"
        case CARD = "http://localhost:10020/"
    }
#else
    enum Services: String {
        case LOGIN = "https://jak.codecamps.de/jak-login/"
        case BOARD = "https://jak.codecamps.de/jak-board/"
        case LIST = "https://jak.codecamps.de/jak-list/"
        case CARD = "https://jak.codecamps.de/jak-card/"
    }
#endif
