//
//  CommentsManager.swift
//  Sample App
//
//  Created by Martin De Simone on 15/02/2022.
//

import Alamofire
import Foundation

protocol CommentsManagerProtocol{
    func createCommentsContainer(containerId: String, title: String, _ callback: @escaping ((Bool, UUID?) -> Void))
    func createComment(contentContainerUUID: UUID, originTitle: String, content: String, _ callback: @escaping ((Bool, UUID?) -> Void))
    func likeComment(contentContainerUUID: UUID, contentUUID: UUID, _ callback: @escaping ((Bool) -> Void))
    func dislikeComment(contentContainerUUID: UUID, contentUUID: UUID, _ callback: @escaping ((Bool) -> Void))
    func replyToComment(contentContainerUUID: UUID, contentUUID: UUID, originTitle: String, content: String, _ callback: @escaping ((Bool) -> Void))
}

class CommentsManager: CommentsManagerProtocol{
    let keychainManagerProtocol: KeychainManagerProtocol
    let authorizationManagerProtocol: AuthorizationManagerProtocol

    init(keychainManagerProtocol: KeychainManagerProtocol, authorizationManagerProtocol: AuthorizationManagerProtocol){
        self.keychainManagerProtocol = keychainManagerProtocol
        self.authorizationManagerProtocol = authorizationManagerProtocol
    }
    
    func createComment(contentContainerUUID: UUID, originTitle: String, content: String, _ callback: @escaping ((Bool, UUID?) -> Void)) {
        authorizationManagerProtocol.authorize({ [weak self]
            success in
            if(success){
                guard let strongSelf = self else {
                    return
                }
                
                let createCommentModel = CreateCommentRequestModel(content: content, metadata: CommentMetadata(origin_title: originTitle))
                                
                AF.request(LIVE_COMMENTS_BASE_URL + "livecomments/" + LIVE_COMMENTS_SECTION_ID + "/" + contentContainerUUID.uuidString + "/comments",
                           method: .post,
                           parameters: createCommentModel,
                           encoder: JSONParameterEncoder.default,
                           headers: strongSelf.getAuthHeaders())
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: CreateCommentResponseModel.self) { response in
                        if let decodedResponse = response.value, response.error == nil{
                            callback(true, decodedResponse.content_uuid)
                        }
                        else{
                            callback(false, nil)
                        }
                }
            }
            
            callback(false, nil)
        })
    }
    
    func replyToComment(contentContainerUUID: UUID, contentUUID: UUID, originTitle: String, content: String, _ callback: @escaping ((Bool) -> Void)) {
        authorizationManagerProtocol.authorize({ [weak self]
            success in
            if(success){
                guard let strongSelf = self else {
                    return
                }
                
                let replyCommentModel = ReplyCommentRequestModel(content: content, metadata: CommentMetadata(origin_title: originTitle))
                
                AF.request(LIVE_COMMENTS_BASE_URL + "livecomments/" + LIVE_COMMENTS_SECTION_ID + "/" + contentContainerUUID.uuidString + "/comments/" + contentUUID.uuidString,
                           method: .post,
                           parameters: replyCommentModel,
                           encoder: JSONParameterEncoder.default,
                           headers: strongSelf.getAuthHeaders())
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: ReplyCommentResponseModel.self) { response in
                        if let decodedResponse = response.value, response.error == nil{
                            callback(true)
                        }
                        else{
                            callback(false)
                        }
                }
            }
            
            callback(false)
        })
    }
    
    func createCommentsContainer(containerId: String, title: String, _ callback: @escaping ((Bool, UUID?) -> Void)) {
        let createCommentContainerModel = CreateCommentContainerRequestModel(container_id: containerId, title: title)

        AF.request(LIVE_COMMENTS_BASE_URL + "livecomments/" + LIVE_COMMENTS_SECTION_ID,
                   method: .post,
                   parameters: createCommentContainerModel,
                   encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: CreateCommentContainerResponseModel.self) { response in
                if let decodedResponse = response.value, response.error == nil{
                    callback(true, decodedResponse.content_container_uuid)
                }
                else{
                    callback(false, nil)
                }
        }
    }
    
    func likeComment(contentContainerUUID: UUID, contentUUID: UUID, _ callback: @escaping ((Bool) -> Void)) {
        authorizationManagerProtocol.authorize({ [weak self]
            success in
            if(success){
                guard let strongSelf = self else {
                    return
                }
                
                AF.request(LIVE_COMMENTS_BASE_URL + "livecomments/" + LIVE_COMMENTS_SECTION_ID + "/" + contentContainerUUID.uuidString + "/comments/" + contentUUID.uuidString + "/like",
                           method: .post,
                           headers: strongSelf.getAuthHeaders())
                    .validate(statusCode: 200..<300)
                    .response { response in
                        if response.response?.statusCode == 200 && response.error == nil{
                            callback(true)
                        }
                        else{
                            callback(false)
                        }
                }
            }
            
            callback(false)
        })
    }
    
    func dislikeComment(contentContainerUUID: UUID, contentUUID: UUID, _ callback: @escaping ((Bool) -> Void)) {
        authorizationManagerProtocol.authorize({ [weak self]
            success in
            if(success){
                guard let strongSelf = self else {
                    return
                }
                
                AF.request(LIVE_COMMENTS_BASE_URL + "livecomments/" + LIVE_COMMENTS_SECTION_ID + "/" + contentContainerUUID.uuidString + "/comments/" + contentUUID.uuidString + "/dislike",
                           method: .post,
                           headers: strongSelf.getAuthHeaders())
                    .validate(statusCode: 200..<300)
                    .response { response in
                        if response.response?.statusCode == 200 && response.error == nil{
                            callback(true)
                        }
                        else{
                            callback(false)
                        }
                }
            }
            
            callback(false)
        })
    }
    
    func getAuthHeaders() -> HTTPHeaders{
        let headers: HTTPHeaders = [.authorization(bearerToken: keychainManagerProtocol.load(withKey: KeychainKeys.BEARER_TOKEN) ?? ""), HTTPHeader(name: "Content-Type", value: "application/json")]
        return headers
    }
}


// MARK: Comment

struct CreateCommentRequestModel: Encodable {
    let content: String
    let metadata: CommentMetadata
}

struct CreateCommentResponseModel: Decodable {
    let http_status: Int?
    let content_uuid: UUID
}

// MARK: Comment reply

struct ReplyCommentRequestModel: Encodable {
    let content: String
    let metadata: CommentMetadata
}

struct ReplyCommentResponseModel: Decodable{
    let http_status: Int?
}

// MARK: Comment container

struct CreateCommentContainerRequestModel: Encodable {
    let container_id: String
    let title: String
}

struct CreateCommentContainerResponseModel: Decodable{
    let http_status: Int?
    let content_container_uuid: UUID
}

// MARK: Metadata

struct CommentMetadata: Encodable{
    let origin_title: String
}
