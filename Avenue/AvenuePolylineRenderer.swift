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
    

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)
        let roadWidth = MKRoadWidthAtZoomScale(zoomScale) * 1.5
        
        var drawRect = NSRect(origin: .zero, size: CGSize(width: roadWidth, height: roadWidth))
//        let screenRect = self.rect(for: mapRect)
//        if #available(macOS 11.0, *) {
//            context.saveGState()
//            context.setFillColor(NSColor.yellow.cgColor)
//            context.fill([CGRect(origin: .zero, size: .init(width: 100, height: 100))])
//            context.translateBy(x: 0, y: 200)
//            context.scaleBy(x: 1, y: -1)
//            context.draw(NSImage(named: "modern-doc-icon-fill")!.cgImage(forProposedRect: &x, context: .current, hints: nil)!, in: NSRect(origin: .init(x: 200, y: 200), size: x.size))
//            context.restoreGState()
//        } else {
//            // Fallback on earlier versions
//        }
        
        let mapPoints = self.polyline.points()
        
        if zoomScale >= 0.1 {
            for idx in 0..<self.polyline.pointCount - 2 {
                guard mapRect.contains(mapPoints[idx]) || mapRect.contains(mapPoints[idx + 1]) else { continue }
                let startPoint = self.point(for: mapPoints[idx])
                let endPoint = self.point(for: mapPoints[idx + 1])
                
                let midPoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
                let bearing =  (atan2(startPoint.y - endPoint.y, startPoint.x - endPoint.x) - .pi)
                //print("ANG \(360 + 90 + (bearing * 180 / .pi)) ")
                if #available(macOS 11.0, *) {
                    let affirm = CGAffineTransform(scaleX: 1, y: -1)
                    let adjustedBearing = -((2.5 * .pi) + bearing)
                    let rotate = affirm.rotated(by: adjustedBearing)
                    let transformed = startPoint.applying(rotate)
                    let newPoint = CGPoint(x: transformed.x - drawRect.midX, y: transformed.y - drawRect.midY)
                    context.saveGState()
                    context.scaleBy(x: 1, y: -1)
                    context.rotate(by: adjustedBearing)
                    context.draw(NSImage(systemSymbolName: "arrow.up", accessibilityDescription: nil)!.cgImage(forProposedRect: &drawRect, context: .current, hints: nil)!, in: NSRect(origin: newPoint, size: drawRect.size))
                    context.restoreGState()
                }
            }
        }
        
    }

}
