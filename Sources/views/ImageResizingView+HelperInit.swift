//
//  ImageResizingView.swift
//  
//
//  Created by Chad Meyers on 8/25/24.
//

import Foundation
import SwiftUI

extension ImageItemViewer {
    /// Creates a new image item viewer which displays the specified image.
    ///
    /// - Parameters:
    ///   - item: The item to display inside the image viewer.
    ///   - maxScale: The maximum scale to allow the user to magnify the image by, relative to the size of this view inside it's parent. Pass `nil` to allow infinite zoom.
    public init(item: InteractiveImageItem, maxScale: CGFloat? = nil) {
        self.init(item: .constant(item), maxScale: maxScale)
    }
    
    /// Creates a new image item viewer which displays the specified image.
    ///
    /// - Parameters:
    ///   - image: The SwiftUI image to display inside the image viewer.
    ///   - size: The native size of the image, in points.
    ///   - maxScale: The maximum scale to allow the user to magnify the image by, relative to the size of this view inside it's parent. Pass `nil` to allow infinite zoom.
    public init(image: Image, size: CGSize, maxScale: CGFloat? = nil) {
        self.init(item: InteractiveImageItem(image: image, size: size), maxScale: maxScale)
    }
    
    /// Creates a new image item viewer which displays the specified image.
    /// The image size is inferred by the ``UIKit/UIImage/size`` property.
    ///
    /// - Parameters:
    ///   - uiImage: The UIKit image to display inside the image viewer.
    ///   - maxScale: The maximum scale to allow the user to magnify the image by, relative to the size of this view inside it's parent. Pass `nil` to allow infinite zoom.
    public init(uiImage: UIImage, maxScale: CGFloat? = nil) {
        self.init(item: InteractiveImageItem(image: uiImage), maxScale: maxScale)
    }
}
