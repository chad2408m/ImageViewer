//
//  InteractiveImageItem+Cropping.swift
//
//
//  Created by Chad Meyers on 8/25/24.
//

import AVFoundation
import Foundation
import SwiftUI
import UIKit

extension InteractiveImageItem {
    //CMMTODO: Document
    public var croppedImage: Image {
        get async {
            return Image(uiImage: await self.croppedUIImage)
        }
    }
    
    //CMMTODO: Document
    public var croppedUIImage: UIImage {
        get async {
            return UIImage(cgImage: await self.croppedCGImage)
        }
    }
    
    //CMMTODO: Document
    @MainActor
    public var croppedCGImage: CGImage {
        get async {
            guard let cgImage = self.imageRenderer.cgImage else {
                //CMMTODO: Create a black cgImage of the specified image size when unable to render
                fatalError("Not yet implemented")
            }
            
            return cgImage
        }
    }
    
    @MainActor
    private var imageRenderer: ImageRenderer<AnyView> {
        let viewContent: some View = {
            self.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: self.lastKnownContainerSize.width, height: self.lastKnownContainerSize.height)
                .scaleEffect(self.zoomScale)
                .offset(self.translation)
        }()
        
        let clippedFrame = AVMakeRect(aspectRatio: CGSize(width: 1, height: 1), insideRect: CGRect(origin: .zero, size: self.lastKnownContainerSize))
                                      
        let clippedContent: some View = {
            viewContent
                .frame(width: clippedFrame.width, height: clippedFrame.height)
            //CMMTODO: Insert padding
                .clipped()
        }()
        
        return ImageRenderer(content: AnyView(clippedContent))
    }
}
