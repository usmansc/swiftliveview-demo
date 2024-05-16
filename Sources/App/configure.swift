import Vapor
import TokamakVapor
import Leaf
import SwiftLiveView

// configures your application
public func configure(_ app: Application) async throws {
    app.views.use(.leaf)
    app.middleware.use(WebsocketInitializer())
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let router = LiveRouter<String, ClientMessage> {
        // View that is rendered at invalid path request
        TokamakStaticHTML.StaticHTMLRenderer(InvalidPath()).render()
    } handleMessage: { router, request, message, socket in
        await router.passMessageToCurrentComponent(message, from: socket)
    }
    guard let privateKeySecret = Environment.get("PRIVATE")?.base64Decoded(),
          let publicKeySecret = Environment.get("PUBLIC")?.base64Decoded() else {
        fatalError("Could not read private or public key environment")
    }
    // register routes
    app.setLiveViewHandler(
        LiveViewHandler<ClientMessage>(
            configuration: LiveViewHandlerConfiguration<ClientMessage>(
                app: app,
                router: router,
                privateKeySecret: privateKeySecret,
                publicKeySecret: publicKeySecret,
                onCloseStrategy: .deleteConnection(after: 10)) {
                [
                    IndexComponent(app: app, path: "/")
                ]
            }
        )
    )
    try routes(app)
}

public enum Action: String, Decodable, Sendable {
    case live_action = "live-action"
}

typealias ClientMessage = BaseClientMessage<Action>

extension String {
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
