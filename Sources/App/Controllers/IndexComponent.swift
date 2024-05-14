//
//  IndexComponent.swift
//
//
//  Created by Lukáš Schmelcer on 14/05/2024.
//

import Vapor
import SwiftLiveView
import Combine

class IndexComponent: LiveRoutableComponent {
    var app: Vapor.Application
    var path: String
    var webSocket: WebSocket?
    var counter = 0 {
        didSet {
            guard let webSocket else { return }
            self.sendUpdate(via: webSocket, content: BaseServerMessage(value: "\(counter)", action: .updateNodeValue(target: "counterLabel")))
        }
    }

    init(app: Vapor.Application, path: String, webSocket: WebSocket? = nil) {
        self.app = app
        self.path = path
        self.webSocket = webSocket
    }

    /// Helper method to render leaf template
    private func renderView(_ app: Application, template: String) async throws -> String {
        let view = try await app.view.render(template).get()
        let buff = view.data
        return String(buffer: buff)
    }

    /// Protocol required method to render base template for component
    func baseTemplate() async throws -> String {
        try await renderView(app, template: "index.leaf")
    }
    
    /// Protocol required method to handle incoming messages
    func receiveMessage<ClientMessageType: ClientMessageDecodable>(from ws: WebSocket, message: ClientMessageType) {
        // Typecast incoming message to our typealiased message from `configure.swift`
        guard let message = message as? ClientMessage else { return }
        switch message.action {
        case .live_action:
            guard let target = LiveActionCall(rawValue: message.value ?? "") else { return }
            switch target {
            case .increment:
                counter += 1
            case .decrement:
                counter -= 1
            }
            return
        default:
            return
        }
    }

    // Mapping for request ids from `index.leaf` template
    private enum LiveActionCall: String {
        case increment = "increment"
        case decrement = "decrement"
    }
}

// MARK: Extension with unused required methods
extension IndexComponent {
    typealias Context = Never
    func contextSnapshot() -> Context? { nil }
    func loadFromContext(_ context: Never) { return }
}
