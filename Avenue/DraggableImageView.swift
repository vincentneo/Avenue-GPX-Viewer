//
//  DraggableImageView.swift
//
//  https://github.com/raphaelhanneken/iconizer
//  https://gist.github.com/raphaelhanneken/d77b6f9b01bef35709da
//

import Cocoa

class DraggableImageView: NSImageView, NSDraggingSource {

    /// Holds the last mouse down event, to track the drag distance.
    var mouseDownEvent: NSEvent?
    var fileURL: URL?
    var darkenFilter: CIFilter?
    

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    // MARK: - NSDraggingSource
    
    func draggingSession(_: NSDraggingSession,
                         sourceOperationMaskFor _: NSDraggingContext) -> NSDragOperation {
        return .copy
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let source = sender.draggingSource as? Self, source == self {
            return NSDragOperation.link
        }
        else {
            return NSDragOperation()
        }
    }

    override func mouseDown(with event: NSEvent) {
        if darkenFilter == nil {
            guard let filter = CIFilter(name: "CIExposureAdjust") else { return }
            filter.setValue(-1.0, forKey: "inputEV")
            self.darkenFilter = filter
        }
        
        self.compositingFilter = darkenFilter
        self.mouseDownEvent = event
        
        if let fileURL = fileURL, event.clickCount == 2 {
            NSWorkspace.shared.activateFileViewerSelecting([fileURL])
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        self.compositingFilter = nil
    }

    // Track mouse dragged events to handle dragging sessions.
    override func mouseDragged(with event: NSEvent) {

        // Calculate the dragging distance...
        let mouseDown = mouseDownEvent!.locationInWindow
        let dragPoint = event.locationInWindow
        let dragDistance = hypot(mouseDown.x - dragPoint.x, mouseDown.y - dragPoint.y)

        // Cancel the dragging session in case of an accidental drag.
        if dragDistance < 3 {
            return
        }

        guard let image = self.image else {
            return
        }

        // Do some math to properly resize the given image.
        let size = NSSize(width: log10(image.size.width) * 30, height: log10(image.size.height) * 30)

        if let draggingImage = image.crop(toSize: size) {

            guard let fileURL = fileURL else {
                return
            }
            
            // Create a new NSDraggingItem with the image as content.
            let draggingItem = NSDraggingItem(pasteboardWriter: fileURL as NSURL)

            // Calculate the mouseDown location from the window's coordinate system to the
            // ImageView's coordinate system, to use it as origin for the dragging frame.
            let draggingFrameOrigin = convert(mouseDown, from: nil)
            // Build the dragging frame and offset it by half the image size on each axis
            // to center the mouse cursor within the dragging frame.
            let draggingFrame = NSRect(origin: draggingFrameOrigin, size: draggingImage.size)
                .offsetBy(dx: -draggingImage.size.width / 2, dy: -draggingImage.size.height / 2)

            // Assign the dragging frame to the draggingFrame property of our dragging item.
            draggingItem.draggingFrame = draggingFrame

            // Provide the components of the dragging image.
            draggingItem.imageComponentsProvider = {
                let component = NSDraggingImageComponent(key: NSDraggingItem.ImageComponentKey.icon)

                component.contents = image
                component.frame = NSRect(origin: NSPoint(), size: draggingFrame.size)
                return [component]
            }
            

            // Begin actual dragging session. Woohow!
            beginDraggingSession(with: [draggingItem], event: mouseDownEvent!, source: self)
        }
    }
}
