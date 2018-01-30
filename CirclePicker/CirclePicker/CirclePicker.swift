//
//  CirclePicker.swift
//  CirclePicker
//
//  Created by Tim Kreuzer on 18.01.18.
//  Copyright © 2018 Tim Kreuzer. All rights reserved.
//

import UIKit

class CirclePicker: UIView
{
    // Public members
    
    // The pickers delegate and dataSource
    var delegate : CirclePickerDelegate?
    var dataSource : CirclePickerDataSource?
    // specifies the size for the pickers cells
    var cellSize = CGFloat(64)
    
    var isActive: Bool
    {
        get
        {
            return active
        }
    }
    
    
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
    // Background image for the picker
    var background : UIImage?
    {
        didSet
        {
            backgroundImage.image = background
        }
    }
    
    
    // Private members
    
    // The view hierarchy
    private var contentView: UIView!
    private var centerView: UIView!
    private var backgroundImage: UIImageView!
    private var backgroundWidth : NSLayoutConstraint!
    private var imageViews : [UIImageView]?
    
    private var gesture: UILongPressGestureRecognizer!
    // The parent, that the picker is attached to
    private var parent: UIView?
    private var middle: CGPoint!
    private var topViewOrigin : CGPoint?
    private var active = false
    
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
        bounds = CGRect(x: 0, y: 0, width: 0, height:0)
        
        // Create views
        contentView = UIView()
        centerView = UIView()
        backgroundImage = UIImageView()
        
        // Setup view hierarchy
        centerView.frame.origin = contentView.center
        contentView.addSubview(centerView)
        contentView.addSubview(backgroundImage)
        addSubview(contentView)
        
        // Add constraints
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundWidth = NSLayoutConstraint(item: backgroundImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
        backgroundImage.addConstraint(backgroundWidth)
        backgroundImage.addConstraint(NSLayoutConstraint(item: backgroundImage, attribute: .height, relatedBy: .equal, toItem: backgroundImage , attribute: .width, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: backgroundImage, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: backgroundImage, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
    
    // Public functions
    
    // Attaches the picker to a certain view.
    // It will always be triggered on a long-press-gesture
    func attachToView(_ view: UIView)
    {
        self.parent = view
        view.isUserInteractionEnabled = true
        gesture = UILongPressGestureRecognizer(target: self, action: #selector(gestureDetected))
        if let duration = minimumPressDuration
        {
            gesture.minimumPressDuration = duration
        }
        view.addGestureRecognizer(gesture)
    }
    
    // Removes the picker from its attached view
    // No further gestures will be recognized
    func removeFromView()
    {
        if let gesture = gesture
        {
            parent?.removeGestureRecognizer(gesture)
        }
        parent = nil
        gesture = nil
    }
    
    // Private functions
    
    @objc private func gestureDetected(gesture: UILongPressGestureRecognizer)
    {
        // First touch - Picker will show up
        if(gesture.state == .began)
        {
            active = true
            let pos = gesture.location(in: parent)
            middle = pos
            self.frame.origin = pos
            parent?.addSubview(self)
            if background != nil
            {
                backgroundImage.alpha = 0
                backgroundWidth.constant = cellSize*3
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
                    self.backgroundImage.alpha = 1
                }, completion: nil)
            }
            createImageViews()
            delegate?.didStartSelection?(in: self)
        }
            // Called on every touch between start and end of the long-press
        else if(gesture.state == .changed)
        {
            cellTouched(gesture.location(in: parent))
        }
            // Touch has ended. Remove the picker and reset it.
        else if(gesture.state == .ended)
        {
            // TopView was set. Reset the translation
            if let v = topView
            {
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
                    v.transform = CGAffineTransform.identity
                }, completion: nil)
            }
            if let images = imageViews
            {
                for image in images
                {
                    image.removeFromSuperview()
                }
            }
            
            self.removeFromSuperview()
            
            if let index = selectedCellIndex
            {
                delegate?.circlePicker?(self, didEndSelectionAt: index)
            }
            selectedCellIndex = nil
            active = false
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
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
                    
                    let dx = self.middle.x - self.topViewOrigin!.x - v.frame.width/2
                    let dy = self.middle.y - self.topViewOrigin!.y - self.cellSize*1.8 - v.frame.height
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
        // Resize the image to fit into the circle
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
        case .none:
            // Calculate the position for the image
            let angle = 360.0/Double(data.numberOfCells(in: self))*Double(index)
            let radius = CGFloat(contentView.frame.width + CGFloat(1.1)*cellSize)
            
            let x = radius * CGFloat(sin(degreeToRadians(angle)))
            let y = -radius * CGFloat(cos(degreeToRadians(angle)))
            
            // Move the image to the right point
            image.frame.origin = CGPoint(x: -cellSize/2+x, y: -cellSize/2+y)
            
        case .fade:
            // Image is transparent before the animation
            image.alpha = 0
            
            // Calculate the position for the image
            let angle = 360.0/Double(data.numberOfCells(in: self))*Double(index)
            let radius = CGFloat(contentView.frame.width + CGFloat(1.1)*cellSize)
            
            let x = radius * CGFloat(sin(degreeToRadians(angle)))
            let y = -radius * CGFloat(cos(degreeToRadians(angle)))
            
            // Move the image to the right point
            image.frame.origin = CGPoint(x: -cellSize/2+x, y: -cellSize/2+y)
            
            // Fade the image in
            UIView.animate(withDuration: animationDuration, delay: 0.1*Double(index), options: .curveEaseInOut, animations: {
                image.alpha = 1
            }, completion: nil)
        case .unfold:
            // Move the image to the center
            image.frame.origin = CGPoint(x: -cellSize/2, y: -cellSize/2)
            
            // Calculate the position for the image
            let angle = 360.0/Double(data.numberOfCells(in: self))*Double(index)
            let radius = CGFloat(contentView.frame.width + CGFloat(1.1)*cellSize)
            
            let x = radius * CGFloat(sin(degreeToRadians(angle)))
            let y = -radius * CGFloat(cos(degreeToRadians(angle)))
            
            // Move the image to the right point
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
        case unfold, scatter, fade, none
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

