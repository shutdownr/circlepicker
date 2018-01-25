//
//  CirclePicker.swift
//  CirclePicker
//
//  Created by Tim Kreuzer on 18.01.18.
//  Copyright © 2018 Tim Kreuzer. All rights reserved.
//

import UIKit

class CirclePicker: UIView {
    
    // Outlets
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var centerView: UIView!
    
    // Public members
    
    // The pickers delegate and dataSource
    var delegate : CirclePickerDelegate?
    var dataSource : CirclePickerDataSource?
    // specifies the size for the pickers cells
    var cellSize = CGFloat(64)
    // the currently selected cell index. nil if none is selected
    var selectedCellIndex: Int?
    // the duration required for the longPress-gesture
    var minimumPressDuration : Double?
    {
        didSet
        {
            if gesture != nil
            {
                gesture.minimumPressDuration = minimumPressDuration!
            }
        }
    }
    // the animationtype for displaying the picker
    var animationType: CirclePickerAnimationType = .unfold
    // the duration of the creating animation
    var animationDuration = 0.4
    // bool, that indicates whether the images should be scaled to fit inside the circles or not
    var resizeImages = true
    // The subject of change for the picker. Moved on top of the picker when displayed
    var topView: UIView?
    {
        didSet
        {
            topViewOrigin = topView?.frame.origin
        }
    }
    
    // Private members
    
    private var imageViews : [UIImageView]?
    private var gesture: UILongPressGestureRecognizer!
    private var view: UIView?
    private var middle: CGPoint!
    private var topViewOrigin : CGPoint?
    
    // Initializers
    init()
    {
        super.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        circlePickerInit()
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        circlePickerInit()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        circlePickerInit()
    }
    
    private func circlePickerInit()
    {
        bounds = CGRect(x: 0, y: 0, width: 0, height: 0)
        Bundle.main.loadNibNamed("CirclePicker", owner: self, options: nil)
        addSubview(contentView)
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
    }
    
    // Public functions
    
    // Attaches the picker to a certain view.
    // It will always be triggered on a long-press-gesture
    func attachToView(_ view: UIView)
    {
        self.view = view
        view.isUserInteractionEnabled = true
        gesture = UILongPressGestureRecognizer(target: self, action: #selector(gestureDetected))
        if let duration = minimumPressDuration
        {
            gesture.minimumPressDuration = duration
        }
        view.addGestureRecognizer(gesture)
    }
    
    // Private functions
    
    @objc private func gestureDetected(gesture: UILongPressGestureRecognizer)
    {
        // First touch - Picker will show up
        if(gesture.state == .began)
        {
            let pos = gesture.location(in: view)
            middle = pos
            self.frame.origin = pos
            view?.addSubview(self)
            createImageViews()
        }
            // Called on every touch between start and end of the long-press
        else if(gesture.state == .changed)
        {
            cellTouched(gesture.location(in: view))
        }
            // Touch has ended. Remove the picker and reset it.
        else if(gesture.state == .ended)
        {
            // TopView was set. Reset the translation
            if let v = topView
            {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    v.transform = CGAffineTransform.identity
                }, completion: nil)
            }
            if let index = selectedCellIndex
            {
                delegate?.circlePicker?(self, didEndSelectionAt: index)
            }
            if let images = imageViews
            {
                for image in images
                {
                    image.removeFromSuperview()
                }
            }
            self.removeFromSuperview()
            selectedCellIndex = nil
        }
    }
    
    // This function creates all the imageViews for the picker,
    // animates them and appends them to the contentView
    private func createImageViews()
    {
        if let data = dataSource
        {
            imageViews = []
            
            
            // The point for creating the images doesn't matter at all
            // The bezierPath will specify the exact position of the image later on
            let point = CGPoint(x: 0, y: 0)
            let rect = CGRect(origin: point, size: CGSize(width: cellSize, height: cellSize))
            
            // TopView is set -> Move it above the picker
            if let v = topView
            {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    
                    let dx = self.middle.x - self.topViewOrigin!.x - self.topView!.frame.width/2
                    let dy = self.middle.y - self.topViewOrigin!.y - self.cellSize*2
                    v.transform = CGAffineTransform(translationX: dx, y: dy)
                }, completion: nil)
            }
            
            for index in 0..<data.numberOfCells(in: self)
            {
                // Create imageView
                let imageView = createImageView(frame: rect, image: data.circlePicker(self, imageForIndex: index))
                // Animate the imageView
                animateImage(index: index, image: imageView, data: data)
                // Add the view to the contentView
                contentView.addSubview(imageView)
                imageViews!.append(imageView)
            }
        }
    }
    
    // Function for creating the images for the picker
    private func createImageView(frame: CGRect, image: UIImage) -> UIImageView
    {
        let imageView = UIImageView(frame: frame)
        var newImage = image
        if(resizeImages)
        {
            let newWidth = imageView.frame.width / sqrt(2)
            let newSize = CGSize(width: newWidth, height: newWidth)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
            image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            imageView.contentMode = .center
        }
        imageView.image = newImage
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        
        return imageView
    }
    
    private func animateImage(index: Int, image:UIImageView, data: CirclePickerDataSource)
    {
        switch animationType {
        case .fade:
            image.alpha = 0
            let angle = 360.0/Double(data.numberOfCells(in: self))*Double(index)
            var x = CGFloat(0)
            var y = CGFloat(0)
            let radius = CGFloat(contentView.frame.width + CGFloat(1.1)*cellSize)
            
            x = radius * CGFloat(sin(degreeToRadians(angle)))
            y = -radius * CGFloat(cos(degreeToRadians(angle)))
            
            image.frame.origin = CGPoint(x: -cellSize/2+x, y: -cellSize/2+y)
            
            UIView.animate(withDuration: animationDuration, delay: 0.1*Double(index), options: .curveEaseInOut, animations: {
                image.alpha = 1
            }, completion: nil)
        case .unfold:
            image.frame.origin = CGPoint(x: -cellSize/2, y: -cellSize/2)
            let angle = 360.0/Double(data.numberOfCells(in: self))*Double(index)
            var x = CGFloat(0)
            var y = CGFloat(0)
            let radius = CGFloat(contentView.frame.width + CGFloat(1.1)*cellSize)
            
            x = radius * CGFloat(sin(degreeToRadians(angle)))
            y = -radius * CGFloat(cos(degreeToRadians(angle)))
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                image.transform = CGAffineTransform(translationX: x, y: y)
            }, completion: nil)
        case .scatter:
            let middle = contentView.center
            let startAngle = degreeToRadians(-90)
            
            
            // Animation for rotating the image to the right position
            let animation = CAKeyframeAnimation(keyPath: "position")
            animation.duration = animationDuration
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            // Rotate clockwise for <= 180 degrees, otherwise counterclockwise
            let clockwise = index>data.numberOfCells(in: self)/2 ? false : true
            
            let endAngle = degreeToRadians(Double(index * 360/data.numberOfCells(in: self))) + startAngle
            let circlePath = UIBezierPath(arcCenter: middle, radius: self.contentView.frame.width + CGFloat(1.1)*self.cellSize, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: clockwise)
            
            animation.path = circlePath.cgPath
            
            // Start the animation
            image.layer.add(animation, forKey: "position")
            image.layer.position = circlePath.currentPoint
        }
    }
    
    // Convenience function for converting degrees to radians
    private func degreeToRadians(_ degree:Double) -> Double
    {
        return 2*Double.pi*degree/360.0
    }
    
    // This function determines if a cell was touched. The delegate
    // receives info about which cell was touched.
    private func cellTouched(_ position: CGPoint)
    {
        let fingerPos = CGPoint(x: position.x-middle.x, y: position.y-middle.y)
        
        var i = 0
        if(centerView.contains(point: fingerPos))
        {
            // Touch in the center-view.
            // No cell is currently selected.
            cellSelected(index: -1)
            selectedCellIndex = nil
            return
        }
        if let imageViews = imageViews
        {
            // Check for every image if it contains the position that was touched
            for image in imageViews
            {
                if(image.circleContains(point: fingerPos))
                {
                    // Cell was touched. Call the delegate and set the cell-state to selected
                    delegate?.circlePicker?(self, didSelectRowAt: i)
                    cellSelected(index: i)
                    return
                }
                i+=1
            }
        }
    }
    
    private func cellSelected(index: Int)
    {
        // Check if the same cell is still selected
        // Make no changes in that case
        if(index==selectedCellIndex)
        {
            return
        }
        if let imageViews = imageViews
        {
            // A specific cell was selected before
            // Set this cell to default
            if let selected = selectedCellIndex
            {
                delegate?.circlePicker?(self, didDeselectRowAt: selected)
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    let transform = imageViews[selected].transform
                    imageViews[selected].transform = transform.concatenating(CGAffineTransform(scaleX: 1/1.2, y: 1/1.2))
                }, completion: nil)
            }
            
            if(index < 0 || index >= imageViews.count){ return }
            // Apply selected-state to the currently selected cell
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                let transform = imageViews[index].transform
                imageViews[index].transform = transform.concatenating(CGAffineTransform(scaleX: 1.2, y: 1.2))
            }, completion: nil)
        }
        // Set currently selected index
        selectedCellIndex = index
    }
    
    enum CirclePickerAnimationType
    {
        case unfold, scatter, fade
    }
    
}

// Extension for special contains-methods
private extension UIView
{
    func contains(point: CGPoint) -> Bool
    {
        if(point.x>frame.origin.x+frame.width || point.x<frame.origin.x)
        {
            return false
        }
        if(point.y>frame.origin.y+frame.height || point.y<frame.origin.y)
        {
            return false
        }
        return true
    }
    // Check if the point is inside the UIView with Circle-Shape
    func circleContains(point:CGPoint) -> Bool
    {
        let centerx = frame.origin.x + frame.width/2
        let centery = frame.origin.y + frame.width/2
        let deltax = pow(point.x-centerx, CGFloat(2))
        let deltay = pow(point.y-centery, CGFloat(2))
        let distance = sqrt(Double(deltax+deltay))
        if(distance<=Double(frame.width/2))
        {
            return true
        }
        return false
    }
}


