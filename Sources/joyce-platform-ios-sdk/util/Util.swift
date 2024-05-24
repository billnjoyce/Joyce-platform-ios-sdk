//
//  Util.swift
//  Joyce Studios
//
//  Created by billkim on 2023/09/19.
//

import UIKit
import WebKit
import SwiftUI
import Foundation

@objc class Util: NSObject {
    open class func getBuildType() -> Constants.BuildType {
        let schemeName = Bundle.main.infoDictionary!["SCHEME_NAME"] as? String
        
        if schemeName == nil {
            return Constants.BuildType.DEV
        }
        
        if schemeName! == "APPSTORE" {
            return Constants.BuildType.APPSTORE
        } else {
            return Constants.BuildType.DEV
        }
        
        /*#if DEV
            return Constants.BuildType.DEV
        #elseif QA
            return Constants.BuildType.QA
        #elseif APPSTORE_QA
            return Constants.BuildType.APPSTORE_QA
        #else
            return Constants.BuildType.APPSTORE
        #endif*/
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 앱스토어 빌드인지 체크하는 함수
    ///
    open class func isAppstoreBuild() -> Bool {
        let schemeName = Bundle.main.infoDictionary!["SCHEME_NAME"] as? String
        
        if schemeName == nil {
            return false
        }
        
        if schemeName! == "APPSTORE" {
            return true
        } else {
            return false
        }
        
        /*#if DEV
            return false
        #elseif QA
            return false
        #elseif APPSTORE_QA
            return true
        #else
            return true
        #endif*/
    }
    
    open class func isPlatformPad() -> Bool {
        return (UIDevice.current.userInterfaceIdiom == .pad)
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 기본 Alert 팝업을 출력하는 함수
    ///
    /// @param message : 출력할 메세지
    /// @param ok : 출력할 ok 버튼 메세지
    ///
    open class func showAlert(message: String?, ok: String?) {
        guard let vc = UIApplication.topViewController() else { return }
        if message == nil { return }
        
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        if ok != nil && !ok!.isEmpty {
            alertController.addAction(UIAlertAction(title: ok, style: .default, handler: { _ in }))
        }
        
        vc.present(alertController, animated: true, completion: nil)
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 기본 Alert 팝업을 출력하는 함수
    ///
    /// @param message : 출력할 메세지
    /// @param ok : 출력할 ok 버튼 메세지
    /// @param completion : ok 버튼 터치 완료 시 받을 이벤트 리스너
    ///
    open class func showAlert(message: String?, ok: String?, completion: @escaping ClosureNone) {
        guard let vc = UIApplication.topViewController() else { return }
        if message == nil { return }
        
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        if ok != nil && !ok!.isEmpty {
            alertController.addAction(UIAlertAction(title: ok, style: .default, handler: { _ in completion() }))
        }
        
        vc.present(alertController, animated: true, completion: nil)
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 기본 Alert 팝업을 출력하는 함수
    ///
    /// @param message : 출력할 메세지
    /// @param ok : 출력할 ok 버튼 메세지
    /// @param cancel : 출력할 cancel 버튼 메세지
    /// @param completion : ok 버튼 터치 완료 시 받을 이벤트 리스너
    ///
    open class func showAlert(title: String?, message: String?, ok: String?, cancel: String?, completion: @escaping ClosureBoolVoid) {
        guard let vc = UIApplication.topViewController() else { return }
        
        if title == nil || message == nil {
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if ok != nil && !ok!.isEmpty {
            alertController.addAction(UIAlertAction(title: ok, style: .default, handler: { (action) in completion(true) }))
        }
        
        if cancel != nil && !cancel!.isEmpty {
            alertController.addAction(UIAlertAction(title: cancel, style: .default, handler: { (action) in completion(false) }))
        }
        
        vc.present(alertController, animated: true, completion: nil)
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 기본 Alert 팝업을 출력하는 함수
    ///
    /// @param message : 출력할 메세지
    /// @param ok : 출력할 ok 버튼 메세지
    /// @param completion : ok 버튼 터치 완료 시 받을 이벤트 리스너
    ///
    open class func showAlertCommon(view: UIView, title: String?, message: String?, ok: String?, completion: @escaping ClosureBoolVoid) {
        if title == nil || message == nil {
            return
        }
        
        let size = UIScreen.main.bounds
        let sizeAlert = CGSize.init(width: 350, height: 200)
        
        let screenWidth = size.width
        let screenHeight = size.height
        
        let alertBg = UIView()
    
        alertBg.backgroundColor = UIColor.white
        
        alertBg.center = view.center
        
        alertBg.layer.cornerRadius = 10
        alertBg.layer.masksToBounds = true
        
        let buttonBg: UIButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight))
        buttonBg.backgroundColor = UIColor.black
        buttonBg.alpha = 0.5
        view.addSubview(buttonBg)

        let labelTitle: UILabel = UILabel()
        labelTitle.text = title
        labelTitle.textAlignment = .center
        labelTitle.textColor = UIColor.black
        labelTitle.font = UIFont.boldSystemFont(ofSize: 20.0)
        alertBg.addSubview(labelTitle)
        
        let labelMessage: UILabel = UILabel()
        labelMessage.text = message
        labelMessage.textAlignment = .center
        labelMessage.textColor = UIColor.black
        labelMessage.numberOfLines = 5
        labelMessage.font = UIFont.systemFont(ofSize: 18.0)
        alertBg.addSubview(labelMessage)
        
        let buttonOk: UIButtonEx = UIButtonEx()
        buttonOk.setTitle(ok, for: .normal)
        buttonOk.titleLabel?.textColor = UIColor.white
        buttonOk.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        buttonOk.backgroundColor = UIColor.init(red: 89/255, green: 107/255, blue: 255/255, alpha: 255/255)
        alertBg.addSubview(buttonOk)
        
        buttonOk.didClicked { tag in
            buttonBg.removeFromSuperview()
            alertBg.removeFromSuperview()
            
            completion(true)
        }
        
        view.addSubview(alertBg)
        
        alertBg.translatesAutoresizingMaskIntoConstraints = false
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        labelMessage.translatesAutoresizingMaskIntoConstraints = false
        buttonOk.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                alertBg.widthAnchor.constraint(equalToConstant: sizeAlert.width),
                alertBg.heightAnchor.constraint(equalToConstant: sizeAlert.height),
                alertBg.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                alertBg.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                //alertBg.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: 1),
                //alertBg.centerYAnchor.constraint(equalToSystemSpacingBelow: view.centerYAnchor, multiplier: 0.8),
                
                labelTitle.topAnchor.constraint(equalTo: alertBg.topAnchor, constant: 20),
                labelTitle.centerXAnchor.constraint(equalTo: alertBg.centerXAnchor),
                
                labelMessage.topAnchor.constraint(equalTo: alertBg.topAnchor, constant: 60),
                labelMessage.centerXAnchor.constraint(equalTo: alertBg.centerXAnchor),
                
                buttonOk.widthAnchor.constraint(equalToConstant: sizeAlert.width),
                buttonOk.heightAnchor.constraint(equalToConstant: 50),
                buttonOk.bottomAnchor.constraint(equalTo: alertBg.bottomAnchor, constant: 0),
                buttonOk.centerXAnchor.constraint(equalTo: alertBg.centerXAnchor)
            ])
        } else {
            // Fallback on earlier versions
        }
    }
    
    open class func showAlertAction(viewController: UIViewController,
                                             title: String,
                                           message: String,
                                              list: [String],
                                            cancel: String,
                                        completion: @escaping ClosureStringVoid) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for text in list {
            alert.addAction(UIAlertAction(title: text, style: .default , handler:{ (UIAlertAction) in
                completion(text)
            }))
        }
        
        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler:{ (UIAlertAction)in
            completion(cancel)
        }))

        alert.view.alpha = 0.0
        
        UIView.animate(withDuration: 1.0, animations: {
            alert.view.alpha = 1.0
        })
        
        if Util.isPlatformPad() {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = viewController.view
                popoverController.sourceRect = CGRect.init(x: viewController.view.bounds.width/2,
                                                           y: viewController.view.bounds.height/2,
                                                           width: 0,
                                                           height: 0)
                popoverController.permittedArrowDirections = []
                
                viewController.present(alert, animated: true, completion: {
                    
                })
            }
            
        } else {
            viewController.present(alert, animated: true, completion: {
                
            })
        }
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 원하는 시간만큼 딜레이를 주는 함수
    ///
    /// @param duration : 딜레이 시간(초)
    /// @param completion : 딜레이 완료 후 받을 이벤트 리스너
    ///
    open class func delay(duration: Double, completion: @escaping ClosureNone) {
        let deadline = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: completion)
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 뷰 컨트롤러 화면을 이동하는 함수
    ///
    /// @param viewController : 현재 뷰 컨트롤러 객체
    /// @param indetifier : 이동할 뷰 컨트롤러 식별자 스트링 값
    /// @param animation : 화면 이동 시의 애니메이션 여부
    /// @param completion : 화면 이동 완료 시 받을 이벤트 리스너
    ///
    open class func presentModalView(from: UIViewController?, indetifier: String?, animation: Bool = true, completion: (ClosureNoneVoid)?) {
        guard let dest = from, let id = indetifier else { return }
        guard let vc = dest.storyboard?.instantiateViewController(withIdentifier: id) else { return }
        
        vc.modalPresentationStyle = .fullScreen
        dest.present(vc, animated: animation, completion: completion)
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 현재 버전 정보를 가져오는 함수
    ///
    open class func getVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "" }
        guard let number = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else { return "" }
        
        if Util.getBuildType() == Constants.BuildType.APPSTORE ||
            Util.getBuildType() == Constants.BuildType.APPSTOREQA {
            return String.init(format: "v.%@(%@)", version, number)
        }
        else {
            return String.init(format: "[%@] v.%@(%@)", Util.getBuildType().rawValue, version, number)
        }
    }
    
    open class func getVersionCode() -> String {
        guard let number = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else { return "0" }
        
        return number
    }
    
    open class func getVersionRaw() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "" }
        guard let number = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else { return "" }
        
        return String.init(format: "v.%@(%@)", version, number)
    }
    
    ///
    /// @author : billkim(김정훈)
    /// JSON 객체에 대해서 스트링으로 인코딩 해주는 함수
    ///
    open class func encodeJson<T>(json: T?) -> String where T: Encodable {
        guard let obj = json else { return "" }
        
        do {
            let jsonData = try JSONEncoder().encode(obj)
            let jsonString = String(data: jsonData, encoding: .utf8)
            guard let reslut = jsonString else { return "" }
            
            return reslut
        } catch _ {
            return ""
        }
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 현재 디바이스의 UUID 값을 생성해주는 함수
    ///
    open class func getUuid() -> String {
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            return uuid
        }
        
        return ""
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 현재 디바이스의 OS 버전을 반환하는 함수
    ///
    open class func getOsVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 현재 디바이스의 모델명을 반환하는 함수
    ///
    open class func getModelName() -> String {
        var utsnameInstance = utsname()
        uname(&utsnameInstance)
        
        let optionalString: String? = withUnsafePointer(to: &utsnameInstance.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in
                String.init(validatingUTF8: ptr)
            }
        }
        
        return optionalString ?? "N/A"
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 저해상도 단말기인지 체크하는 함수
    ///
    open class func isLowResolution() -> Bool {
        let width = UIScreen.main.bounds.width
        
        return (width < 400)
    }
    
    open class func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    open class func isDarkMode() -> Bool {
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return true
            }
            else {
                return false
            }
        } else {
            return false
        }
    }
    
    open class func openUrl(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 상태바(Status Bar) 컬러 설정 함수
    ///
    /// @param view : 대상 View 객체
    /// @param color : 원하는 컬러값
    ///
    open class func setStatusBarColor(view: UIView, color: UIColor) {
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = color
        
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 파일 다운로드를 실행하는 함수
    ///
    /// @param context : 현재 화면 Context
    /// @param url : 파일 다운로드를 실행할 url 주소값
    /// @param completion : 다운로 완료 후 받을 이벤트 리스너드(다운로드 받은 파일명 전달)
    ///
    open class func downloadFile(url: String, completion: @escaping ClosureStringVoid) {
        let fileName = (url as NSString).lastPathComponent
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationFileUrl = documentDirectory.appendingPathComponent(fileName)
        
        if let fileUrl = URL(string: url) {
            URLSession.shared.downloadTask(with: fileUrl) { (fileUrl, response, error) in
                
                if let fileLinkUrl = fileUrl {
                    do {
                        let data = try Data(contentsOf: fileLinkUrl)
                        try data.write(to: destinationFileUrl)
                        
                        DispatchQueue.main.async {
                            completion(fileName)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion("")
                        }
                    }
                }
            }.resume()
        }
    }
    
    open class func checkNetworkStatus() -> Bool {
        if !Reachability.isConnectedToNetwork() {
            //Util.showAlert(message: "서비스 접속이 원활하지 않습니다. 네트워크 연결 상태를 확인해주세요.", ok: "확인")
            
            return false
        }
        
        return true
    }
    
    open class func evaluateJavaScript(webView: WKWebView, script: String, completion: @escaping ClosureAnyVoid) {
        webView.evaluateJavaScript(script) { (result, error) in
            completion(result)
        }
    }
    
    @objc open class func showSettingsView(from: UIViewController?, completion: (ClosureNoneVoid)?) {
        let indetifier: String? = "CompactSettingsView"
        guard let dest = from, let id = indetifier else { return }
        guard let vc = dest.storyboard?.instantiateViewController(withIdentifier: id) else { return }
        
        vc.modalPresentationStyle = .fullScreen
        //vc.modalPresentationStyle = .currentContext
        dest.present(vc, animated: true, completion: completion)
    }
    
    open class func getCurrentTimestamps() -> Int64 {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        
        return timestamp
    }
    
    open class func getCurrentDateString() -> String {
        let now = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        return String(format: "%04d-%02d-%02d", year, month, day)
    }
    
    open class func getCurrentDate() -> String {
        let now = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        return String(format: "%04d.%02d.%02d", year, month, day)
    }
    
    open class func getCurrentDateWithTime() -> String {
        let now = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let seconds = calendar.component(.second, from: now)
        
        return String(format: "%04d.%02d.%02d\n %02d:%02d:%02d", year, month, day, hour, minute, seconds)
    }
    
    open class func getCurrentDateYear() -> String {
        let now = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: now)
        
        let yearString = "TEXT_YEAR".localized
        
        return String(format: "%04d%@", year, yearString)
    }
    
    open class func getCurrentDateYearAndMonthFormat() -> String {
        let now = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        
        return String(format: "%04d.%02d", year, month)
    }
    
    open class func getCurrentDateYearAndMonth() -> String {
        let now = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        let yearString = "TEXT_YEAR".localized
        let monthString = "TEXT_MONTH".localized
        
        return String(format: "%04d%@ %02d%@", year, yearString, month, monthString)
    }
    
    open class func toYearMonthFromDateString(_ from: String) -> String {
        let now = Util.toDate(from)
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        //let yearString = "TEXT_YEAR".localized
        //let monthString = "TEXT_MONTH".localized
        
        return String(format: "%04d.%02d", year, month)
    }
    
    open class func toYearMonthFromCurrentDate(_ from: String) -> String {
        let yearString = "TEXT_YEAR".localized
        let monthString = "TEXT_MONTH".localized
        
        let currentMonth = from.replacingOccurrences(of: monthString, with: "")
        var year, month: Int
        
        year = Int(currentMonth.prefix(4))!
        month = Int(currentMonth.suffix(2))!
        
        return String(format: "%04d.%02d", year, month)
    }
    
    open class func toPrevYearFromCurrentDate(_ from: String) -> String {
        let yearString = "TEXT_YEAR".localized
        
        let currentMonth = from
        var year: Int
        
        year = Int(currentMonth.prefix(4))!
        
        year -= 1
        
        return String(format: "%04d", year)
    }
    
    open class func toNextYearFromCurrentDate(_ from: String) -> String {
        let yearString = "TEXT_YEAR".localized
        
        let currentMonth = from
        var year: Int
        
        year = Int(currentMonth.prefix(4))!
        
        year += 1
        
        return String(format: "%04d", year)
    }
    
    open class func toPrevYearMonthFromCurrentDate(_ from: String) -> String {
        let yearString = "TEXT_YEAR".localized
        let monthString = "TEXT_MONTH".localized
        
        let currentMonth = from.replacingOccurrences(of: monthString, with: "")
        var year, month: Int
        
        year = Int(currentMonth.prefix(4))!
        month = Int(currentMonth.suffix(2))!
        
        month -= 1
        
        if month <= 0 {
            month = 12
            year -= 1
        }
        
        return String(format: "%04d.%02d", year, month)
    }
    
    open class func toNextYearMonthFromCurrentDate(_ from: String) -> String {
        let yearString = "TEXT_YEAR".localized
        let monthString = "TEXT_MONTH".localized
        
        let currentMonth = from.replacingOccurrences(of: monthString, with: "")
        var year, month: Int
        
        year = Int(currentMonth.prefix(4))!
        month = Int(currentMonth.suffix(2))!
        
        month += 1
        
        if month > 12 {
            month = 1
            year += 1
        }
        
        return String(format: "%04d.%02d", year, month)
    }
    
    open class func toDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "YYYY.MM.dd"
        return dateFormatter.string(from: date)
    }
    
    open class func toDate(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let date = dateFormatter.date(from: dateString) ?? Date()
        
        return date
    }
    
    open class func toDateStringByDays(_ from: String, _ days: Int) -> String {
        let startDate = Util.toDate(from)
        let targetDate = Calendar.current.date(byAdding: .day, value: days, to: startDate)!
        
        let date = Util.toDateString(date: targetDate)
        
        return date
    }
    
    open class func getMonths(_ from: String, _ to: String) -> [String] {
        let startMonth = Util.toYearMonthFromDateString(from)
        let endMonth = Util.toYearMonthFromDateString(to)
        
        let startMonthInt = Util.toNumbericString(text: startMonth).replacingOccurrences(of: ".", with: "")
        let endMonthInt = Util.toNumbericString(text: startMonth).replacingOccurrences(of: ".", with: "")
        
        LogManager.shared.pushLog(log: "[getMonths] startMonth: \(startMonth), endMonth: \(endMonth)")
        
        if endMonthInt < startMonthInt {
            LogManager.shared.pushLog(log: "[getMonths] months: []")
            
            return []
        }
        
        var months: [String] = []
        
        var currentMonth = startMonth
        
        months.append(String(format: "%@", currentMonth))
                      
        while(true) {
            let nextMonth = Util.toNextYearMonthFromCurrentDate(currentMonth)
            LogManager.shared.pushLog(log: "[getMonths] nextMonth: \(nextMonth)")
            
            months.append(String(format: "%@", nextMonth))
            
            currentMonth = nextMonth
            
            if currentMonth == endMonth {
                break
            }
        }
        
        LogManager.shared.pushLog(log: "[getMonths] months: \(months)")
        
        return months
    }
    
    open class func numberOfDaysBetweenDates(_ from: String, and to: String) -> Int {
        let calendar = Calendar.current

        let day1 = toDate(from)
        let day2 = toDate(to)
        
        let date1 = calendar.startOfDay(for: day1)
        let date2 = calendar.startOfDay(for: day2)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        return components.day!
    }
    
    @available(iOS 15.0, *)
    open class func toThousandString(text: String) -> String {
        let number = Util.toNumbericString(text: text)
        let result = Util.toThousandString(number: Int(number) ?? 0)
    
        //let result = text.unfoldSubSequences(limitedTo: 3).joined(separator: ",")
        
        return result
    }
    
    @available(iOS 15.0, *)
    open class func toThousandString(number: Int) -> String {
        let result = number.formatted(.number.locale(.init(identifier: "en_US")))
        
        //let text = String(format: "%d", number)
        //let result = text.unfoldSubSequences(limitedTo: 3).joined(separator: ",")
        
        return result
    }
    
    open class func toNumbericString(text: String) -> String {
        var result = text
        
        result = result.replacingOccurrences(of: " ", with: "")
        result = result.replacingOccurrences(of: ",", with: "")
        result = result.replacingOccurrences(of: "km", with: "")
        result = result.replacingOccurrences(of: "L", with: "")
        result = result.replacingOccurrences(of: "kWh", with: "")
        result = result.replacingOccurrences(of: "$", with: "")
        result = result.replacingOccurrences(of: "/", with: "")
        result = result.replacingOccurrences(of: "mi", with: "")
        result = result.replacingOccurrences(of: "£", with: "")
        result = result.replacingOccurrences(of: "€", with: "")
        result = result.replacingOccurrences(of: "₩", with: "")
        result = result.replacingOccurrences(of: "\n", with: "")
        result = result.replacingOccurrences(of: "Gallons", with: "")
        result = result.replacingOccurrences(of: "TEXT_YEAR".localized, with: "")
        result = result.replacingOccurrences(of: "TEXT_MONTH".localized, with: "")
        result = result.replacingOccurrences(of: "TEXT_MONEY_WON".localized, with: "")
        result = result.replacingOccurrences(of: "TEXT_MONEY_DOLLAR".localized, with: "")
        
        result = result.replacingOccurrences(of: "TEXT_MONEY_CURRENCY".localized, with: "")
        
        return result
    }
    
    @available(iOS 15.0, *)
    open class func toMoneyString(text: String) -> String {
        let number = Int(Util.toNumbericString(text: text)) ?? 0
        let result = String(format: "%@ %@", Util.toThousandString(number: number), "TEXT_MONEY_CURRENCY".localized)
        
        return result
    }
    
    @available(iOS 15.0, *)
    open class func toMoneyString(number: Int) -> String {
        let result = String(format: "%@ %@", Util.toThousandString(number: number), "TEXT_MONEY_CURRENCY".localized)
        
        return result
    }
    
    open class func checkFirstInstall() -> Bool {
        let key = "firstInstall"
        let value = getCacheValue(key: key)
        
        if value.isEmpty {
            setCacheValue(key: key, value: "false")
            return true
        } else {
            //saveCacheValue(key: key, value: "false")
            return false
        }
        
        /*let rootPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "first.install"
        
        let filePath = rootPath.appendingPathComponent(fileName)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath.path) {
            //print("FILE AVAILABLE")
            return false
        } else {
            //print("FILE NOT AVAILABLE")
            
            if let data: Data = "installed".data(using: String.Encoding.utf8) { // String to Data
                do {
                    try data.write(to: filePath) // 위 data를 "hi.txt"에 쓰기
                } catch let e {
                    print(e.localizedDescription)
                }
            }
            
            return true
        }*/
    }
    
    open class func checkAppUpdate() -> Bool {
        let key = "appupdate"
        let value = getCacheValue(key: key)
        
        let version = getVersionRaw()
        
        if value.isEmpty {
            setCacheValue(key: key, value: version)
            return true
        } else {
            if version == value {
                return false
            } else {
                setCacheValue(key: key, value: version)
                return true
            }
        }
    }
    
    open class func setCacheValue(key: String, value: String) {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(value, forKey: key)
    }
    
    open class func getCacheValue(key: String) -> String {
        let userDefaults = UserDefaults.standard
        
        guard let value = userDefaults.object(forKey: key) else { return "" }
        
        return value as! String
    }
}
