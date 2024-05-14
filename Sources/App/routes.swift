import Vapor
import SwiftLiveView

func routes(_ app: Application) throws {
    app.get("api", "issue-token") { req async throws -> String in
        try TokenGenerator.generateToken(app)
    }

    app.get("", "**") { req async throws -> View in
        return try await req.view.render("index")
    }

    app.get { req async throws -> View in
        return try await req.view.render("index")
    }

    let handler: LiveViewHandler<ClientMessage> = app.liveViewHandler()
    app.webSocket("websocket", onUpgrade: handler.handleWebsocket)
}
