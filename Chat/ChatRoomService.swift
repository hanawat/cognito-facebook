//
//  ChatRoomService.swift
//  Chat
//
//  Created by Hanawa Takuro on 2016/11/17.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ChatRoomService {

    fileprivate lazy var dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()

    func saveChatRoom(id: String, name: String, user: ChatUser, completion: ((Result<ChatRoom, NSError>) -> Void)?) {

        guard let room = ChatRoom() else { fatalError() }
        room.roomId = id
        room.roomName = name
        room.userId = user.userId

        dynamoDBObjectMapper.save(room)
            .continue(with: AWSExecutor.mainThread(), with: { task -> AnyObject! in
                if let error = task.error as? NSError {
                    completion?(.failure(error))
                    return nil
                }

                completion?(.success(room))
                return nil
            })
    }

    func getChatRooms(with user: ChatUser, completion: ((Result<[ChatRoom], NSError>) -> Void)?) {

        let query = AWSDynamoDBQueryExpression()
        query.indexName = "userId-roomId-index"
        query.keyConditionExpression = "userId = :val"
        query.expressionAttributeValues = [":val" : user.userId]
        dynamoDBObjectMapper.query(ChatRoom.self, expression: query)
            .continue(with: AWSExecutor.mainThread(), with: { task -> AnyObject! in
                if let error = task.error as? NSError {
                    completion?(.failure(error))
                    return nil
                }

                guard let rooms = task.result?.items as? [ChatRoom] else { fatalError() }
                completion?(.success(rooms))
                return nil
            })
    }

    func deleteChatRoom(with room: ChatRoom, completion: ((Error?) -> Void)?) {
        dynamoDBObjectMapper.remove(room)
            .continue(with: AWSExecutor.mainThread(), with: { task -> AnyObject! in
                completion?(task.error)
                return nil
            })
    }
}
