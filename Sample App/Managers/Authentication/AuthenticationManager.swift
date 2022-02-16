//
//  AuthenticationManager.swift
//  Sample App
//
//  Created by Martin De Simone on 15/02/2022.
//

import Alamofire
import Foundation

protocol AuthenticationManagerProtocol{
    func login(email: String, password: String, _ callback: @escaping ((Bool) -> Void))
    func signup(name: String, email: String, password: String, _ callback: @escaping ((Bool) -> Void))
    func logout(_ callback: @escaping ((Bool) -> Void))
    func isAuthenticated(_ callback: @escaping ((Bool) -> Void))
}

class AuthenticationManager: AuthenticationManagerProtocol{
    let keychainManagerProtocol: KeychainManagerProtocol
    
    init(keychainManagerProtocol: KeychainManagerProtocol){
        self.keychainManagerProtocol = keychainManagerProtocol
    }
    
    func isAuthenticated(_ callback: @escaping ((Bool) -> Void)){
        callback(keychainManagerProtocol.load(withKey: KeychainKeys.USER_LOGGED_IN) != nil)
    }
    
    func login(email: String, password: String, _ callback: @escaping ((Bool) -> Void)) {
        let login = LoginRequestModel(email: email, password: password)
        AF.request(USERS_BASE_URL + USERS_SITE_ID + "/users/login",
                   method: .post,
                   parameters: login,
                   encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: LoginResponseModel.self) { [] response in
                if let decodedResponse = response.value, response.error == nil{
                    self.keychainManagerProtocol.save("", forKey: KeychainKeys.USER_LOGGED_IN)
                    callback(true)
                }
                else{
                    callback(false)
                }
        }
    }
    
    func signup(name: String, email: String, password: String, _ callback: @escaping ((Bool) -> Void)) {
        let signUpModel = SignUpRequestModel(name: name, email: email, password: password)
        AF.request(USERS_BASE_URL + USERS_SITE_ID + "/users",
                   method: .post,
                   parameters: signUpModel,
                   encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: SignUpResponseModel.self) { response in
                print(response)
                if let decodedResponse = response.value, response.error == nil{
                    self.keychainManagerProtocol.save("", forKey: KeychainKeys.USER_LOGGED_IN)
                    callback(true)
                }
                else{
                    callback(false)
                }
        }
    }
    
    func logout(_ callback: @escaping ((Bool) -> Void)) {
        AF.request(USERS_BASE_URL + USERS_SITE_ID + "/users/logout",
                   method: .delete)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: LogoutResponseModel.self) { response in
                if let decodedResponse = response.value, response.error == nil{
                    self.keychainManagerProtocol.save(nil, forKey: KeychainKeys.USER_LOGGED_IN)
                    callback(true)
                }
                else{
                    callback(false)
                }
        }
    }
}

// MARK: Login

struct LoginRequestModel: Encodable {
    let email: String
    let password: String
}

struct LoginResponseModel: Decodable {
    let http_status: Int
}

// MARK: Signup

struct SignUpRequestModel: Encodable {
    let name: String
    let email: String
    let password: String
}

struct SignUpResponseModel: Decodable{
    let http_status: Int
}

// MARK: Logout

struct LogoutResponseModel: Decodable {
    let http_status: Int
}
