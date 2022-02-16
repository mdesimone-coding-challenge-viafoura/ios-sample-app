//
//  CommentTableViewCell.swift
//  Sample App
//
//  Created by Martin De Simone on 16/02/2022.
//

import Foundation
import UIKit

class CommentTableViewCell: UITableViewCell{
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var replyLabel: UILabel!
    
    var replyCallback: (() -> Void)?
    var likeCallback: (() -> Void)?
    var dislikeCallback: (() -> Void)?
    
    // This should not be stored this way as cell recycling will cause glitching, doing this for speed/demo purposes
    var isLiked = false

    func setup(comment: Comment){
        contentLabel.text = comment.content
        
        likeLabel.textColor = .gray
        likeLabel.isUserInteractionEnabled = true
        likeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(likeTapped)))
        
        replyLabel.isUserInteractionEnabled = true
        replyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(replyTapped)))
    }
    
    @objc func replyTapped(){
        replyCallback?()
    }
    
    // This should not be done this way, doing this for speed/demo purposes
    @objc func likeTapped(){
        isLiked = !isLiked
        
        if isLiked{
            likeLabel.textColor = .systemGreen
            likeLabel.text = "Liked"
            likeCallback?()
        }
        else{
            likeLabel.textColor = .gray
            likeLabel.text = "Like"
            dislikeCallback?()
        }
    }
}
