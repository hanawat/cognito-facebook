//
//  ChatUser.swift
//  Chat
//
//  Created by Hanawa Takuro on 2016/11/13.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ChatUser: AWSDynamoDBObjectModel, AWSDynamoDBModeling {

    var userId: String = ""
    var userName: String = ""
    var userImageUrl: String = ""
    var endpoint: String = ""

    static func dynamoDBTableName() -> String {
        return "ChatUsers"
    }

    static func hashKeyAttribute() -> String {
        return "userId"
    }
}
