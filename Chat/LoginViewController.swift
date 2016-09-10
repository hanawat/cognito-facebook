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
import AWSSNS
import AWSDynamoDB
import Keys

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var chatRoomButton: UIButton!

    var deviceToken: String?

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

    func login() {

        // Initialize the Amazon Cognito credentials provider
        guard let poolId = ChatKeys().cognitoIdentityPoolId() else { return }

        let providerManager = ChatLoginProviderManager()
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .apNortheast1, identityPoolId: poolId, identityProviderManager: providerManager)
        let configuration = AWSServiceConfiguration(region:.apNortheast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        guard let request = AWSSNSCreatePlatformEndpointInput() else { return }

        request.token = deviceToken
        request.platformApplicationArn = ChatKeys().sNSApplicationARN()

        AWSSNS.default().createPlatformEndpoint(request)
            .continue(successBlock: { task -> Any? in

                print("Created Endpoint")
                return task

            }).continue(with: .mainThread(), with: { task -> Any? in
                if let error = task.error {
                    print(error.localizedDescription)
                    return nil
                }

                self.chatRoomButton.isEnabled = true
                guard let id = credentialsProvider.identityId, let endpoint = task.result?.endpointArn! else {
                    return nil
                }

                self.createUser(id: id, endpoint: endpoint, completion: { user, error in
                    if error == nil, let model = user {
                    AWSDynamoDBObjectMapper.default().save(model)
                    } else { return }
                })
                return nil
            })
    }

    func updateDeviceToken(_ notification: Notification?) {
        guard let deviceToken = notification?.userInfo?["deviceToken"] as? String else { return }
        self.deviceToken = deviceToken

        guard let _ = FBSDKAccessToken.current() else { return }
        self.login()
    }

    func createUser(id: String, endpoint: String, completion: @escaping (_ user: ChatUser?, _ error: Error?) -> Void) {

        FBSDKProfile.loadCurrentProfile { (profile, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "Unknown Error")
                completion(nil, error); return
            }

            // TODO: Dynamo
            guard let name = profile?.name,
                let imageUrl = profile?.imageURL(for: FBSDKProfilePictureMode.square, size: CGSize(width: 50, height: 50)) else {
                    completion(nil, NSError(domain: "", code: -1, userInfo: nil)); return
            }

            let user = ChatUser()
            user?.id = id
            user?.name = name
            user?.imageUrl = imageUrl.absoluteString
            user?.endpoint = endpoint
            completion(user, nil)
        }
    }
}

class ChatLoginProviderManager: NSObject, AWSIdentityProviderManager {

    func logins() -> AWSTask<NSDictionary> {

        guard let facebookToken = FBSDKAccessToken.current() else {

            // TODO: Return Error
            let error = NSError(domain: "", code: -1, userInfo: nil) as Error
            return AWSTask(error: error)
        }

        let providers = [AWSIdentityProviderFacebook: facebookToken.tokenString] as NSDictionary
        return AWSTask(result: providers)
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {

        guard error == nil, result.isCancelled == false else { return }
        login()
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        chatRoomButton.isEnabled = false
    }
}
