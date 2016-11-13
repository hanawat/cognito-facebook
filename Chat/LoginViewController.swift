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
        LoginService.login(deviceToken: deviceToken, completion: { result in

            switch result {
            case .success(let user):
                self.chatRoomButton.isEnabled = true
                self.chatUser = user
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {

        guard error == nil, result.isCancelled == false,
            let deviceToken = self.deviceToken else { return }

        LoginService.login(deviceToken: deviceToken, completion: { result in

            switch result {
            case .success(let user):
                self.chatRoomButton.isEnabled = true
                self.chatUser = user
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {

        DispatchQueue.main.async {
            self.chatRoomButton.isEnabled = false
        }
    }
}
