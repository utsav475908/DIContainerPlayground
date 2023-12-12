import UIKit

//Container.shared.bind(Object.self) { resolver in
//    
//}
//
//let object = Container.shared.resolve(Object.self)


final class Container {
    static let shared = Container()
    
    private init() {}
    
    private var services: [String: Any] = [:]
    
    func bind<Service>(service: Service.Type, resolver: @escaping(Container) -> Service) {
        let key = String(describing: Service.self)
        self.services[key] = resolver(self)
    }
    
    func resolve<Service>(_ type: Service.Type) -> Service {
        let key = String(describing: type)
        guard let service = services[key] as? Service else {
            fatalError("\(type) service not registered")
        }
        return service
    }
}

struct User {
    let username: String
    let password: String
}

protocol Authenticator {
    func authenticate(user: User) -> Bool
}

protocol Analytics {
    func log(infos: String)
}

struct DefaultAuthenticator: Authenticator {
    func authenticate(user: User) -> Bool {
        return true
    }
}

struct DefaultAnalaytics: Analytics {
    func log(infos: String) {
        print(infos)
    }
}

class LoginViewModel {
    private let analytics: Analytics
    private let authenticator: Authenticator
    
    init(analytics: Analytics, authenticator: Authenticator) {
        self.analytics = analytics
        self.authenticator = authenticator
    }
    
    func login(username: String, password: String) {
        let user = User(username: username, password: password)
        let result = authenticator.authenticate(user: user)
        if result {
            analytics.log(infos: "✅ \(user.username) is logged in successfully")
        } else {
            analytics.log(infos: "❌ \(user.username) is not logged in 🥲")
        }
    }
}

Container.shared.bind(service: Authenticator.self) { resolver in
 return DefaultAuthenticator()
}

Container.shared.bind(service: Analytics.self) { resolver in
    return DefaultAnalaytics()
}

Container.shared.bind(service: LoginViewModel.self) { resolver in
    let authenticator = resolver.resolve(Authenticator.self)
    let analytics = resolver.resolve(Analytics.self)
    return LoginViewModel(analytics: analytics, authenticator: authenticator)
}

let viewModel = Container.shared.resolve(LoginViewModel.self)
viewModel.login(username: "utsav", password: "kumar")

