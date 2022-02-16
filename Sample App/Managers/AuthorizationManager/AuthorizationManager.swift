//
//  AuthorizationManagerProtocol.swift
//  Sample App
//
//  Created by Martin De Simone on 15/02/2022.
//

import Alamofire
import Foundation

protocol AuthorizationManagerProtocol{
    func authorize(_ callback: @escaping ((Bool) -> Void))
}

class AuthorizationManager: AuthorizationManagerProtocol{
    let keychainManagerProtocol: KeychainManagerProtocol
    
    init(keychainManagerProtocol: KeychainManagerProtocol){
        self.keychainManagerProtocol = keychainManagerProtocol
    }
    
    func authorize(_ callback: @escaping ((Bool) -> Void)) {
        let authorizationModel = AuthorizationRequestModel(grant_type: "client_credentials", scope: LIVE_COMMENTS_SECTION_ID)
        
        let credentialData = "\(AUTHORIZATION_USERNAME):\(AUTHORIZATION_PASSWORD)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers: HTTPHeaders = ["Authorization": "Basic \(base64Credentials)"]
        
        AF.request(AUTHORIZATION_BASE_URL + "authorize_client",
                   method: .post,
                   parameters: authorizationModel,
                   encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
                   headers: headers)
            .validate(statusCode: 200..<300)
            .authenticate(username: AUTHORIZATION_USERNAME, password: AUTHORIZATION_PASSWORD)
            .responseDecodable(of: AuthorizationResponseModel.self) { response in
                if let decodedResponse = response.value, response.error == nil{
                    self.keychainManagerProtocol.save(decodedResponse.access_token, forKey: KeychainKeys.BEARER_TOKEN)
                    callback(true)
                }
                else{
                    callback(false)
                }
        }
    }
}

// MARK: Authorization models

struct AuthorizationRequestModel: Encodable {
    let grant_type: String
    let scope: String
}

struct AuthorizationResponseModel: Decodable{
    let status_code: Int
    let status_message: String
    let access_token: String
    let client: String
    let authname: String
    let grant_type: String
}
