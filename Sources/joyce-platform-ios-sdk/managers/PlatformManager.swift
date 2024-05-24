//
//  PlatformManager.swift
//  Joyce Studios
//
//  Created by billkim on 2023/09/19.
//

import Foundation

public class PlatformManager: NSObject {
    private static let instance = PlatformManager()
    
    @objc static let shared = PlatformManager()
    
    private let hostUrl = "https://us-central1-carfund-f5102.cloudfunctions.net"
    
    enum ApiUris: String {
        case apiSendPush = "/sendPush"
        case apiSendPushToken = "/sendPushToken"
        case apiSetData = "/setData"
        case apiGetData = "/getData"
    }
    
    enum ApiRootNames: String {
        case rootInstalls = "installs"
        case rootDau = "dau"
        case rootUpdates = "updates"
        case rootSales = "sales"
        case rootEvents = "events"
    }
    
    private var appName = ""
    private let uuid = Util.getUuid()
    //private let date = Util.getCurrentDateString()
    
    private var checkNotifications = false
    private var notificationForDau = false
    private var notificationForInstalls = false
    private var notificationForUpdates = false
    private var notificationForSales = false
    private var notificationForEvents = false
    
    public func initManager(appName: String) {
        self.appName = appName
        self.checkNotifications = false
        
        FirebaseManager.shared.login { resultCode in
            if resultCode == 0 {
                self.checkNotifications { resultCode in
                    self.checkInstalls()
                }
            }
        }
    }
    
    private func checkInstalls() {
        let first = Util.checkFirstInstall()
        
        if first {
            Util.checkAppUpdate()
            PlatformManager.shared.setDataForInstalls()
            //PlatformManager.shared.sendPush(topic: "topic-jsapps-ios", title: "", message: "first intalled")
        } else {
            let isAppUpdate = Util.checkAppUpdate()
            
            if isAppUpdate {
                PlatformManager.shared.setDataForUpdates()
            }
        }
    }

    public func sendPush(topic: String, title: String, message: String) {
        var url = hostUrl
        let uri = ApiUris.apiSendPush.rawValue
                
        url += uri
        url += "?topic=\(topic)&title=\(title)&message=\(message)"
        
        LogManager.shared.pushLog(log: "[sendPush] url : \(url)")
        
        NetworkManager.shared.requestGet(url: url) { response in
            LogManager.shared.pushLog(log: "[sendPush] response : \(response)")
        }
    }
    
    public func sendPushForToken(token: String, title: String, message: String, link: String) {
        var url = hostUrl
        let uri = ApiUris.apiSendPushToken.rawValue
                
        url += uri
        url += "?token=\(token)&title=\(title)&message=\(message)&link=\(link)"
        
        LogManager.shared.pushLog(log: "[sendPushForToken] url : \(url)")
        
        NetworkManager.shared.requestGet(url: url) { response in
            LogManager.shared.pushLog(log: "[sendPushForToken] response : \(response)")
        }
    }
    
    public func didForegroundApp() {
        FirebaseManager.shared.login { resultCode in
            if resultCode == 0 {
                self.checkNotifications { resultCode in
                    self.setDataForDau()
                }
            }
        }
    }
    
    public func didBackgroundApp() {
        
    }
    
    private func setDataForInstalls() {
        var url = hostUrl
        let uri = ApiUris.apiSetData.rawValue
        
        let root = ApiRootNames.rootInstalls.rawValue
        let timestamps = Util.getCurrentTimestamps()
        
        let buildType = (Util.isAppstoreBuild()) ? "/": "-dev/"
        let version = Util.getVersionRaw().replacingOccurrences(of: ".", with: "-")
        
        let date = Util.getCurrentDateString()
        
        url += uri
        url += "?appName=\(appName)&key=" + root + buildType + date + "/\(version)/" + uuid + "/" + "&value=" + timestamps.description
        
        LogManager.shared.pushLog(log: "[setDataForInstalls] url : \(url)")
                                  
        NetworkManager.shared.requestGet(url: url) { response in
            LogManager.shared.pushLog(log: "[setDataForInstalls] response : \(response)")
        }
        
        LogManager.shared.pushLog(log: "[setDataForInstalls] notificationForInstalls : \(PlatformManager.shared.notificationForInstalls)")
        
        if PlatformManager.shared.notificationForInstalls {
            let appName = appName
            let platform = "ios"
            let buildType = "-" + Util.getBuildType().rawValue.lowercased()
            //let buildType = Util.isAppstoreBuild() ? "": "-" + Util.getBuildType().rawValue.lowercased()
            let dates = Util.getCurrentDateString()
            let child = "jsapps/" + appName.appending("/\(root)\(buildType)/\(dates)/\(version)")
            
            FirebaseManager.shared.getDataForRealtimeDB(child: child) { value in
                LogManager.shared.pushLog(log: "[setDataForInstalls] value : \(value)")
                
                let versionInfo = version.replacingOccurrences(of: "-", with: ".")
                
                let title = "[\(appName)]"
                var message = "\(platform) 앱에서 Installs 이벤트가 발생하였습니다. (\(1)) \n[\(Util.getBuildType().rawValue) - \(versionInfo)]"
                
                if value is NSNull {
                    self.sendPush(topic: "topic-jsapps-all", title: title, message: message)
                    return
                }
                
                let dic = value as! [String: Any]
                LogManager.shared.pushLog(log: "[setDataForInstalls] dic.count : \(dic.count)")
                
                message = "\(platform) 앱에서 Installs 이벤트가 발생하였습니다. (\(dic.count)) \n[\(Util.getBuildType().rawValue) - \(versionInfo)]"
                
                self.sendPush(topic: "topic-jsapps-all", title: title, message: message)
            }
        }
    }
    
    private func setDataForDau() {
        var url = hostUrl
        let uri = ApiUris.apiSetData.rawValue
        
        let root = ApiRootNames.rootDau.rawValue
        let timestamps = Util.getCurrentTimestamps()
        
        let buildType = (Util.isAppstoreBuild()) ? "/": "-dev/"
        let version = Util.getVersionRaw().replacingOccurrences(of: ".", with: "-")
        
        let date = Util.getCurrentDateString()
        
        url += uri
        url += "?appName=\(appName)&key=" + root + buildType + date + "/\(version)/" + uuid + "/" + "&value=" + timestamps.description
        
        LogManager.shared.pushLog(log: "[setDataForDau] url : \(url)")
                                  
        NetworkManager.shared.requestGet(url: url) { response in
            LogManager.shared.pushLog(log: "[setDataForDau] response : \(response)")
        }
        
        LogManager.shared.pushLog(log: "[setDataForDau] notificationForDau : \(PlatformManager.shared.notificationForDau)")
        
        if PlatformManager.shared.notificationForDau {
            let appName = appName
            let platform = "ios"
            let buildType = "-" + Util.getBuildType().rawValue.lowercased()
            //let buildType = Util.isAppstoreBuild() ? "": "-" + Util.getBuildType().rawValue.lowercased()
            let dates = Util.getCurrentDateString()
            let child = "jsapps/" + appName.appending("/\(root)\(buildType)/\(dates)/\(version)")
            
            FirebaseManager.shared.getDataForRealtimeDB(child: child) { value in
                LogManager.shared.pushLog(log: "[setDataForDau] value : \(value)")
                
                let versionInfo = version.replacingOccurrences(of: "-", with: ".")
                
                let title = "[\(appName)]"
                var message = "\(platform) 앱에서 DAU 이벤트가 발생하였습니다. (\(1)) \n[\(Util.getBuildType().rawValue) - \(versionInfo)]"
                
                if value is NSNull {
                    self.sendPush(topic: "topic-jsapps-all", title: title, message: message)
                    return
                }
                
                let dic = value as! [String: Any]
                LogManager.shared.pushLog(log: "[setDataForDau] dic.count : \(dic.count)")
                
                message = "\(platform) 앱에서 DAU 이벤트가 발생하였습니다. (\(dic.count)) \n[\(Util.getBuildType().rawValue) - \(versionInfo)]"
                
                self.sendPush(topic: "topic-jsapps-all", title: title, message: message)
            }
        }
    }
    
    private func setDataForUpdates() {
        var url = hostUrl
        let uri = ApiUris.apiSetData.rawValue
        
        let root = ApiRootNames.rootUpdates.rawValue
        let timestamps = Util.getCurrentTimestamps()
        
        let buildType = (Util.isAppstoreBuild()) ? "/": "-dev/"
        let version = Util.getVersionRaw().replacingOccurrences(of: ".", with: "-")
        
        let date = Util.getCurrentDateString()
        
        url += uri
        url += "?appName=\(appName)&key=" + root + buildType + date + "/\(version)/" + uuid + "/" + "&value=" + timestamps.description
        
        LogManager.shared.pushLog(log: "[setDataForUpdates] url : \(url)")
                                  
        NetworkManager.shared.requestGet(url: url) { response in
            LogManager.shared.pushLog(log: "[setDataForUpdates] response : \(response)")
        }
        
        LogManager.shared.pushLog(log: "[setDataForUpdates] notificationForUpdates : \(PlatformManager.shared.notificationForUpdates)")
        
        if PlatformManager.shared.notificationForUpdates {
            let appName = appName
            let platform = "ios"
            let buildType = "-" + Util.getBuildType().rawValue.lowercased()
            //let buildType = Util.isAppstoreBuild() ? "": "-" + Util.getBuildType().rawValue.lowercased()
            let dates = Util.getCurrentDateString()
            let child = "jsapps/" + appName.appending("/\(root)\(buildType)/\(dates)/\(version)")
            
            FirebaseManager.shared.getDataForRealtimeDB(child: child) { value in
                LogManager.shared.pushLog(log: "[setDataForUpdates] value : \(value)")
                
                let versionInfo = version.replacingOccurrences(of: "-", with: ".")
                
                let title = "[\(appName)]"
                var message = "\(platform) 앱에서 Updates 이벤트가 발생하였습니다. (\(1)) \n[\(Util.getBuildType().rawValue) - \(versionInfo)]"
                
                if value is NSNull {
                    self.sendPush(topic: "topic-jsapps-all", title: title, message: message)
                    return
                }
                
                let dic = value as! [String: Any]
                LogManager.shared.pushLog(log: "[setDataForUpdates] dic.count : \(dic.count)")
                
                message = "\(platform) 앱에서 Updates 이벤트가 발생하였습니다. (\(dic.count)) \n[\(Util.getBuildType().rawValue) - \(versionInfo)]"
                
                self.sendPush(topic: "topic-jsapps-all", title: title, message: message)
            }
        }
    }
    
    private func setDataForSales(type: String, productName: String, price: String) {
        var url = hostUrl
        let uri = ApiUris.apiSetData.rawValue
        
        let root = ApiRootNames.rootSales.rawValue
        let timestamps = Util.getCurrentTimestamps()
        
        let buildType = (Util.isAppstoreBuild()) ? "/": "-dev/"
        let version = Util.getVersionRaw().replacingOccurrences(of: ".", with: "-")
        
        let date = Util.getCurrentDateString()
        
        url += uri
        url += "?appName=\(appName)&key=" + root + buildType + date + "/\(version)/" + uuid + "/" + "\(type)/\(productName)" + "&value=" + price
        
        LogManager.shared.pushLog(log: "[setDataForSales] url : \(url)")
                                  
        NetworkManager.shared.requestGet(url: url) { response in
            LogManager.shared.pushLog(log: "[setDataForSales] response : \(response)")
        }
        
        LogManager.shared.pushLog(log: "[setDataForSales] notificationForSales : \(PlatformManager.shared.notificationForSales)")
        
        if PlatformManager.shared.notificationForSales {
            let appName = appName
            let platform = "ios"
            let buildType = "-" + Util.getBuildType().rawValue.lowercased()
            //let buildType = Util.isAppstoreBuild() ? "": "-" + Util.getBuildType().rawValue.lowercased()
            let dates = Util.getCurrentDateString()
            let child = "jsapps/" + appName.appending("/\(root)\(buildType)/\(dates)/\(version)")
            
            FirebaseManager.shared.getDataForRealtimeDB(child: child) { value in
                LogManager.shared.pushLog(log: "[setDataForSales] value : \(value)")
                
                let versionInfo = version.replacingOccurrences(of: "-", with: ".")
                
                let title = "[\(appName)]"
                var message = "\(platform) 앱에서 Sales 이벤트가 발생하였습니다. (\(1)) \n[\(Util.getBuildType().rawValue) - \(versionInfo)] \n[type : \(type), productName : \(productName), price : \(price)]"
                
                if value is NSNull {
                    self.sendPush(topic: "topic-jsapps-all", title: title, message: message)
                    return
                }
                
                let dic = value as! [String: Any]
                LogManager.shared.pushLog(log: "[setDataForSales] dic.count : \(dic.count)")
                
                message = "\(platform) 앱에서 Sales 이벤트가 발생하였습니다. (\(dic.count)) \n[\(Util.getBuildType().rawValue) - \(versionInfo)] \n[type : \(type), productName : \(productName), price : \(price)]"
                
                self.sendPush(topic: "topic-jsapps-all", title: title, message: message)
            }
        }
    }
    
    func setDataForEvent(event: String, info: String) {
        var url = hostUrl
        let uri = ApiUris.apiSetData.rawValue
        
        let root = ApiRootNames.rootEvents.rawValue
        let timestamps = Util.getCurrentTimestamps()
        
        let buildType = (Util.isAppstoreBuild()) ? "/": "-dev/"
        let version = Util.getVersionRaw().replacingOccurrences(of: ".", with: "-")
        
        let date = Util.getCurrentDateString()
        
        url += uri
        url += "?appName=\(appName)&key=" + root + buildType + date + "/\(version)/" + timestamps.description + "/" + "\(event)/" + "&value=" + info
        
        LogManager.shared.pushLog(log: "[setDataForEvent] url : \(url)")
                                  
        NetworkManager.shared.requestGet(url: url) { response in
            LogManager.shared.pushLog(log: "[setDataForEvent] response : \(response)")
        }
        
        LogManager.shared.pushLog(log: "[setDataForEvent] notificationForEvents : \(PlatformManager.shared.notificationForEvents)")
        
        if PlatformManager.shared.notificationForEvents {
            let appName = appName
            let platform = "ios"
            let buildType = "-" + Util.getBuildType().rawValue.lowercased()
            //let buildType = Util.isAppstoreBuild() ? "": "-" + Util.getBuildType().rawValue.lowercased()
            let dates = Util.getCurrentDateString()
            let child = "jsapps/" + appName.appending("/\(root)\(buildType)/\(dates)/\(version)")
            
            FirebaseManager.shared.getDataForRealtimeDB(child: child) { value in
                LogManager.shared.pushLog(log: "[setDataForEvent] value : \(value)")
                
                let versionInfo = version.replacingOccurrences(of: "-", with: ".")
                
                let title = "[\(appName)]"
                var message = "\(platform) 앱에서 Event 이벤트가 발생하였습니다. (\(1)) \n[\(Util.getBuildType().rawValue) - \(versionInfo)] \n[event : \(event), info : \(info)]"
                
                if value is NSNull {
                    self.sendPush(topic: "topic-jsapps-all", title: title, message: message)
                    return
                }
                
                let dic = value as! [String: Any]
                LogManager.shared.pushLog(log: "[setDataForEvent] dic.count : \(dic.count)")
                
                message = "\(platform) 앱에서 Event 이벤트가 발생하였습니다. (\(dic.count)) \n[\(Util.getBuildType().rawValue) - \(versionInfo)] \n[event : \(event), info : \(info)]"
                
                self.sendPush(topic: "topic-jsapps-all", title: title, message: message)
            }
        }
    }
    
    public func checkUpdateInfo(completion: @escaping (_ resultCode: Int, _ updateInfo: UpdateInfo?) -> Void) {
        let appName = appName
        let platform = "ios"
        let buildType = "-" + Util.getBuildType().rawValue.lowercased()
        //let buildType = Util.isAppstoreBuild() ? "": "-" + Util.getBuildType().rawValue.lowercased()
        //let key = Util.getCurrentTimestamps()
        let child = appName.appending("/info/info-\(platform)\(buildType)")
        
        FirebaseManager.shared.getDataForRealtimeDB(child: child) { value in
            LogManager.shared.pushLog(log: "[checkUpdateInfo] value : \(value)")
            
            if value is NSNull || value == nil  {
                completion(JSErrorCode.fail.rawValue, nil)
                return
            }
            
            let dic = value as! [String: Any]
            
            let checkUpdate = dic["CheckUpdate"] as? Bool ?? false
            let forceUpdate = dic["ForceUpdate"] as? Bool ?? false
            let agreementLink = dic["AgreementLink"] as? String ?? ""
            let appstoreLink = dic["AppstoreLink"] as? String ?? ""
            let moreAppsLink = dic["MoreAppsLink"] as? String ?? ""
            let adMobBannerAdId = dic["AdMobBannerAdId"] as? String ?? ""
            let bundleCode = dic["BundleCode"] as? Int ?? 0
            let bundleCodeReview = dic["BundleCodeReview"] as? Int ?? 0
            
            var info = UpdateInfo()
            
                //.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            
            info.checkUpdate = checkUpdate
            info.forceUpdate = forceUpdate
            info.agreementLink = agreementLink
            info.appstoreLink = appstoreLink
            info.moreAppsLink = moreAppsLink
            info.adMobBannerAdId = adMobBannerAdId
            info.bundleCode = bundleCode
            info.bundleCodeReview = bundleCodeReview
            
            if checkUpdate {
                let currentBundleCode = Int(Util.getVersionCode()) ?? 0
                
                if currentBundleCode >= bundleCode {
                    completion(Constants.AppUpdateResult.appUpdateResultOK.code, info)
                } else {
                    if forceUpdate {
                        completion(Constants.AppUpdateResult.appUpdateResultRequireUpdateForced.code, info)
                    } else {
                        completion(Constants.AppUpdateResult.appUpdateResultRequireUpdate.code, info)
                    }
                }
            } else {
                completion(Constants.AppUpdateResult.appUpdateResultOK.code, info)
            }
        }
    }
    
    public func loadBanners(completion: @escaping (_ list: [BannerInfo]) -> Void) {
        var list: [BannerInfo] = []
        
        let appName = appName
        let platform = "ios"
        let buildType = "-" + Util.getBuildType().rawValue.lowercased()
        //let buildType = Util.isAppstoreBuild() ? "": "-" + Util.getBuildType().rawValue.lowercased()
        //let key = Util.getCurrentTimestamps()
        let child = appName.appending("/info/banner-\(platform)\(buildType)")
        
        FirebaseManager.shared.getDataForRealtimeDB(child: child) { value in
            LogManager.shared.pushLog(log: "[loadBanners] value : \(value)")
            
            if value is NSNull || value == nil  {
                completion([])
                return
            }
            
            let array = value as! [Any]
            
            array.forEach { element in
                let dic = element as! [String: Any]
                
                let platform = dic["platform"] as? String ?? ""
                
                if platform == "ios" {
                    let bid = dic["bid"] as? String ?? ""
                    let type = dic["type"] as? String ?? ""
                    let title = dic["title"] as? String ?? ""
                    let message = dic["message"] as? String ?? ""
                    let url = dic["url"] as? String ?? ""
                    let linkUrl = dic["linkUrl"] as? String ?? ""
                    let startDates = dic["startDates"] as? String ?? ""
                    let endDates = dic["endDates"] as? String ?? ""
                    let showToday = dic["showToday"] as? String ?? ""
                    let showSeconds = dic["showSeconds"] as? String ?? ""
                    
                    var info: BannerInfo = BannerInfo()
                    
                    info.bid = bid
                    info.type = type
                    info.title = title
                    info.message = message
                    info.url = url
                    info.linkUrl = linkUrl
                    info.platform = platform
                    info.startDates = startDates
                    info.endDates = endDates
                    info.showToday = showToday
                    info.showSeconds = showSeconds
                    
                    list.append(info)
                    
                    LogManager.shared.pushLog(log: "[loadBanners] info : \(info)")
                }
            }
                        
            if list.count > 0 {
                completion(list)
            } else {
                completion([])
            }
        }
    }
    
    public func checkNotifications(completion: @escaping (_ resultCode: Int) -> Void) {
        if checkNotifications {
            checkNotifications = true
            completion(0)
            return
        }
        
        let appName = appName
        let platform = "ios"
        let buildType = "-" + Util.getBuildType().rawValue.lowercased()
        //let buildType = Util.isAppstoreBuild() ? "": "-" + Util.getBuildType().rawValue.lowercased()
        //let key = Util.getCurrentTimestamps()
        let child = "jsapps/" + appName.appending("/notifications\(buildType)/\(platform)")
        
        FirebaseManager.shared.getDataForRealtimeDB(child: child) { value in
            LogManager.shared.pushLog(log: "[checkNotifications] value : \(value)")
            
            if value is NSNull || value == nil {
                completion(JSErrorCode.fail.rawValue)
                return
            }
            
            let dic = value as! [String: Any]
            
            let dau = dic["dau"] as? Bool ?? false
            let installs = dic["installs"] as? Bool ?? false
            let updates = dic["updates"] as? Bool ?? false
            let sales = dic["sales"] as? Bool ?? false
            let events = dic["events"] as? Bool ?? false
            
            PlatformManager.shared.notificationForDau = dau
            PlatformManager.shared.notificationForInstalls = installs
            PlatformManager.shared.notificationForUpdates = updates
            PlatformManager.shared.notificationForSales = sales
            PlatformManager.shared.notificationForEvents = events
            
            completion(0)
        }
    }
}


