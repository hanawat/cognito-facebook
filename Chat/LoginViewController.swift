//
//  LoginViewController.swift
//  Chat
//
//  Created by Hanawa Takuro on 2016/08/30.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Keys

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var chatRoomButton: UIButton!

    var deviceToken: String?
    var chatUser: ChatUser?

    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]

        NotificationCenter.default.addObserver(self, selector: #selector(updateDeviceToken(_:)), name: .deviceTokenUpdated, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let chatRoomViewController = segue.destination as? ChatRoomViewController,
            let chatUser = self.chatUser else { return }

        chatRoomViewController.chatUser = chatUser
    }

    func updateDeviceToken(_ notification: Notification?) {
        guard let deviceToken = notification?.userInfo?["deviceToken"] as? String else { return }
        self.deviceToken = deviceToken

        guard let _ = FBSDKAccessToken.current() else { return }
        LoginService.login(deviceToken: deviceToken, completion: { loggedinUser in
            self.chatRoomButton.isEnabled = (loggedinUser != nil) ? true : false
            self.chatUser = loggedinUser
        })
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {

        guard error == nil, result.isCancelled == false,
            let deviceToken = self.deviceToken else { return }

        LoginService.login(deviceToken: deviceToken, completion: { loggedinUser in
            self.chatRoomButton.isEnabled = (loggedinUser != nil) ? true : false
            self.chatUser = loggedinUser
        })
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        chatRoomButton.isEnabled = false
    }
}
