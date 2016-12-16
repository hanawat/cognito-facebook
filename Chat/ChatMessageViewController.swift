//
//  ChatMessageViewController.swift
//  Chat
//
//  Created by Hanawa Takuro on 2016/12/16.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import AWSDynamoDB

class ChatMessageViewController: JSQMessagesViewController {

    var user: ChatUser! {
        didSet {
            senderId = user.userId
            senderDisplayName = user.userName
        }
    }

    var room: ChatRoom!

    fileprivate var messages = [ChatMessage]()
    fileprivate var users = [ChatUser]()
    fileprivate var iconSet = [String : JSQMessagesAvatarImage]()
    fileprivate var othersBubble: JSQMessagesBubbleImage!
    fileprivate var myBubble: JSQMessagesBubbleImage!
    fileprivate var othersAvator: JSQMessagesAvatarImage!
    fileprivate var myAvator: JSQMessagesAvatarImage!
    fileprivate let messageService = ChatMessageService()

    override func viewDidLoad() {
        super.viewDidLoad()

        let bubbleFactory = JSQMessagesBubbleImageFactory()
        othersBubble = bubbleFactory?.incomingMessagesBubbleImage(with: .jsq_messageBubbleBlue())
        myBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: .jsq_messageBubbleGreen())
        othersAvator = JSQMessagesAvatarImageFactory.avatarImage(with: #imageLiteral(resourceName: "OthersAvatar"), diameter: 64)
        inputToolbar.contentView.leftBarButtonItem = nil

        NotificationCenter.default.addObserver(self, selector: #selector(onPushNotificationReceived(_:)), name: NSNotification.Name(rawValue: "MessageUpdated"), object: nil)

        reloadMessages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func onPushNotificationReceived(_ notification: Notification?) {
    }

    fileprivate func reloadMessages() {

        messageService.getMessages(room: room, lastMessage: messages.last, completion: { result in

            switch result {
            case .success(let messages):
                self.messages.append(contentsOf: messages)

            case .failure(let error):
                print(error)
            }

            let unknownUserIds = self.getUnknownUserIds(messages: self.messages, knownUsers: self.users)
            self.messageService.getUsers(userIds: unknownUserIds, completion: { result in

                switch result {
                case .success(let unknownUsers):
                    self.users.append(contentsOf: unknownUsers)

                    unknownUsers.forEach { unknownUser in

                        let image = URL(string: unknownUser.userImageUrl).flatMap({ (try? Data(contentsOf: $0)) }).flatMap({ UIImage(data: $0) }) ?? #imageLiteral(resourceName: "MyAvatar")
                        self.iconSet[unknownUser.userId] = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 64)

                        if unknownUser.userId == self.user.userId {
                            self.myAvator = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 64)
                        } else {

                        }
                    }

                    self.finishReceivingMessage()

                case .failure(let error):
                    print(error)
                }
            })
        })
    }

    func getUnknownUserIds(messages: [ChatMessage], knownUsers: [ChatUser]) -> [String] {
        let knownUserIds = knownUsers.map { $0.userId }
        let unknownUserIds = messages.reduce([]) { acc, message -> [String] in
            var acc = acc
            let userId = message.userId
            if !knownUserIds.contains(userId) && !acc.contains(userId) {
                acc.append(message.userId)
            }
            return acc
        }
        return unknownUserIds
    }
}

extension ChatMessageViewController {

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {

        JSQSystemSoundPlayer.jsq_playMessageSentAlert()
        messageService.saveMessage(text: text, user: user, room: room, completion: { result in
            switch result {
            case .success:
                self.finishSendingMessage(animated: true)
                self.reloadMessages()
            case .failure(let error):
                print(error)
            }
        })
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {

        let message = messages[indexPath.row]
        guard let user = users.filter({$0.userId == message.userId}).first else { fatalError() }

        let date = Date(timeIntervalSince1970: TimeInterval(message.time))
        return JSQMessage(senderId: user.userId, senderDisplayName: user.userName, date: date, text: message.text)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {

        let message = messages[indexPath.row]
        if message.userId == senderId {
            return myBubble
        } else {
            return othersBubble
        }
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {

        let message = messages[indexPath.row]
        if message.userId == senderId {
            return myAvator
        } else {
            if let iconImage = iconSet[message.userId] {
                return iconImage
            } else {
                return othersAvator
            }
        }
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {

        let date = Date(timeIntervalSince1970: TimeInterval(messages[indexPath.item].time))
        let previousDate = Date(timeIntervalSince1970: TimeInterval(messages[indexPath.item].time))
        guard indexPath.item == 0 || date.timeIntervalSince(previousDate) / 60.0 > 1.0 else {
            return NSAttributedString()
        }

        return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: date)
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {

        let date = Date(timeIntervalSince1970: TimeInterval(messages[indexPath.item].time))
        let previousDate = Date(timeIntervalSince1970: TimeInterval(messages[indexPath.item].time))
        guard indexPath.item == 0 || date.timeIntervalSince(previousDate) / 60.0 > 1.0 else {
            return 0.0
        }

        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}
