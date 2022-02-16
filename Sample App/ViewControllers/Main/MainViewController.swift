//
//  ViewController.swift
//  Sample App
//
//  Created by Martin De Simone on 15/02/2022.
//

import UIKit

class MainViewController: BaseViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var seeCommentsButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    enum AlertType{
        case login
        case logout
        case signup
    }
    
    class VFCommentsViewController{
        
    }
    let mainViewModel = MainViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupArticle()
        
        logoutButton.isHidden = !mainViewModel.isAuthenticated
    }
    
    func setupArticle(){
        let customWebViewController = CustomWebViewController()
        
        addChild(customWebViewController)
        customWebViewController.view.frame = contentView.bounds
        contentView.addSubview(customWebViewController.view)
        customWebViewController.didMove(toParent: self)
        
        customWebViewController.loadUrl(url: URL(string: mainViewModel.ARTICLE_URL)!)
    }
    
    @IBAction func seeCommentsTapped(_ sender: Any) {
        if mainViewModel.isAuthenticated{
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let commentsViewController = mainStoryboard.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
            commentsViewController.commentsViewModel = CommentsViewModel(articleTitle: mainViewModel.ARTICLE_NAME, articleId: mainViewModel.ARTICLE_ID)
            self.present(commentsViewController, animated: true, completion: nil)
        }
        else{
            showAlertNotAuthenticated()
        }
    }
    
    func showAlertNotAuthenticated(){
        let alert = UIAlertController(title: "You are not logged in", message: "Please enter to continue", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Create account", style: .default, handler: { (_) in
            self.showSignupAlert()
        }))

        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (_) in
            self.showLoginAlert()
        }))

        self.present(alert, animated: true)
    }
    
    func showLoginAlert(){
        let alertController = UIAlertController(title: "Log-in", message: "Enter your credentials", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "E-mail"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Log-in", style: .default, handler: { alert -> Void in
            let emailText = (alertController.textFields![0] as UITextField).text ?? ""
            let passwordText = (alertController.textFields![1] as UITextField).text ?? ""
            self.mainViewModel.submitLogin(email: emailText, password: passwordText, {
                success, errorMessage in
                if(success){
                    self.logoutButton.isHidden = false
                }
                else{
                    self.showErrorAlert(errorMessage: errorMessage ?? "", alertType: .login)
                }
            })
        })

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSignupAlert(){
        let alertController = UIAlertController(title: "Create your account", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Name"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "E-mail"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Sign-up", style: .default, handler: { alert -> Void in
            let nameText = (alertController.textFields![0] as UITextField).text ?? ""
            let emailText = (alertController.textFields![1] as UITextField).text ?? ""
            let passwordText = (alertController.textFields![2] as UITextField).text ?? ""
            
            self.mainViewModel.submitSignup(name: nameText, email: emailText, password: passwordText, {
                success, errorMessage in
                if(success){
                    self.logoutButton.isHidden = false
                }
                else{
                    self.showErrorAlert(errorMessage: errorMessage ?? "", alertType: .signup)
                }
            })
        })

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(errorMessage: String, alertType: AlertType){
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)

        if(alertType != .logout){
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { alert -> Void in
                if alertType == .login{
                    self.showLoginAlert()
                }
                else if alertType == .signup{
                    self.showSignupAlert()
                }
            })

            alertController.addAction(retryAction)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        mainViewModel.submitLogout({ success, errorMessage in
            if(success){
                self.logoutButton.isHidden = true
            }
            else{
                self.showErrorAlert(errorMessage: errorMessage ?? "", alertType: .logout)
            }
        })
    }
}

