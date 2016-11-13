//
//  ChatRoom.swift
//  Chat
//
//  Created by Hanawa Takuro on 2016/11/13.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ChatRoom: AWSDynamoDBObjectModel, AWSDynamoDBModeling {

    var roomId: String = ""
    var roomName: String = ""
    var userId: String = ""

    static func dynamoDBTableName() -> String {
        return "ChatRooms"
    }

    static func hashKeyAttribute() -> String {
        return "roomId"
    }

    static func rangeKeyAttribute() -> String {
        return "userId"
    }
}
