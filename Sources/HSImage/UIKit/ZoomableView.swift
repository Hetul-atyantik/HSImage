//
//  ZoomableView.swift
//  
//
//  Created by Hetul Soni on 03/10/23.
//

import SwiftUI

struct ZoomableView: UIViewRepresentable {
    
    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    @Binding var offset: CGSize
    @Binding var isPinching: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ZoomableUIView {
        let pinchZoomView = ZoomableUIView()
        pinchZoomView.delegate = context.coordinator
        return pinchZoomView
    }
    
    func updateUIView(_ pageControl: ZoomableUIView, context: Context) { }
    
    class Coordinator: NSObject, ZoomableViewDelgate {
        var pinchZoom: ZoomableView
        
        init(_ pinchZoom: ZoomableView) {
            self.pinchZoom = pinchZoom
        }
        
        func pinchZoomView(_ pinchZoomView: ZoomableUIView, didChangePinching isPinching: Bool) {
            pinchZoom.isPinching = isPinching
        }
        
        func pinchZoomView(_ pinchZoomView: ZoomableUIView, didChangeScale scale: CGFloat) {
            pinchZoom.scale = scale
        }
        
        func pinchZoomView(_ pinchZoomView: ZoomableUIView, didChangeAnchor anchor: UnitPoint) {
            pinchZoom.anchor = anchor
        }
        
        func pinchZoomView(_ pinchZoomView: ZoomableUIView, didChangeOffset offset: CGSize) {
            pinchZoom.offset = offset
        }
    }
}
