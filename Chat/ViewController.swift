//
//  ViewController.swift
//  Chat
//
//  Created by Hanawa Takuro on 2016/08/30.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ViewController: UIViewController {

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var loginImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: FBSDKLoginButtonDelegate {

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }
}
