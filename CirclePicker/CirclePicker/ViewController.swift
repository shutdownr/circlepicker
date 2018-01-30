//
//  ViewController.swift
//  CirclePickerTest
//
//  Created by Tim Kreuzer on 18.01.18.
//  Copyright © 2018 Tim Kreuzer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CirclePickerDelegate, CirclePickerDataSource
{
    
    @IBOutlet var centerLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    
    @IBOutlet var numberCtrl: UISegmentedControl!
    @IBOutlet var animationCtrl: UISegmentedControl!
    
    @IBOutlet var iconsSwitch: UISwitch!
    @IBOutlet var icon: UIImageView!

    @IBOutlet var picker: CirclePicker!
    
    //private var picker : CirclePicker!
    private var images : [UIImage]!
    private var currentImages : [UIImage]!
    private var icons : [UIImage]!
    private var currentIcons : [UIImage]!
    private var size : Float = 64.0
    

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background_grey.jpg")!)
        
        
        let image1 = UIImage.imageWithColor2(color: UIColor.red)
        let image2 = UIImage.imageWithColor2(color: UIColor.orange)
        let image3 = UIImage.imageWithColor2(color: UIColor.yellow)
        let image4 = UIImage.imageWithColor2(color: UIColor.green)
        let image5 = UIImage.imageWithColor2(color: UIColor.cyan)
        let image6 = UIImage.imageWithColor2(color: UIColor.blue)
        let image7 = UIImage.imageWithColor2(color: UIColor.magenta)
        let image8 = UIImage.imageWithColor2(color: UIColor.purple)
        
        let icon1 = UIImage(named: "camera.png")!
        let icon2 = UIImage(named: "clock.png")!
        let icon3 = UIImage(named: "heart.png")!
        let icon4 = UIImage(named: "home.png")!
        let icon5 = UIImage(named: "music.png")!
        let icon6 = UIImage(named: "rocket.png")!
        let icon7 = UIImage(named: "star.png")!
        let icon8 = UIImage(named: "wifi.png")!
        
        
        images = [image1,image2,image3,image4,image5,image6,image7,image8]
        currentImages = Array(images.prefix(numberCtrl.selectedSegmentIndex+1))
        icons = [icon1,icon2,icon3,icon4,icon5,icon6,icon7,icon8]
        currentIcons = Array(icons.prefix(numberCtrl.selectedSegmentIndex+1))
        
        //picker = CirclePicker()
        picker.delegate = self
        picker.dataSource = self
        picker.attachToView(view)
        
        picker.resizeImages = false
        picker.topView = centerLabel
        
        picker.background = UIImage(named: "pickerBackground.png")
    }
    @IBAction func segmentSelected(_ sender: UISegmentedControl)
    {
        currentImages = Array(images.prefix(sender.selectedSegmentIndex+1))
        currentIcons = Array(icons.prefix(sender.selectedSegmentIndex+1))
    }
    @IBAction func sliderChanged(_ sender: UISlider)
    {
        sizeLabel.text = String(sender.value)
        picker.cellSize = CGFloat(sender.value)
    }
    @IBAction func iconsChanged(_ sender: UISwitch)
    {
        picker.resizeImages = sender.isOn
    }
    
    @IBAction func animationSelected(_ sender: UISegmentedControl)
    {
        switch sender.selectedSegmentIndex
        {
        case 0:
            picker.animationType = .unfold
        case 1:
            picker.animationType = .scatter
        case 2:
            picker.animationType = .fade
        case 3:
            picker.animationType = .none
        default:
            break
        }
    }
    func numberOfCells(in: CirclePicker) -> Int
    {
        return iconsSwitch.isOn ? currentIcons.count : currentImages.count
    }
    
    func circlePicker(_: CirclePicker, imageForIndex index: Int) -> UIImage
    {
        return iconsSwitch.isOn ? currentIcons[index] : currentImages[index]
    }
    
    func circlePicker(_ circlePicker: CirclePicker, didEndSelectionAt position: Int)
    {
        if(iconsSwitch.isOn)
        {
            changeIcon(position)
        }
        else
        {
            changeColor(position)
        }
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeIcon(_ index: Int)
    {
        var image = UIImage()
        switch index
        {
        case 0:
            image = UIImage(named: "camera.png")!
        case 1:
            image = UIImage(named: "clock.png")!
        case 2:
            image = UIImage(named: "heart.png")!
        case 3:
            image = UIImage(named: "home.png")!
        case 4:
            image = UIImage(named: "music.png")!
        case 5:
            image = UIImage(named: "rocket.png")!
        case 6:
            image = UIImage(named: "star.png")!
        case 7:
            image = UIImage(named: "wifi.png")!
        default:
            image = UIImage(named: "camera.png")!
        }
        icon.image = image
    }
    
    func changeColor(_ index: Int)
    {
        var color = UIColor.black
        switch index
        {
        case 0:
            color = UIColor.red
        case 1:
            color = UIColor.orange
        case 2:
            color = UIColor.yellow
        case 3:
            color = UIColor.green
        case 4:
            color = UIColor.cyan
        case 5:
            color = UIColor.blue
        case 6:
            color = UIColor.magenta
        case 7:
            color = UIColor.purple
        default:
            color = UIColor.black
        }
        centerLabel.textColor = color
    }
    
    
}

private extension UIImage
{
    class func imageWithColor2(color: UIColor, size: CGSize=CGSize(width: 1, height: 1)) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

