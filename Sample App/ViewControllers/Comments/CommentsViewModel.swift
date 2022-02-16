//
//  CommentsViewModel.swift
//  Sample App
//
//  Created by Martin De Simone on 15/02/2022.
//

import Foundation
class CommentsViewModel: BaseViewModel{
    let commentsManager: CommentsManagerProtocol = DependencyManager.shared().inject()
    
    var articleTitle = ""
    var articleId = ""
    
    var comments = [Comment]()
    
    var commentsContainerId: UUID?
    
    init(articleTitle: String, articleId: String) {
        super.init()
        
        self.articleTitle = articleTitle
        self.articleId = articleId
        
        createCommentsContainer()
    }
    
    func createCommentsContainer(){
        commentsManager.createCommentsContainer(containerId: articleId, title: articleTitle, { success, uuid in
            if(success){
                self.commentsContainerId = uuid
            }
        })
    }

    func submitNewComment(content: String, _ callback: @escaping ((Bool, String?) -> Void)){
        if content.isEmpty{
            callback(false, "You must enter a comment")
        }
        
        guard let commentsContainerId = commentsContainerId else {
            callback(false, "An error has ocurred")
            return
        }
        
        commentsManager.createComment(contentContainerUUID: commentsContainerId, originTitle: articleTitle, content: content, {
            success, uuid in
            if success, let uuid = uuid{
                self.comments.append(Comment(uuid: uuid, content: content))
                callback(true, nil)
            }
            else{
                callback(false, "An error has ocurred")
            }
        })
    }
    
    func likeComment(contentId: UUID, _ callback: @escaping ((Bool, String?) -> Void)){
        guard let commentsContainerId = commentsContainerId else {
            callback(false, "An error has ocurred")
            return
        }
        
        commentsManager.likeComment(contentContainerUUID: commentsContainerId, contentUUID: contentId, {
            success in
            if success{
                callback(true, nil)
            }
            else{
                callback(false, "An error has ocurred")
            }
        })
    }
    
    func dislikeComment(contentId: UUID, _ callback: @escaping ((Bool, String?) -> Void)){
        guard let commentsContainerId = commentsContainerId else {
            callback(false, "An error has ocurred")
            return
        }
        
        commentsManager.dislikeComment(contentContainerUUID: commentsContainerId, contentUUID: contentId, {
            success in
            if success{
                callback(true, nil)
            }
            else{
                callback(false, "An error has ocurred")
            }
        })
    }
    
    func newReply(content: String, contentId: UUID, _ callback: @escaping ((Bool, String?) -> Void)){
        guard let commentsContainerId = commentsContainerId else {
            callback(false, "An error has ocurred")
            return
        }
        
        commentsManager.replyToComment(contentContainerUUID: commentsContainerId, contentUUID: contentId, originTitle: articleTitle, content: content, {
            success in
            if success{
                callback(true, nil)
            }
            else{
                callback(false, "An error has ocurred")
            }
        })
    }
}
