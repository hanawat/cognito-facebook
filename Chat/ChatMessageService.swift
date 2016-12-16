//
//  ChatMessageService.swift
//  Chat
//
//  Created by Hanawa Takuro on 2016/12/16.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ChatMessageService {

    fileprivate lazy var dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()

    func saveMessage(text: String, user: ChatUser, room: ChatRoom, completion: ((Result<ChatMessage, NSError>) -> Void)?) {

        guard let message = ChatMessage() else { fatalError() }
        message.messageId = String(Date().timeIntervalSince1970 * 100000)
        message.roomId = room.roomId
        message.userId = user.userId
        message.text = text
        message.time = Int(Date().timeIntervalSince1970)

        dynamoDBObjectMapper.save(message).continue(with: AWSExecutor.mainThread(), with: { task -> AnyObject? in
            if let error = task.error as? NSError {
                print(error)
                completion?(.failure(error))
                return nil
            }

            completion?(.success(message))
            return nil
        })
    }

    func getMessages(room: ChatRoom, lastMessage: ChatMessage? = nil, completion: ((Result<[ChatMessage], NSError>) -> Void)?) {

        let query = AWSDynamoDBQueryExpression()

        // Searching room id and filtering with message id
        query.keyConditionExpression = "roomId = :roomId AND messageId > :messageId"

        let lastMessageId = lastMessage?.messageId ?? "0"
        query.expressionAttributeValues = [":roomId" : room.roomId, ":messageId" : lastMessageId]
        query.limit = 10
        query.scanIndexForward = false

        dynamoDBObjectMapper.query(ChatMessage.self, expression: query)
            .continue(with: AWSExecutor.mainThread(), with: { task -> AnyObject? in
                if let error = task.error as? NSError {
                    print(error)
                    completion?(.failure(error))
                    return nil
                }

                guard let messages = task.result?.items as? [ChatMessage] else { fatalError() }
                completion?(.success(messages.reversed()))
                return nil
            })
    }

    func getUsers(userIds: [String], completion: ((Result<[ChatUser], NSError>) -> Void)?) {

        let tasks = userIds.map { userId -> AWSTask<AnyObject> in
            dynamoDBObjectMapper.load(ChatUser.self, hashKey: userId, rangeKey: nil)
        }

        AWSTask<NSArray>(forCompletionOfAllTasksWithResults: tasks)
            .continue(with: AWSExecutor.mainThread(), with: { task -> AnyObject? in

            if let error = task.error as? NSError {
                completion?(.failure(error))
                return nil
            }

            guard let users = task.result as? [ChatUser] else { fatalError() }
            completion?(.success(users))
            return nil
        })
    }
}
