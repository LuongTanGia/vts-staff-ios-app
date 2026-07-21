//
//  VTS_STAFFApp.swift
//  VTS_STAFF
//
//  Created by viettas on 20/6/26.
//

import SwiftUI
import FirebaseCore
import UserNotifications
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate  {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        // 1. Cấu hình Firebase App mặc định từ file GoogleService-Info.plist
        FirebaseApp.configure()
        
        // 2. Gán Delegate cho Firebase Messaging để lắng nghe sự thay đổi của Token
        Messaging.messaging().delegate = self

        // 3. Gán Delegate cho UNUserNotificationCenter để hiển thị/xử lý thông báo đẩy trong App
        UNUserNotificationCenter.current().delegate = self

        // 4. Xin quyền hiển thị thông báo (Alert, Badge, Sound) từ phía người dùng
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in

            if let error = error {
                print("Notification permission error:", error)
            }

            print("Permission granted status:", granted)
        }

        // 5. Đăng ký nhận Remote Notification từ Apple APNs (Sinh ra APNs Device Token)
        application.registerForRemoteNotifications()

        return true
    }

    // MARK: - APNs Device Token Callback
    // Gọi khi thiết bị đăng ký thành công với cổng thông báo Apple APNs và trả về Device Token dạng raw Data
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("✅ APNs Token received")
        
        // 1. Liên kết token này với Firebase Messaging để có thể gửi thông báo FCM tới máy
        Messaging.messaging().apnsToken = deviceToken
        
        // 2. Gửi thông báo cục bộ trong App để giao diện ContentView biết và lấy FCM token thủ công
        NotificationCenter.default.post(
            name: Notification.Name("APNSTokenReceived"),
            object: nil
        )
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ APNs Register Error:", error)
    }

    // MARK: - Firebase Messaging Delegate (Lắng nghe FCM Token mới)
    // Được gọi khi Firebase Messaging cấp phát thành công hoặc làm mới (refresh) FCM Registration Token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("✅ FCM Registration Token: \(String(describing: fcmToken))")
        if let fcmToken = fcmToken {
            // 1. Lưu lại token này vào bộ nhớ tạm UserDefaults để hiển thị lên màn hình
            UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
            
            // 2. Phát thông báo báo giao diện ContentView cập nhật lại giao diện người dùng
            NotificationCenter.default.post(
                name: Notification.Name("FCMTokenUpdated"),
                object: nil,
                userInfo: ["token": fcmToken]
            )
        }
    }

    // MARK: - UNUserNotificationCenterDelegate (Xử lý thông báo khi App mở)
    
    // Được gọi khi thông báo đẩy đến khi ứng dụng đang chạy ở Foreground (ở trên màn hình)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        print("Foreground notification received: \(userInfo)")
        
        // 1. Nếu đây là thông báo local do chính App tự tạo để hiển thị banner, cho phép hiển thị
        if userInfo["isLocalNotification"] as? Bool == true {
            completionHandler([.banner, .list, .sound, .badge])
            return
        }
        
        // 2. Nếu là thông báo remote từ Firebase có custom payload: MsgTitle & MsgData
        if let msgTitle = userInfo["MsgTitle"] as? String {
            let content = UNMutableNotificationContent()
            content.title = msgTitle
            content.body = userInfo["MsgData"] as? String ?? ""
            content.sound = UNNotificationSound.default
            
            // Đính kèm các data ban đầu + đánh dấu là local notification để tránh lặp vô hạn
            var localUserInfo = userInfo
            localUserInfo["isLocalNotification"] = true
            content.userInfo = localUserInfo
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error presenting custom foreground notification: \(error)")
                }
            }
            
            // Không hiển thị banner của notification remote gốc (vì không có phần alert content chuẩn)
            completionHandler([])
        } else {
            // Trường hợp thông báo remote thông thường khác có sẵn aps.alert
            completionHandler([.banner, .list, .sound, .badge])
        }
    }

    // Được gọi khi người dùng nhấp (tap) vào banner thông báo đẩy từ thanh trạng thái
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped: \(userInfo)")
        completionHandler()
    }

    // MARK: - Xử lý thông báo đẩy chạy ngầm (Background) hoặc tắt ứng dụng hoàn toàn (Closed/Terminated)
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("Background/Terminated remote notification received: \(userInfo)")
        
        // Nếu app đang active ở Foreground, bỏ qua vì willPresent đã xử lý
        if application.applicationState == .active {
            completionHandler(.noData)
            return
        }
        
        // Nếu là thông báo remote từ Firebase có custom payload: MsgTitle & MsgData
        if let msgTitle = userInfo["MsgTitle"] as? String {
            let content = UNMutableNotificationContent()
            content.title = msgTitle
            content.body = userInfo["MsgData"] as? String ?? ""
            content.sound = UNNotificationSound.default
            
            var localUserInfo = userInfo
            localUserInfo["isLocalNotification"] = true
            content.userInfo = localUserInfo
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error presenting background local notification: \(error)")
                }
            }
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }

}


@main
struct VTS_STAFFApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
