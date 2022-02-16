//
//  Comment.swift
//  Sample App
//
//  Created by Martin De Simone on 16/02/2022.
//

import Foundation
class Comment{
    let uuid: UUID
    let content: String
    
    init(uuid: UUID, content: String) {
        self.uuid = uuid
        self.content = content
    }
}
