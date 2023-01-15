//
//  AvenuePolylineRenderer.swift
//  Avenue
//
//  Created by Vincent Neo on 14/1/23.
//  Copyright © 2023 Vincent. All rights reserved.
//

import Cocoa
import MapKit

class AvenuePolylineRenderer: MKPolylineRenderer {
    private let image = NSImage(named: "route-arrow")!

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)
        let roadWidth = MKRoadWidthAtZoomScale(zoomScale) * 3
        
        var drawRect = NSRect(origin: .zero, size: CGSize(width: roadWidth, height: roadWidth))
        guard let cgImage = image.cgImage(forProposedRect: &drawRect, context: .current, hints: nil) else { return }
        
        let mapPoints = self.polyline.points()
        
        if zoomScale >= 0.2 {
            for idx in 0..<self.polyline.pointCount - 2 {
                guard mapRect.contains(mapPoints[idx]) || mapRect.contains(mapPoints[idx + 1]) else { continue }
                let startPoint = self.point(for: mapPoints[idx])
                let endPoint = self.point(for: mapPoints[idx + 1])
                
                //let midPoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
                let bearing =  (atan2(startPoint.y - endPoint.y, startPoint.x - endPoint.x) - .pi)
                
                let affirm = CGAffineTransform(scaleX: 1, y: -1)
                let adjustedBearing = -((2.5 * .pi) + bearing)
                let rotate = affirm.rotated(by: adjustedBearing)
                let transformed = startPoint.applying(rotate)
                let newPoint = CGPoint(x: transformed.x - drawRect.midX, y: transformed.y - drawRect.midY)
                context.saveGState()
                context.scaleBy(x: 1, y: -1)
                context.rotate(by: adjustedBearing)
                context.setBlendMode(.luminosity)
                context.draw(cgImage, in: NSRect(origin: newPoint, size: drawRect.size))
                context.restoreGState()
                
            }
        }
        
    }

}
