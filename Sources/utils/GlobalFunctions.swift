//
//  GlobalFunctions.swift
//  
//
//  Created by Chad Meyers on 8/25/24.
//

import Foundation

/// Clamps a value between two upper and lower bounds, inclusive.
///
/// - Parameters:
///   - minValue: The minimum value that `value` can take on, down to and including this value.
///   - value: The value to clamp within the minimum and maximum values
///   - maxValue: The maximum value that `value` can take on, up to and including this value.
/// - Returns: When `value < minValue`, returns `minValue`.
///            When `value > maxValue`, returns `maxValue`.
///            Otherwise, returns `value`.
internal func clamp<T: Comparable>(min minValue: T, value: T, max maxValue: T) -> T {
    return min(maxValue, max(minValue, value))
}
