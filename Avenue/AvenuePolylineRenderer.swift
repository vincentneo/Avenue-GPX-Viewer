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
        let roadWidth = MKRoadWidthAtZoomScale(zoomScale) * 2
        
        var drawRect = NSRect(origin: .zero, size: CGSize(width: roadWidth, height: roadWidth))
        guard let cgImage = image.cgImage(forProposedRect: &drawRect, context: .current, hints: nil) else { return }
        
        let mapPoints = self.polyline.points()
        
        var prevMapPoint: MKMapPoint?
        
        for idx in 0..<self.polyline.pointCount - 2 {
            guard mapRect.contains(mapPoints[idx]) || mapRect.contains(mapPoints[idx + 1]) else { continue }
            let startMapPoint = mapPoints[idx]
            let endMapPoint = mapPoints[idx + 1]
            let startPoint = self.point(for: startMapPoint)
            let endPoint = self.point(for: endMapPoint)
            let region = MKCoordinateRegion(mapRect)
            let latDist = region.span.latitudeDelta * 110574 // https://ada-lovecraft.github.io/post/geopositional-deltas-expressed-as-meters/
            let distanceFilter = 0.12 * latDist
            
            if let previous = prevMapPoint {
                if previous.distance(to: endMapPoint) > distanceFilter {
                    prevMapPoint = nil
                }
                else {
                    continue
                }
            }
            else if startMapPoint.distance(to: endMapPoint) < distanceFilter {
                prevMapPoint = startMapPoint
                continue
            }

            //let midPoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
            let bearing = atan2(startPoint.y - endPoint.y, startPoint.x - endPoint.x) - .pi
            let scaleTransform = CGAffineTransform(scaleX: 1, y: -1)
            let adjustedBearing = -((2.5 * .pi) + bearing)
            let rotateTransform = scaleTransform.rotated(by: adjustedBearing)
            let transformed = startPoint.applying(rotateTransform)
            let newPoint = CGPoint(x: transformed.x - drawRect.midX, y: transformed.y - drawRect.midY)
            context.saveGState()
            context.scaleBy(x: 1, y: -1)
            context.rotate(by: adjustedBearing)
            context.setBlendMode(.luminosity)
            context.setAlpha(0.85)
            context.draw(cgImage, in: NSRect(origin: newPoint, size: drawRect.size))
            context.restoreGState()
            
        }
        
        
    }

}
