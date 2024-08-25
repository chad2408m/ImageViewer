//
//  File.swift
//  
//
//  Created by Chad Meyers on 8/25/24.
//

import Foundation
import SwiftUI

extension CGSize {
    /// Scales the width and height of this size by the given positive factor value.
    ///
    /// If `factor` is negative, it will be set to `0.0` instead.
    ///
    /// - Parameter factor: The factor to scale by, or `nil` to perform no scaling (equivalent to scaling by 1.0).
    ///                     This method does not permit negative scale factors, and will instead return a ``CGSize/zero`` if negative value is specified.
    internal func scaled(_ factor: CGFloat?) -> CGSize {
        let factor = max(0.0, factor ?? 1.0)
        
        return CGSize(width: self.width * factor, height: self.height * factor)
    }
    
    /// Clamps the width and height of this size to the given range of values.
    ///
    /// - Parameters:
    ///   - minWidth: The minimum width to clamp this size to, or `nil` to leave unclamped.
    ///   - minHeight: The minimum height to clamp this size to, or `nil` to leave unclamped.
    internal func clamp(minWidth: CGFloat? = nil, minHeight: CGFloat? = nil) -> CGSize {
        return CGSize(width: minWidth.map { max($0, self.width) } ?? self.width,
                      height: minHeight.map { max($0, self.height) } ?? self.height)
    }
    
    /// Converts the specified CGPoint to a UnitPoint within the bounds of this size.
    internal func unitPoint(for cgPoint: CGPoint) -> UnitPoint {
        return UnitPoint(x: ImageViewer.clamp(min: 0.0, value: cgPoint.x, max: self.width) * self.width,
                         y: ImageViewer.clamp(min: 0.0, value: cgPoint.y, max: self.height) * self.height)
    }
    
    /// Returns the mid-point of this size as a CGPoint
    internal var centerPoint: CGPoint {
        return CGPoint(x: self.width / 2.0, y: self.height / 2.0)
    }
}
