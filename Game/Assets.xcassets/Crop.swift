//
//  Item.swift
//  Game Test 4
//
//  Created by Cat Blue on 9/21/17.
//
//

import Foundation
import SpriteKit

class Crop: SKSpriteNode {
    var cropInfo: Info!
    
    let dirtImage = SKTexture(imageNamed: "Dirt")
    var growingImage: SKTexture!
    var readyToHarvestImage: SKTexture!
    
    var currentTexture: SKTexture!
    
    var cropProperties: [NSMutableDictionary]!
    
    var gameDelegate: GameDelegate!
    
    var currentStage = 3 {
        didSet {
            newStage()
        }
    }
    
    var cropType = 0
    
    var timeSinceLastStage = CFAbsoluteTimeGetCurrent()
    var timeToGrow: Double = 0
    
    var cropReward: Double!

    let stages = [0, 1, 2]

    init(data: [String: Any]?, newGameDelegate: GameDelegate, newCropInfo: Info) {
        gameDelegate = newGameDelegate
        
        super.init(texture: nil, color: .clear, size: CGSize(width: 100, height: 100))
        
        cropInfo = newCropInfo
        
        currentStage = 0
        newStage()
        
        cropProperties = gameDelegate.getCropProperties()
        
        if let existingData = data {
            setCrop(newCropType: existingData["cropType"] as! Int)
            currentStage = existingData["currentStage"] as! Int
            newStage()
            
            timeSinceLastStage = existingData["timeSinceLastStage"] as! CFAbsoluteTime
        }
        
        isUserInteractionEnabled = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameDelegate.validTouch() {
            touchUpdate()
        }
    }
    
    func update() {
        if (CFAbsoluteTimeGetCurrent() - timeSinceLastStage > timeToGrow) {
            checkStage()
        }
        
        if cropInfo.isHidden == false {
            cropInfo.changeInfoTextTo(getTime())
        }
    }
    
    func setCrop(newCropType: Int) {
        cropType = newCropType
        growingImage = SKTexture(imageNamed: cropProperties[cropType]["growingImage"] as! String)
        readyToHarvestImage = SKTexture(imageNamed: cropProperties[cropType]["readyToHarvestImage"] as! String)
        cropReward = cropProperties[cropType]["cropReward"] as! Double
        timeToGrow = cropProperties[cropType]["timeToGrow"] as! Double
    }
    
    func getCropData() -> NSDictionary {
        let data = NSMutableDictionary()
        data["currentStage"] = currentStage
        data["timeSinceLastStage"] = timeSinceLastStage
        data["timeToGrow"] = timeToGrow
        data["cropType"] = cropType
        data["cropReward"] = cropReward
        return data
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func newStage() {
        timeSinceLastStage = CFAbsoluteTimeGetCurrent()
        switch currentStage {
        case 0:
            currentTexture = dirtImage
        case 1:
            currentTexture = growingImage
        case 2:
            currentTexture = readyToHarvestImage
        default:
            break
        }
        
        let plot = parent as? Plot
        plot?.plotSpriteNode.texture = currentTexture
    }
    
    func checkStage() {
        if currentStage != 0 && currentStage != 2 {
            currentStage+=1
        }
    }
    
    func touchUpdate() {
        if currentStage != 2 && gameDelegate.getCropPickerHiddenState() {
            if cropInfo.isHidden == true {
                gameDelegate.closeInfo()
                cropInfo.activate()
            }
            else {
                cropInfo.deactivate()
            }
        }
        else {
            gameDelegate.changeCropPickerState(isHidden: true, nil)
            
            if currentStage == 2 {
                let _ = gameDelegate.updateMoney(changeInMoney: cropReward)
                currentStage = 0
                gameDelegate.closeInfo()
            }
        }
    }
    
    func getTime() -> String {
        let timeRemaining = CFAbsoluteTimeGetCurrent() - timeSinceLastStage
        
        if (timeRemaining < timeToGrow && currentStage == 1) {
            return  "Time remaining: \n\(String(Int(timeToGrow - abs(CFAbsoluteTimeGetCurrent() - timeSinceLastStage)) + 1)) seconds."
        }
        else {
            return "This crop is ready to be harvested."
        }
    }
    
    func getNotificationMessage() -> String? {
        let plot = parent as! Plot
        let pos = plot.positionInArray!
        return ((CFAbsoluteTimeGetCurrent() - timeSinceLastStage < timeToGrow) && currentStage == 1 ? "Crop with crop type \(cropType) and position of (\(pos.x), \(pos.y)) is ready to be harvested." : nil)
    }
    
    func getNotificationTime() -> TimeInterval {
        return timeToGrow - (CFAbsoluteTimeGetCurrent() - timeSinceLastStage) + 1
    }
}
