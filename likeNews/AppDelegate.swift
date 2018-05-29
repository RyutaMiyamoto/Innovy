//
//  AppDelegate.swift
//  likeNews
//
//  Created by R.miyamoto on 2017/07/25.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit
import HockeySDK
import Firebase
import SVProgressHUD
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 初期設定
        initSetting(application: application)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return Twitter.sharedInstance().application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Push通知設定
        Messaging.messaging().apnsToken = deviceToken
    }

    /// 初期設定
    ///
    /// - Parameter application: application
    private func initSetting(application: UIApplication) {
        // Firebase初期設定
        FirebaseApp.configure()
        
        // Push通知設定
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
        application.registerForRemoteNotifications()
        
        // Twitter設定
        Twitter.sharedInstance().start(withConsumerKey:Bundle.Api(key: .twitterConsumerKey), consumerSecret:Bundle.Api(key: .twitterConsumerSecret))
        
        // 古い記事を削除
        NewsListModel().removeOldArticles()
        
        // NavigationBarの初期設定
        setNavigationBar()
        
        // HockeyAppの初期設定
        BITHockeyManager.shared().configure(withIdentifier: Bundle.HockeyApp(key: .Id))
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
        
        // SVProgressHUDの設定
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.resetOffsetFromCenter()
        SVProgressHUD.setBackgroundColor(#colorLiteral(red: 0.9656466209, green: 0.9752074785, blue: 0.9752074785, alpha: 1))
        
        // NavigationBar設定
        UINavigationBar.appearance().tintColor = UIColor.titleFont()
    }
    
    /// NavigationBarの初期設定
    func setNavigationBar() {
        // NavigationBarの下線を消す
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }
}

