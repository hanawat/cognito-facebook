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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ChatRoomViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ChatRoomCell", for: indexPath)
    }
}

extension ChatRoomViewController: UITableViewDelegate {
    
}
