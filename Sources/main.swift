import Vapor

let PORT = 8080

struct User: Content {
    var name: String
    var age: Int

}

struct UserResponse: Content {
    var id: Int
    var user: User
}

struct UserListResponse: Content {

    var userList: [User]

}

struct UserCreatedResponse: Content {
    var created: Bool
    var user: User
}

actor Counter {

    var id = 0

    func increment() {
        id += 1
    }

    func collect() -> Int {
        return id
    }

}

actor UsersState {

    var users: [Int: User] = [0: User(name: "", age: 0)]

    func insert(id: Int, u: User) {
        users[id] = u
    }
    func collect(id: Int) -> User? {
        return users[id]
    }
    func collect_all() -> [User] {
        return Array(users.values)
    }
    func remove(id: Int) -> Bool {

        let removed = users.removeValue(forKey: id)
        return removed != nil

    }
    func change(id: Int, u: User) -> Bool {

        let exists = users.index(forKey: id)
        if exists != nil {
            users[id] = u
            return true
        }
        return false
    }
}

func routes(_ app: Application) throws {

    let counter = Counter()
    let state = UsersState()

    app.post("user") { req async throws -> UserResponse in
        let user = try req.content.decode(User.self)
        await counter.increment()
        let id = await counter.collect()
        await state.insert(id: id, u: user)
        return UserResponse(id: id, user: user)
    }

    app.delete("user", ":id") { req async throws -> Response in

        guard let idString = req.parameters.get("id"),
            let id = Int(idString),
            await state.remove(id: id)
        else {
            let notFound = ["error": "User not found."]
            let data = try JSONEncoder().encode(notFound)
            return Response(status: .notFound, body: .init(data: data))
        }

        return Response(status: .accepted, body: .init(string: "User deleted successfully."))

    }

    app.patch("user", ":id") { req async throws -> Response in

        let user = try req.content.decode(User.self)

        guard let idString = req.parameters.get("id"),
            let id = Int(idString),
            await state.change(id: id, u: user)
        else {
            let notFound = ["error": "User not found."]
            let data = try JSONEncoder().encode(notFound)
            return Response(status: .notFound, body: .init(data: data))
        }

        return Response(status: .accepted, body: .init(string: "User patched successfully."))

    }

    app.get("users") { req async throws -> UserListResponse in

        let users = await state.collect_all()
        let response = UserListResponse(userList: users)
        return response
    }
    app.get("user", ":id") { req async throws -> Response in
        guard let idString = req.parameters.get("id"),
            let id = Int(idString),
            let user = await state.collect(id: id)
        else {

            let notFound = ["error": "User not found."]
            let data = try JSONEncoder().encode(notFound)
            return Response(status: .notFound, body: .init(data: data))
        }

        let data = try JSONEncoder().encode(user)
        return Response(status: .ok, body: .init(data: data))
    }

}

var app = try await Application.make(.detect())

try routes(app)
try await app.execute()
