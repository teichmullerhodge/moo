import Foundation
import FoundationNetworking

class WebSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?

    func connect() {
        let url = URL(string: "wss://echo.websocket.org")!  // Replace with your WebSocket server
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()

        listen()
        send(message: "Hello WebSocket 👋")
    }

    func listen() {
        webSocketTask?.receive({ result in
            switch result {
            case .failure(let error):
                print("Error receiving: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received string: \(text)")
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    print("Unknown message")
                }
                self?.listen()
            }
        })
    }

    func send(message: String) {
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print("Error sending: \(error)")
            } else {
                print("Message sent: \(message)")
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
