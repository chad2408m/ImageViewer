//
//  InteractiveImageItem.swift
//
//
//  Created by Chad Meyers on 8/18/24.
//

import AVFoundation
import Foundation
import SwiftUI
import Observation

//CMMTODO: Add properties for crop image insets
//CMMTODO: Add two environment values for: .interactiveImageClipShape(_:padding:), .interactiveImageOverlay(visibility:), use the foreground style for overlay
//CMMTODO: Document
@Observable
public class InteractiveImageItem: Identifiable {
    /// The image to display inside an ``ImageResizingView`` view.
    public let image: Image
    
    /// The original size of the image, before any transformations are applied.
    public let imageSize: CGSize
    
    /// The amount the image is scaled by, relative to it's parent view.
    ///
    /// A value of 1.0 indicates no scaling transformations are applied.
    /// A value greater than 1 indicates the image is magnified within it's parent view to a larger size.
    /// This magnified size may still be smaller than the original image size, as images are always scaled to fit their parent.
    ///
    /// Images are not allowed to be scaled to a value less than 1.0.
    public private(set) var zoomScale: CGFloat = 1.0
    
    /// The amount of translation applied to the center of this image, relative to the center of it's parent view.
    ///
    /// A value of (0, 0) indicates the image is perfectly centered within it's parent view.
    public private(set) var translation: CGSize = .zero
    
    /// An internal tracking of the last known parent container size.
    ///
    /// Defaults to the image size until placed into a ``ImageResizer``.
    @ObservationIgnored
    internal private(set) var lastKnownContainerSize: CGSize
    
    /// Each interactive image item is identified by it's instance.
    public var id: AnyObject {
        return self
    }
    
    /// Creates a new resizable image item for the given SwiftUI image.
    ///
    /// - Parameters:
    ///   - image: The image to draw.
    ///   - size: The native size of the image, in points.
    public init(image: Image, size: CGSize) {
        self.image = image
        self.imageSize = size.clamp(minWidth: 1.0, minHeight: 1.0)
        self.lastKnownContainerSize = size
    }
}

//MARK: Helper initializers

extension InteractiveImageItem {
    /// Creates a new resizable image from the given UIKit image, automatically inferring the image's dimensions.
    ///
    /// - Parameter image: The image to draw.
    public convenience init(image: UIImage) {
        self.init(image: Image(uiImage: image), size: image.size)
    }
    
    /// Creates a new resizable image from the given image bytes, if possible.
    ///
    /// The image data must be in a format supported by the system. See ``UIKit/UIImage/init(data:)``.
    ///
    /// - Parameter data: The data to decode which represents the image.
    /// - Returns: Returns `nil` if the image could not be decoded.
    public convenience init?(data: Data) {
        if let uiImage = UIImage(data: data) {
            self.init(image: uiImage)
        } else {
            return nil
        }
    }
}

//MARK: Calculating and setting zoom scale

extension InteractiveImageItem {
    internal func activeZoomScale(value: MagnifyGesture.Value?, maxScale: CGFloat?) -> CGFloat {
        guard let value else {
            return self.zoomScale
        }
        
        let magnification = value.magnification
        
        if magnification > 1.0 {
            let newScale = self.zoomScale + (magnification - 1.0)
            
            if let maxScale, newScale > maxScale {
                let overScale = newScale - maxScale
                let logAdjustedOverScale = log2(overScale + 1.0)
                return maxScale + logAdjustedOverScale
            } else {
                return newScale
            }
        } else {
            return (self.zoomScale * magnification)
        }
    }
    
    internal func finalizeZoomScale(value: MagnifyGesture.Value, maxScale: CGFloat? = nil, animation: Animation = .spring) {
        self.zoomScale = self.activeZoomScale(value: value, maxScale: maxScale)
        
        // Clamp zoom scale to stay within bounds, then animate to that value
        let clampedZoomScale = clamp(min: 1.0, value: self.zoomScale, max: maxScale ?? .infinity)
        let magnificationPoint = self.lastKnownContainerSize.unitPoint(for: value.startLocation)
        self.animateToZoomScale(clampedZoomScale, location: magnificationPoint, animation: animation)
    }
    
    internal func animateToZoomScale(_ magnification: CGFloat, location: UnitPoint, animation: Animation = .spring) {
        withAnimation(animation) {
            self.zoomScale = magnification
            self.translation = self.clampTranslationToFit(self.translation, in: self.lastKnownContainerSize)
        }
    }
}

//MARK: Calculating and setting translation

extension InteractiveImageItem {
    internal func activeTranslation(value: DragGesture.Value?, zoomScaleValue: MagnifyGesture.Value?, in bounds: CGSize) -> CGSize {
        self.lastKnownContainerSize = bounds
        
        guard let translation = value?.translation else {
            return self.translation.scaled(zoomScaleValue?.magnification)
        }
        
        return CGSize(width: self.translation.width + translation.width, height: self.translation.height + translation.height)
    }
    
    internal func finalizeTranslation(value: DragGesture.Value, animation: Animation = .spring) {
        let lastKnownContainerSize = self.lastKnownContainerSize
        self.translation = self.activeTranslation(value: value, zoomScaleValue: nil, in: lastKnownContainerSize)
        
        // Clamp value within bounds
        withAnimation(animation) {
            self.translation = self.clampTranslationToFit(self.translation, in: lastKnownContainerSize)
        }
    }
    
    private func clampTranslationToFit(_ value: CGSize, in bounds: CGSize) -> CGSize {
        let maxTranslation = self.maximumTranslation(in: bounds)
        let horizontalTranslation = clamp(min: -maxTranslation.width, value: value.width, max: maxTranslation.width)
        let verticalTranslation = clamp(min: -maxTranslation.height, value: value.height, max: maxTranslation.height)
        
        return CGSize(width: horizontalTranslation, height: verticalTranslation)
    }
    
    private func maximumTranslation(in bounds: CGSize) -> CGSize {
        let aspectRatio = self.imageSize
        let boundingRect = CGRect(origin: .zero, size: bounds)
        let resizedImage = AVMakeRect(aspectRatio: aspectRatio, insideRect: boundingRect)
        let scaledImageSize = CGSize(width: resizedImage.width * self.zoomScale, height: resizedImage.height * self.zoomScale)
        let maximumHorizontalTranslation: CGFloat = max(0.0, scaledImageSize.width - bounds.width) / 2.0
        let maximumVerticalTranslation: CGFloat = max(0.0, scaledImageSize.height - bounds.height) / 2.0
        return CGSize(width: maximumHorizontalTranslation, height: maximumVerticalTranslation)
    }
}
