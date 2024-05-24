//
//  FirebaseManager.swift
//  Joyce Studios
//
//  Created by billkim on 2023/09/19.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabaseInternal
import UserNotifications
import FirebaseMessaging

public class FirebaseManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate, UIApplicationDelegate {
    private static let instance = FirebaseManager()
    
    @objc static let shared = FirebaseManager()
    
    private var isLoginedFireabse = false
    private var firebaseUid = ""
    
    private var firebaseCommonEmail = "firebase-common@joyce.com"
    private var firebaseCommonId = "Joyce1234!"
    
    public var pushToken = ""
    
    private var isLoggined = false
    
    private let gcmMessageIDKey = "gcm.message_id"
    
    //private var refRealtimeDB: DatabaseReference = Database.database().reference()
    
    public func initManager(application: UIApplication, completion: @escaping (_ resultCode: Int) -> Void) {
        FirebaseApp.configure()
        
        /*Messaging.messaging().token { token, error in
          if let error = error {
              LogManager.shared.pushLog(log: "[initManager] Error fetching FCM registration token: \(error)")
              //print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
              LogManager.shared.pushLog(log: "[initManager] token: \(token)")
              FirebaseManager.shared.pushToken = token
          }
        }*/
        
        // Firebase Messaging References : https://designcode.io/swiftui-advanced-handbook-push-notifications-part-2
        
        /*Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { granted, error in
              LogManager.shared.pushLog(log: "[requestAuthorization] granted : \(granted), error : \(error)")
              
              if let error = error {
                  
              } else {
                  DispatchQueue.main.async {
                      application.registerForRemoteNotifications()
                  }
              }
          }
        )*/

        //application.registerForRemoteNotifications()
        
        login(completion: completion)
    }
    
    public func login(completion: @escaping (_ resultCode: Int) -> Void) {
        if self.isLoggined {
            completion(0)
            
            return
        }
        
        FirebaseManager.shared.login(uid: firebaseCommonId, email: firebaseCommonEmail) { resultCode, fid in
            LogManager.shared.pushLog(log: "[login] resultCode : \(resultCode)")
            
            self.isLoggined = resultCode == 0
            
            Messaging.messaging().token { token, error in
              if let error = error {
                  LogManager.shared.pushLog(log: "[initManager] Error fetching FCM registration token: \(error)")
                  //print("Error fetching FCM registration token: \(error)")
              } else if let token = token {
                  LogManager.shared.pushLog(log: "[initManager] token: \(token)")
                  FirebaseManager.shared.pushToken = token
              }
            }
            
            completion(resultCode)
        }
    }
    
    public func getPushToken() -> String {
        return FirebaseManager.shared.pushToken
    }
}


// Firebase Messaging
extension FirebaseManager {
    public func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        LogManager.shared.pushLog(log: "[didRegisterForRemoteNotificationsWithDeviceToken] apnsToken : \(deviceToken)")
    }
    
    public func application(_ application: UIApplication,
                       didFailToRegisterForRemoteNotificationsWithError error: Error) {
        LogManager.shared.pushLog(log: "[didFailToRegisterForRemoteNotificationsWithError] Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    public func application(_ application: UIApplication,
                       didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }

        LogManager.shared.pushLog(log: "[didReceiveRemoteNotification] userInfo : \(userInfo)")
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        
        self.subscribeTopics()
        
        FirebaseManager.shared.pushToken = fcmToken ?? ""
        
        LogManager.shared.pushLog(log: "[didReceiveRegistrationToken] fcmToken : \(fcmToken)")
        
        Messaging.messaging().token { token, error in
          if let error = error {
              LogManager.shared.pushLog(log: "[didReceiveRegistrationToken] Error fetching FCM registration token: \(error)")
              //print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
              LogManager.shared.pushLog(log: "[didReceiveRegistrationToken] token: \(token)")
              FirebaseManager.shared.pushToken = token
          }
        }
    }
    
    func subscribeTopics() {
        Messaging.messaging().subscribe(toTopic: "topic-carfund-all") { error in
            //print("Subscribed to topic-jsapps-all")
        }
        
        Messaging.messaging().subscribe(toTopic: "topic-carfund-ios") { error in
            //print("Subscribed to topic-jsapps-ios")
        }
    }
}


// Auth
extension FirebaseManager {
    public func login(uid: String, email: String, completion: @escaping (_ resultCode: Int, _ fid: String) -> Void) {
        self.firebaseUid = ""
        self.isLoginedFireabse = false
        
        Auth.auth().signIn(withEmail: email, password: uid) { [weak self] authResult, error in
            LogManager.shared.pushLog(log: "[signIn] authResult : \(authResult), error : \(error)")
            
            if error == nil {
                let currentUser = Auth.auth().currentUser
                LogManager.shared.pushLog(log: "[signIn] currentUser : \(currentUser)")
                LogManager.shared.pushLog(log: "[signIn] currentUser?.uid : \(currentUser?.uid)")
                
                if currentUser?.uid == nil {
                    completion(JSErrorCode.invalidIdToken.rawValue, "")
                } else {
                    self?.isLoginedFireabse = true
                    self?.firebaseUid = currentUser!.uid
                    
                    completion(JSErrorCode.success.rawValue, currentUser!.uid)
                }
            } else {
                Auth.auth().createUser(withEmail: email, password: uid) { authResult, error in
                    LogManager.shared.pushLog(log: "[createUser] authResult : \(authResult), error : \(error)")
                    
                    let currentUser = Auth.auth().currentUser
                    LogManager.shared.pushLog(log: "[createUser] currentUser : \(currentUser)")
                    LogManager.shared.pushLog(log: "[createUser] currentUser?.uid : \(currentUser?.uid)")
                    
                    if error == nil {
                        if currentUser?.uid == nil {
                            completion(JSErrorCode.invalidIdToken.rawValue, "")
                        } else {
                            self?.isLoginedFireabse = true
                            self?.firebaseUid = currentUser!.uid
                            
                            completion(JSErrorCode.success.rawValue, currentUser!.uid)
                        }
                    } else {
                        completion(JSErrorCode.invalidIdToken.rawValue, "")
                    }
                }
            }
        }
    }
    
    public func logout() {
        do {
            self.isLoggined = false
            
            self.firebaseUid = ""
            self.isLoginedFireabse = false
            
            try Auth.auth().signOut()
        } catch {
            
        }
    }
    
    public func unregister(completion: @escaping (_ resultCode: Int) -> Void) {
        let currentUser = Auth.auth().currentUser
        
        currentUser?.delete(completion: { error in
            if error == nil {
                self.removeDataForRealtimeDB(child: self.firebaseUid)
                
                self.firebaseUid = ""
                self.isLoginedFireabse = false
                
                completion(0)
            } else {
                completion(JSErrorCode.fail.rawValue)
            }
        })
    }
}


// Firestore
extension FirebaseManager {
    public func getDataForRealtimeDB(child: String, queryLimited: Int = 0, completion: @escaping (_ value: Any?) -> Void) {
        var ref: DatabaseReference = Database.database().reference()
        
        if !self.isLoginedFireabse {
            LogManager.shared.pushLog(log: "[getDataForRealtimeDB] firebase is not logined.")
            return
        }
        
        var dbRef: DatabaseReference! = ref.child(child)
        
        if queryLimited > 0 {
            dbRef.queryLimited(toFirst: UInt(queryLimited)).getData(completion:  { error, snapshot in
                LogManager.shared.pushLog(log: "[getDataForRealtimeDB] child : \(child), error : \(error), snapshot : \(snapshot), value : \(snapshot?.value)")
                
                guard error == nil else {
                    LogManager.shared.pushLog(log: error!.localizedDescription)
                    completion(nil)
                    
                    return
                }
                
                completion(snapshot?.value)
            });
        } else if queryLimited < 0 {
            dbRef.queryLimited(toLast: UInt(-queryLimited)).getData(completion:  { error, snapshot in
                LogManager.shared.pushLog(log: "[getDataForRealtimeDB] child : \(child), error : \(error), snapshot : \(snapshot), value : \(snapshot?.value)")
                
                guard error == nil else {
                    LogManager.shared.pushLog(log: error!.localizedDescription)
                    completion(nil)
                    
                    return
                }
                
                completion(snapshot?.value)
            });
        } else {
            dbRef.getData(completion:  { error, snapshot in
                LogManager.shared.pushLog(log: "[getDataForRealtimeDB] child : \(child), error : \(error), snapshot : \(snapshot), value : \(snapshot?.value)")
                
                guard error == nil else {
                    LogManager.shared.pushLog(log: error!.localizedDescription)
                    completion(nil)
                    
                    return
                }
                
                completion(snapshot?.value)
            });
        }
    }
    
    public func observeDataForRealtimeDB(child: String, completion: @escaping (_ value: Any?) -> Void) {
        var ref: DatabaseReference = Database.database().reference()
        
        if !self.isLoginedFireabse {
            LogManager.shared.pushLog(log: "[observeDataForRealtimeDB] firebase is not logined.")
            return
        }
        
        var dbRef: DatabaseReference! = ref.child(child)
        
        dbRef.observe(DataEventType.value, with: { snapshot in
            LogManager.shared.pushLog(log: "[observeDataForRealtimeDB] (Value) child : \(child), snapshot : \(snapshot), value : \(snapshot.value)")
            
            completion(snapshot.value)
        })
        
        /*dbRef.observe(DataEventType.childAdded, with: { snapshot in
            LogManager.shared.pushLog(log: "[observeDataForRealtimeDB] (Added) child : \(child), snapshot : \(snapshot), value : \(snapshot.value)")
            
            completion(snapshot.value)
        })
        
        dbRef.observe(DataEventType.childRemoved, with: { snapshot in
            LogManager.shared.pushLog(log: "[observeDataForRealtimeDB] (Removed) child : \(child), snapshot : \(snapshot), value : \(snapshot.value)")
            
            completion(snapshot.value)
        })
        
        dbRef.observe(DataEventType.childChanged, with: { snapshot in
            LogManager.shared.pushLog(log: "[observeDataForRealtimeDB] (Changed) child : \(child), snapshot : \(snapshot), value : \(snapshot.value)")
            
            completion(snapshot.value)
        })*/
    }
    
    public func removeAllObservers(child: String, completion: @escaping (_ value: Any?) -> Void) {
        var ref: DatabaseReference = Database.database().reference()
        
        if !self.isLoginedFireabse {
            LogManager.shared.pushLog(log: "[removeAllObservers] firebase is not logined.")
            return
        }
        
        var dbRef: DatabaseReference! = ref.child(child)
        
        dbRef.removeAllObservers()
    }
    
    public func observeDataChangedForRealtimeDB(child: String, completion: @escaping (_ value: Any?) -> Void) {
        var ref: DatabaseReference = Database.database().reference()
        
        if !self.isLoginedFireabse {
            LogManager.shared.pushLog(log: "[observeDataChangedForRealtimeDB] firebase is not logined.")
            return
        }
        
        var dbRef: DatabaseReference! = ref.child(child)
        
        dbRef.observe(DataEventType.childAdded, with: { snapshot in
            LogManager.shared.pushLog(log: "[observeDataChangedForRealtimeDB] child : \(child), snapshot : \(snapshot), value : \(snapshot.value)")
            
            completion(snapshot.value)
        })
    }
    
    public func setDataForRealtimeDB(child: String, value: String) {
        var ref: DatabaseReference = Database.database().reference()
        
        if !self.isLoginedFireabse {
            LogManager.shared.pushLog(log: "[setDataForRealtimeDB] firebase is not logined.")
            return
        }
        
        LogManager.shared.pushLog(log: "[setDataForRealtimeDB] child : \(child), value : \(value)")
        
        ref.child(child).setValue(value)
    }
    
    public func removeDataForRealtimeDB(child: String) {
        var ref: DatabaseReference = Database.database().reference()
        
        if !self.isLoginedFireabse {
            LogManager.shared.pushLog(log: "[removeDataForRealtimeDB] firebase is not logined.")
            return
        }
        
        LogManager.shared.pushLog(log: "[removeDataForRealtimeDB] child : \(child)")
        
        ref.child(child).removeValue { error, _ in
            LogManager.shared.pushLog(log: "[removeDataForRealtimeDB] error : \(error)")
        }
    }
}
