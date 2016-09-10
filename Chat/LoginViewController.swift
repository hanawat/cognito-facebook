//
//  LoginViewController.swift
//  Chat
//
//  Created by Hanawa Takuro on 2016/08/30.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import AWSCognito
import Keys

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: FBSDKLoginButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class ChatLoginProviderManager: NSObject, AWSIdentityProviderManager {

    func logins() -> AWSTask<NSDictionary> {

        guard let fbtoken = FBSDKAccessToken.current().tokenString else {

            // TODO: Return Error
            return AWSTask(error: NSError())
        }

        let providers = [AWSIdentityProviderFacebook: fbtoken] as NSDictionary
        return AWSTask(result: providers)
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {

        guard error == nil, result.isCancelled == false else { return }

        // Initialize the Amazon Cognito credentials provider
        guard let poolId = ChatKeys().cognitoIdentityPoolId() else { return }

        let providerManager = ChatLoginProviderManager()
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .apNortheast1, identityPoolId: poolId, identityProviderManager: providerManager)
        let configuration = AWSServiceConfiguration(region:.apNortheast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        credentialsProvider.credentials().continue(successBlock: { task -> Any? in
            return nil
        })
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
}
