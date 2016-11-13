//
//  LoginService.swift
//  Chat
//
//  Created by Hanawa Takuro on 2016/11/13.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import AWSCognito
import AWSSNS
import AWSDynamoDB
import FBSDKLoginKit
import Keys

class LoginService {

    typealias CreateChatUser = (_ user: ChatUser?, _ error: Error?) -> Void

    class func login(deviceToken: String, completion: @escaping (_ loggedinUser: ChatUser?) -> Void) {

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
                    completion(nil)
                    return nil
                }

                guard let id = credentialsProvider.identityId, let endpoint = task.result?.endpointArn! else {
                    completion(nil)
                    return nil
                }

                self.createUser(id: id, endpoint: endpoint, completion: { user, error in
                    if error == nil, let model = user {
                        AWSDynamoDBObjectMapper.default().save(model)
                        completion(model)
                    } else {
                        completion(nil)
                        return
                    }
                })

                return nil
            })
    }

    fileprivate class func createUser(id: String, endpoint: String, completion: @escaping CreateChatUser)  {

        FBSDKProfile.loadCurrentProfile { (profile, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "Unknown Error")
                completion(nil, error); return
            }

            guard let name = profile?.name,
                let imageUrl = profile?.imageURL(for: FBSDKProfilePictureMode.square, size: CGSize(width: 50, height: 50)) else {
                    completion(nil, NSError(domain: "", code: -1, userInfo: nil)); return
            }

            let user = ChatUser()
            user?.userId = id
            user?.userName = name
            user?.userImageUrl = imageUrl.absoluteString
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
