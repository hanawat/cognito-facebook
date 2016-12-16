//
//  ChatRoomViewController.swift
//  Chat
//
//  Created by Hanawa Takuro on 2016/09/11.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit

class ChatRoomViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var chatUser: ChatUser!
    var chatRooms = [ChatRoom]()

    fileprivate let roomsService = ChatRoomService()

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadRooms()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier , identifier == "EnterChatRoom",
            let destination = segue.destination as? ChatMessageViewController,
            let selectedRow = tableView.indexPathForSelectedRow?.row else { fatalError() }

        destination.user = chatUser
        destination.room = chatRooms[selectedRow]
    }

    @IBAction func createChatRoom(_ sender: UIBarButtonItem) {
        let alert = createRoomAlert()
        present(alert, animated: true, completion: nil)
    }

    fileprivate func reloadRooms() {
        roomsService.getChatRooms(with: self.chatUser, completion: { result in
            switch result {
            case .success(let rooms):
                self.chatRooms = rooms
                self.tableView.reloadData()

            case .failure(let error):
                print(error)
            }
        })
    }

    fileprivate func createRoomAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Create Chat Room", message: "Input room ID and Name", preferredStyle: .alert)

        let textFieldNames = [ "Room ID", "Room Name" ]
        textFieldNames.forEach { (textFieldName) in
            alert.addTextField { (textField) in
                textField.placeholder = textFieldName
            }
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { action in

            if let textFields =  alert.textFields , textFields.count == textFieldNames.count {
                guard let roomId = textFields[0].text, let roomName = textFields[1].text else { fatalError() }

                self.roomsService.saveChatRoom(id: roomId, name: roomName, user: self.chatUser, completion: { result in

                    switch result {
                    case .success:
                        self.reloadRooms()

                    case .failure(let error):
                        print(error)
                    }
                })
            }
        }))

        return alert
    }
}

extension ChatRoomViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let chatRoom = chatRooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomCell", for: indexPath)
        cell.textLabel?.text = chatRoom.roomName

        return cell
    }
}
