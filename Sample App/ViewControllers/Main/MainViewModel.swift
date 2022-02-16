//
//  MainViewModel.swift
//  Sample App
//
//  Created by Martin De Simone on 15/02/2022.
//

import Foundation
class MainViewModel: BaseViewModel{
    var isAuthenticated = false
    
    let authenticationManager: AuthenticationManagerProtocol = DependencyManager.shared().inject()
    
    let ARTICLE_URL = "https://www.clarin.com/autos/dymak-spiritus-triciclo-electrico-quieren-fabricar-argentina-vas-poder-manejar_0_KOlHQRzm7T.html"
    let ARTICLE_NAME = "Triciclo Electrico"
    let ARTICLE_ID = "@313j12m2w1"
    
    override init(){
        super.init()
        
        loadAuthenticationState()
    }
    
    func submitLogin(email: String, password: String, _ callback: @escaping ((Bool, String?) -> Void)){
        if email.isEmpty || password.isEmpty{
            callback(false, "You must fill all fields")
        }
        
        if password.count < 8{
            callback(false, "Password must be at least 8 characters")
        }
        
        authenticationManager.login(email: email, password: password, {
            success in
            if success{
                self.loadAuthenticationState()
                callback(true, nil)
            }
            else{
                callback(false, "An error has ocurred")
            }
        })
    }
    
    func submitSignup(name: String, email: String, password: String, _ callback: @escaping ((Bool, String?) -> Void)){
        if email.isEmpty || password.isEmpty || name.isEmpty{
            callback(false, "You must fill all fields")
        }
        
        if password.count < 8{
            callback(false, "Password must be at least 8 characters")
        }
        
        authenticationManager.signup(name: name, email: email, password: password, {
            success in
            if success{
                self.loadAuthenticationState()
                callback(true, nil)
            }
            else{
                callback(false, "An error has ocurred")
            }
        })
    }
    
    func submitLogout( _ callback: @escaping ((Bool, String?) -> Void)){
        authenticationManager.logout({
            success in
            if success{
                self.loadAuthenticationState()
                callback(true, nil)
            }
            else{
                callback(false, "An error has ocurred")
            }
        })
    }
    
    func loadAuthenticationState(){
        authenticationManager.isAuthenticated({ isAuthenticated in
            self.isAuthenticated = isAuthenticated
        })
    }
}
