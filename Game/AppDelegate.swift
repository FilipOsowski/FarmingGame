//
//  AppDelegate.swift
//  Game Test 2
//
//  Created by Cat Blue on 9/21/17.
//
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Notifications granted.")
            } else {
                print(error!.localizedDescription)
            }
        }
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "saveGameData"), object: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "scheduleNotifications"), object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

