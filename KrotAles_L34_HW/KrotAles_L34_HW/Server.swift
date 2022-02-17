//
//  Server.swift
//  KrotAles_L34_HW
//
//  Created by Ales Krot on 16.02.22.
//

import Foundation

struct User {
    let login: String
}

enum ServerError: Error {
    case wrongLogin
    case unknownError
}

class Server {
    private var users = [User]()
    private let serverQueue = DispatchQueue(label: "app.server", attributes: .concurrent)
    
    init() {
        createUsers()
    }
    
    private func createUsers() {
        let user1 = User(login: "user1")
        let user2 = User(login: "user2")
        
        users.append(user1)
        users.append(user2)
    }
    
    func signIn(login: String, completion: @escaping (Result<String, ServerError>) -> Void) {
        serverQueue.asyncAfter(deadline: .now() + 2) {
            let loginInArray = self.users.filter({ user in
                user.login == login
            })
            if loginInArray.isEmpty {
                completion(.failure(.wrongLogin))
            } else {
            completion(.success(login))
            }
        }
    }
}
