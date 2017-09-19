//
//  DeviceSize.swift
//  Pods
//
//  Created by Anatoliy Voropay on 6/8/16.
//  Copyright © 2016 Anatoliy Voropay. All rights reserved.
//

import UIKit

/// Available screen sizes
///
/// - parameter unknown:
/// - parameter inches_3_5:    Representing screens for iPhone 4, 4S
/// - parameter inches_4_0:    Representing screens for iPhone 5, 5S
/// - parameter inches_4_7:    Screens for iPhone 6, 6S
/// - parameter inches_5_5:    Screens for iPhone 6Plus
/// - parameter inches_7_9:    Screens for iPad Mini
/// - parameter inches_9_7:    Screens for iPad
/// - parameter inches_12_9:   Screens for iPad Pro
public enum Screen: CGFloat {
    case unknown     = 0
    case inches_3_5  = 3.5
    case inches_4_0  = 4.0
    case inches_4_7  = 4.7
    case inches_5_5  = 5.5
    case inches_7_9  = 7.9
    case inches_9_7  = 9.7
    case inches_12_9 = 12.9

    /// Return screen family
    public var family: ScreenFamily {
        switch self {
        case .inches_3_5, .inches_4_0, .inches_4_7:
            return .Small

        case .inches_5_5, .inches_7_9:
            return .Medium

        case .inches_9_7, .inches_12_9:
            return .Big

        default:
            return .Unknown
        }
    }
}

/// These parameters are used to groups device screens into 3 groups:
///
/// - parameter unknown:
/// - parameter small:     Include devices with screen resolution 3.5, 4.0, 4.7 inches (iPhones without iPhone 6Plus)
/// - parameter medium:    Include devices with screen resolution 5.5, 7.9 inches (iPhone 6Plus and iPad mini)
/// - parameter big:       Include devices with biger screen resolutions (Regular iPad and iPad Pro)
public enum ScreenFamily: String {
    case Unknown = "Unknown"
    case Small   = "Small"
    case Medium  = "Medium"
    case Big     = "Big"
}

/// Different types of screen scales
///
/// - Parameter x1:
/// - Parameter x2:
/// - Parameter x3:
/// - Parameter unknown:
public enum Scale: CGFloat, Comparable, Equatable {
    case x1      = 1.0
    case x2      = 2.0
    case x3      = 3.0
    case unknown = 0
}

public func ==(lhs: Scale, rhs: Scale) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

public func <(lhs: Scale, rhs: Scale) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

public func <=(lhs: Scale, rhs: Scale) -> Bool {
    return lhs.rawValue <= rhs.rawValue
}

public func >=(lhs: Scale, rhs: Scale) -> Bool {
    return lhs.rawValue >= rhs.rawValue
}

public func >(lhs: Scale, rhs: Scale) -> Bool {
    return lhs.rawValue > rhs.rawValue
}

/// Detecting screen properties
extension Device {

    /// Detect device screen.
    ///
    /// - seealso: Screen
    static public var screen: Screen {
        let size = UIScreen.main.bounds.size
        let height = max(size.width, size.height)

        switch height {
        case 480:
            return .inches_3_5

        case 568:
            return .inches_4_0

        case 667:
            return ( scale == .x3 ? .inches_5_5 : .inches_4_7 )

        case 736:
            return .inches_5_5

        case 1024:
            switch version {
            case .padMini, .padMini2, .padMini3, .padMini4:
                return .inches_7_9

            default:
                return .inches_9_7
            }

        case 1366:
            return .inches_12_9

        default:
            return .unknown
        }
    }

    /// Detect screen resolution scale.
    ///
    /// - Seealso: Scale
    static public var scale: Scale {
        let scale = UIScreen.main.scale

        switch scale {
        case 1.0:
            return .x1

        case 2.0:
            return .x2

        case 3.0:
            return .x3

        default:
            return .unknown
        }
    }

    /// Return `true` for retina displays
    static public var isRetina: Bool {
        return scale > Scale.x1
    }
}

/// Work with sizes
extension Device {

    /// Returns size for a specific device (iPad or iPhone/iPod)
    static public func size<T: Any>(phone: T, pad: T) -> T {
        return ( Device.isPad ? pad : phone )
    }

    /// Return size depending on specific screen family.
    /// If Screen size is unknown (in this case ScreenFamily will be unknown too) it will return small value
    ///
    /// - seealso: Screen, ScreenFamily
    static public func size<T: Any>(small: T, medium: T, big: T) -> T {
        let family = Device.screen.family

        switch family {
        case .Small:
            return small

        case .Medium:
            return medium

        case .Big:
            return big

        default:
            return small
        }
    }

    /// Return value for specific screen size. Incoming parameter should be a screen size. If it is not defined
    /// nearest value will be used. Code example:
    ///
    /// ```
    /// let sizes: [Screen:AnyObject] = [
    ///     .inches_3_5: 12,
    ///     .inches_4_0: 13,
    ///     .inches_4_7: 14,
    ///     .inches_9_7: 15
    ///    ]
    /// let exactSize = Device.size(sizes: sizes) as! Int
    /// let _ = UIFont(name: "Arial", size: CGFloat(exactSize))
    /// ```
    ///
    /// After that your font will be:
    /// * 12 for 3.5" inches (older devices)
    /// * 13 for iPhone 5, 5S
    /// * 14 for iPhone 6, 6Plus and iPad mini
    /// * and 15 for other iPads
    ///
    /// - seealso: Screen
    static public func size<T: Any>(sizes: [Screen : T]) -> T? {
        let screen = Device.screen
        var nearestValue: T?
        var distance = CGFloat.greatestFiniteMagnitude

        for (key, value) in sizes {
            // Prevent from iterating whole array
            if (key == screen) {
                return value
            }

            let actualDistance = fabs(key.rawValue - screen.rawValue)
            if actualDistance < distance {
                nearestValue = value
                distance = actualDistance
            }
        }

        return nearestValue
    }
}
