# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

target 'Chat' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Chat
  pod 'FBSDKLoginKit'
  pod 'AWSCognito'
  pod 'AWSSNS'
  pod 'AWSDynamoDB'
  pod 'JSQMessagesViewController'

end

plugin 'cocoapods-keys', {
  :project => "Chat",
  :keys => [
    "CognitoIdentityPoolId"
  ]
}
