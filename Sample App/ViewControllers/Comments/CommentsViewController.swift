//
//  CommentsViewController.swift
//  Sample App
//
//  Created by Martin De Simone on 15/02/2022.
//

import Foundation
import UIKit
class CommentsViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newCommentButton: UIButton!
        
    var commentsViewModel: CommentsViewModel!
    
    struct Identifiers{
        static let commentCellIdentifier = "commentCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func newCommentTapped(_ sender: Any) {
        showNewCommentAlert()
    }
    
    func showNewCommentAlert(){
        let alertController = UIAlertController(title: "New comment", message: "Type your thoughts", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Text"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Send", style: .default, handler: { alert -> Void in
            let contentText = (alertController.textFields![0] as UITextField).text ?? ""
            self.commentsViewModel.submitNewComment(content: contentText, {
                success, errorMessage in
                if(success){
                    self.tableView.reloadData()
                }
                else{
                   
                }
            })
        })

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showNewReplyAlert(comment: Comment){
        let alertController = UIAlertController(title: "New reply", message: "Type your thoughts", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Text"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Send", style: .default, handler: { alert -> Void in
            let contentText = (alertController.textFields![0] as UITextField).text ?? ""
            self.commentsViewModel.newReply(content: contentText, contentId: comment.uuid, {
                success, errorMessage in
                
            })
        })

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension CommentsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
}

extension CommentsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsViewModel.comments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.commentCellIdentifier, for: indexPath) as! CommentTableViewCell
        let comment = commentsViewModel.comments[indexPath.row]
        cell.setup(comment: comment)
        cell.replyCallback = {
            self.showNewReplyAlert(comment: comment)
        }
        cell.likeCallback = {
            self.commentsViewModel.likeComment(contentId: comment.uuid, {
                success, errorMessage in
            })
        }
        cell.dislikeCallback = {
            self.commentsViewModel.dislikeComment(contentId: comment.uuid, {
                success, errorMessage in
            })
        }
        return cell
    }
}
