//
//  Extensions.swift
//  Joyce Studios
//
//  Created by billkim on 2024/05/23.
//

import UIKit
import WebKit
import SwiftUI
import Foundation

@available(iOS 13.0, *)
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    /// Hides the standard system background of the view.
    ///
    func scrollContentBackgroundHidden() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden)
        } else {
            return self
        }
    }

    /// Layers the given views behind this ``TextEditor``.
    ///
    func textEditorBackground<V>(@ViewBuilder _ content: () -> V) -> some View where V : View {
        self
            .onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
            .background(content())
    }
    
    func textEditorBackground(_ content: Color) -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden)
                .background(content)
        } else {
            UITextView.appearance().backgroundColor = .clear
            return self.background(content)
        }
    }
}

extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }

        return arrayOrdered
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func subString(from: Int, to: Int) -> String {
       let startIndex = self.index(self.startIndex, offsetBy: from)
       let endIndex = self.index(self.startIndex, offsetBy: to)
       return String(self[startIndex..<endIndex])
    }
    
    func trim() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}

public extension Int {

    /// Returns a random Int point number between 0 and Int.max.
    static var random: Int {
        return Int.random(n: Int.max)
    }

    /// Random integer between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random Int point number between 0 and n max
    static func random(n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }

    ///  Random integer between min and max
    ///
    /// - Parameters:
    ///   - min:    Interval minimun
    ///   - max:    Interval max
    /// - Returns:  Returns a random Int point number between 0 and n max
    static func random(min: Int, max: Int) -> Int {
        return Int.random(n: max - min + 1) + min

    }
}

// MARK: Double Extension

public extension Double {

    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }

    /// Random double between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random double point number between 0 and n max
    static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}

// MARK: Float Extension

public extension Float {

    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }

    /// Random float between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random float point number between 0 and n max
    static func random(min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}

// MARK: CGFloat Extension

public extension CGFloat {

    /// Randomly returns either 1.0 or -1.0.
    static var randomSign: CGFloat {
        return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
    }

    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: CGFloat {
        return CGFloat(Float.random)
    }

    /// Random CGFloat between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random CGFloat point number between 0 and n max
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
}

///
/// @author : billkim(김정훈)
/// UIApplication 객체에 대해서 확장 기능을 제공하는 확장 클래스
///
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

///
/// @author : billkim(김정훈)
/// UIImage 객체에 대해서 확장 기능을 제공하는 확장 클래스
///
extension UIImage {
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            //LogManager.shared.pushLog("image doesn't exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    public class func gifImageWithURL(_ gifUrl: String) -> UIImage? {
        guard let bundleURL: URL = URL(string: gifUrl)
            else {
            //LogManager.shared.pushLog("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            //LogManager.shared.pushLog("image named \"\(gifUrl)\" into NSData")
            return nil
        }

        return gifImageWithData(imageData)
        
        
    }

    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
            //LogManager.shared.pushLog("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            //LogManager.shared.pushLog("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gifImageWithData(imageData)
    }

    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)

        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        delay = delayObject as? Double ?? 0.0

        if delay < 0.1 {
            delay = 0.1
        }

        return delay
    }

    class func gcdForPair(_ input1: Int?, _ input2: Int?) -> Int {
        var input1 = input1
        var input2 = input2
        
        if input2 == nil || input1 == nil {
            if input2 != nil {
                return input2!
            } else if input1 != nil {
                return input1!
            } else {
                return 0
            }
        }

        if input1! < input2! {
            let newValue = input1
            input1 = input2
            input2 = newValue
        }

        var rest: Int
        while true {
            rest = input1! % input2!

            if rest == 0 {
                return input2!
            } else {
                input1 = input2
                input2 = rest
            }
        }
    }

    class func gcdForArray(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        for idx in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, idx, nil) {
                images.append(image)
            }

            let delaySeconds = UIImage.delayForImageAtIndex(Int(idx),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
        }()

        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for idx in 0..<count {
            frame = UIImage(cgImage: images[Int(idx)])
            frameCount = Int(delays[Int(idx)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)

        return animation
    }
}

class UIButtonEx: UIButton {
    var action: ((Int) -> Void)?

    func didClicked(action: @escaping (Int) -> Void) {
        self.action = action
        self.addTarget(self, action: #selector(self.clicked), for: .touchUpInside)
    }

    @objc func clicked() {
        action?(tag)
    }
}
