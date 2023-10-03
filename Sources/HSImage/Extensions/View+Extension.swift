//
//  View+Extension.swift
//  
//
//  Created by Hetul Soni on 03/10/23.
//

import SwiftUI

extension View {
    public func manageZoom(isZoomAllowed: Bool) -> some View {
        self.modifier(ZoomableViewModifier(isZoomAllowed: isZoomAllowed))
    }
}
