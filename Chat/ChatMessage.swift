//
//  ChatMessage.swift
//  Chat
//
//  Created by Hanawa Takuro on 2016/11/13.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ChatMessage: AWSDynamoDBObjectModel, AWSDynamoDBModeling {

    var messageId: String = ""
    var roomId: String = ""
    var userId: String = ""
    var text: String = ""
    var time: Int = 0

    static func dynamoDBTableName() -> String {
        return "ChatMessages"
    }

    static func hashKeyAttribute() -> String {
        return "roomId"
    }

    static func rangeKeyAttribute() -> String {
        return "messageId"
    }

}
