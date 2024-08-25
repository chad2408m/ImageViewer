//
//  ImageResizingView.swift
//
//
//  Created by Chad Meyers on 8/18/24.
//

import Foundation
import SwiftUI

//CMMTODO: Document
public struct ImageItemViewer: View {
    @Binding private var imageItem: InteractiveImageItem
    @State private var activeScaleValue: MagnifyGesture.Value? = nil
    @State private var activeDragValue: DragGesture.Value? = nil
    private let maxScale: CGFloat?
    
    /// Creates a new image item viewer which displays the specified image.
    ///
    /// - Parameters:
    ///   - item: A binding to the item to display inside the image viewer.
    ///   - maxScale: The maximum scale to allow the user to magnify the image by, relative to the size of this view inside it's parent. Pass `nil` to allow infinite zoom.
    public init(item: Binding<InteractiveImageItem>, maxScale: CGFloat? = nil) {
        self._imageItem = item
        self.maxScale = maxScale
    }
}

//MARK: Helper initializers

//MARK: View body

extension ImageItemViewer {
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                let scale = self.imageItem.activeZoomScale(value: self.activeScaleValue, maxScale: self.maxScale)
                let translation = self.imageItem.activeTranslation(value: self.activeDragValue, zoomScaleValue: self.activeScaleValue, in: proxy.size)
                
#if DEBUG
                self.debugView(bounds: proxy.size, viewScale: scale, viewPan: translation)
#endif
                
                self.imageItem.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .border(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(scale)
                    .offset(translation)
            }
        }
        .animation(.spring, value: self.imageItem.zoomScale)
        .contentShape(Rectangle())
        .gesture(self.interactiveGestures)
        .accessibilityZoomAction(self.performAutomaticZoomGesture(action:))
        .border(.blue)
    }
}

//MARK: Gestures

extension ImageItemViewer {
    private var interactiveGestures: some Gesture {
        return self.scaleGesture.simultaneously(with: self.panGesture)
            .exclusively(before: self.doubleTapZoomGesture)
    }
    
    private var doubleTapZoomGesture: some Gesture {
        return TapGesture(count: 2)
            .onEnded { _ in
                self.performAutomaticZoomGesture(location: .center)
            }
    }
    
    private var scaleGesture: some Gesture {
        return MagnifyGesture()
            .onChanged { value in
                self.activeScaleValue = value
            }
            .onEnded { value in
                self.imageItem.finalizeZoomScale(value: value, maxScale: self.maxScale)
                self.activeScaleValue = nil
            }
    }
    
    private var panGesture: some Gesture {
        return DragGesture()
            .onChanged { value in
                self.activeDragValue = value
            }
            .onEnded { value in
                self.imageItem.finalizeTranslation(value: value)
                self.activeDragValue = nil
            }
    }
}

//MARK: Action handling

extension ImageItemViewer {
    private func performAutomaticZoomGesture(action: AccessibilityZoomGestureAction) {
        self.performAutomaticZoomGesture(direction: action.direction, location: action.location)
    }
    
    private func performAutomaticZoomGesture(direction: AccessibilityZoomGestureAction.Direction? = nil, location: UnitPoint) {
        let direction = direction ?? (self.imageItem.zoomScale > 1.01 ? .zoomOut : .zoomIn)
        let zoomScale = direction == .zoomIn ? (self.maxScale ?? 3.0) : 1.0
        
        self.imageItem.animateToZoomScale(zoomScale, location: location)
    }
                                        
}

#if DEBUG
//MARK: Debugging

extension ImageItemViewer {
    @ViewBuilder
    private func debugView(bounds: CGSize, viewScale: CGFloat, viewPan: CGSize) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("View Bounds = \(bounds)")
                Text("Image = {\(self.imageItem.translation), \(self.imageItem.imageSize)}")
                Text("Image scale = \(self.imageItem.zoomScale)")
                Text("Active Scale = \(self.activeScaleValue?.magnification ?? 1.0)")
                Text("Active Pan = \(self.activeDragValue?.translation ?? .zero)")
                Text("View Scale = \(viewScale)")
                Text("View Pan = \(viewPan)")
                Spacer()
            }
            Spacer()
        }
        .padding(8.0)
    }
}

#endif

//MARK: Preview

#Preview() {
    NavigationStack {
        ImageItemViewer(image: Image(systemName: "person.circle"), 
                        size: CGSize(width: 40, height: 40),
                        maxScale: 3.0)
            .navigationTitle("Image viewer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbar(.visible, for: .navigationBar)
            .background {
                Image.checkerboardTile
                    .backgroundStyle(Color(white: 0.85))
                    .ignoresSafeArea()
            }
    }
}

extension Image {
    /// A checkerboard image which automatically tiles itself (for use as a background)
    fileprivate static var checkerboardTile: Image {
        Image(size: CGSize(width: 30.0, height: 30.0)) { context in
            context.fill(Path(CGRect(x: 0, y: 0, width: 15.0, height: 15.0)), with: .style(.background))
            context.fill(Path(CGRect(x: 15.0, y: 0, width: 15.0, height: 15.0)), with: .style(.background.tertiary))
            context.fill(Path(CGRect(x: 0, y: 15.0, width: 15.0, height: 15.0)), with: .style(.background.tertiary))
            context.fill(Path(CGRect(x: 15.0, y: 15.0, width: 15.0, height: 15.0)), with: .style(.background))
        }
        .resizable(resizingMode: .tile)
    }
}
