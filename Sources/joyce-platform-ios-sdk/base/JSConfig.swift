//
//  JSConfig.swift
//  Joyce Studios
//
//  Version History
//
//  Created by billkim on 2024/05/23.
//

import Foundation

public typealias ClosureNone = () -> Void
public typealias ClosureNoneVoid = () -> Void
public typealias ClosureBoolVoid = (Bool) -> Void
public typealias ClosureStringVoid = (String) -> Void
public typealias ClosureAnyVoid = (Any) -> Void
public typealias ClosureNSDicVoid = (NSDictionary?) -> Void

@objc
public enum JSErrorCode: Int {
    case notPrepared = -1
    case success = 0
    case fail = 1
    case cancelLogin
    case invalidIdToken
    case invalidAccessToken
    case notSupportOsVersion
    case invalidResponseData
    case invalidClientId
    case notSupportedPlatformType
    case invalidExpireTime
    case invalidRefreshToken
}

enum Constants {
    ///
    /// @author : billkim(김정훈)
    /// 빌드 타입에 대한 스트링 리스트 목록
    ///
    enum BuildType: String {
        case DEV = "DEV"
        case QA = "QA"
        case APPSTORE = "RELEASE"
        case APPSTOREQA = "RELEASE_QA"
    }

    ///
    /// @author : billkim(김정훈)
    /// 데이터 베이스 관련 이름 정보 목록
    ///
    enum DataBaseName {
        #if DEV
            static let updateInfoDB = "info-ios-qa"
        #elseif QA
            static let updateInfoDB = "info-ios-qa"
        #elseif APPSTORE_QA
            static let updateInfoDB = "info-ios"
        #else
            static let updateInfoDB = "info-ios"
        #endif
        
        //static let updateInfoDB = "info-ios"
    }
    
    ///
    /// @author : billkim(김정훈)
    /// 앱 업데이트 정보 요청과 관련한 결과값 목록
    ///
    enum AppUpdateResult {
        case appUpdateResultOK
        case appUpdateResultFail
        case appUpdateResultRequireUpdate
        case appUpdateResultRequireUpdateForced

        var code: Int {
            switch self {
                case .appUpdateResultOK:
                    return 0
                case .appUpdateResultFail:
                    return -1
                case .appUpdateResultRequireUpdate:
                    return -2
                case .appUpdateResultRequireUpdateForced:
                    return -3
            }
        }

        var message: String {
            switch self {
                case .appUpdateResultOK:
                    return "OK"
                case .appUpdateResultFail:
                    return "Failed"
                case .appUpdateResultRequireUpdate:
                    return "App is required update."
                case .appUpdateResultRequireUpdateForced:
                    return "App must required update."
            }
        }
    }
}
