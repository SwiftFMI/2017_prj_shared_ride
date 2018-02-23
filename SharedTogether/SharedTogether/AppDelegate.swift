//
//  AppDelegate.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 8.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import KVNProgress

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    //change root view controller on window
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var chatIsActive = false

    // MARK: - Remote notifications
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//        center.removeAllDeliveredNotifications()
//        center.removeAllPendingNotificationRequests()
//        if UIApplication.shared.applicationState == .active {
//
//            if chatIsActive {
//                return
//            }
//        }
//        
//        completionHandler(.alert)
//    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        let token = Messaging.messaging().fcmToken
        
        if let fbToken = token, var user = Defaults.getLoggedUser() {
            Database.database().reference()
                .child(Constants.Users.ROOT)
                .child(user.id)
                .updateChildValues([Constants.Users.NOTIFICATIONS_TOKEN: fbToken], withCompletionBlock: {(error, dbReference) in
                    if error == nil {
                        user.notificationsToken = fbToken
                        Defaults.setLoggedUser(user: user)
                    }
                })
        }
        print("FCM token: \(token ?? "")")
        
        // KVNProgress
        let configuration = KVNProgressConfiguration()
        configuration.isFullScreen = true
        let color = UIColor(red: 86/255, green: 190/255, blue: 197/255, alpha: 1.0)
        configuration.circleStrokeForegroundColor = color
        configuration.circleStrokeBackgroundColor = UIColor.lightGray
        configuration.statusColor = UIColor.darkText
        
        KVNProgress.setConfiguration(configuration)
        
        return true
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        //if there is a logged user register its token
        if var user = Defaults.getLoggedUser() {
            Database.database().reference()
                .child(Constants.Users.ROOT)
                .child(user.id)
                .updateChildValues([Constants.Users.NOTIFICATIONS_TOKEN: fcmToken], withCompletionBlock: {(error, dbReference) in
                    if error == nil {
                        user.notificationsToken = fcmToken
                        Defaults.setLoggedUser(user: user)
                    }
                })
        }
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}

