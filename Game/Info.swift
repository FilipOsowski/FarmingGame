//
//  Info.swift
//  Game Test 9
//
//  Created by Cat Blue on 12/2/17.
//

import SpriteKit

class Info: SKNode {
    
    var infoBodyImage = UIImage(named: "Info")!
    
    let infoText = SKLabelNode(fontNamed: "AppleSDGothicNeo-Regular")
    
    let resetPlotButton = SpriteNodeButton(imageNamed: "ResetPlot", "Reset the Plot")
    let removeCropButton = SpriteNodeButton(imageNamed: "RemoveCrop", "Remove Current Crop")
    let plantCropButton = SpriteNodeButton(imageNamed: "PlantCrop", "Plant Crop")
    let buyPlotButton = SpriteNodeButton(imageNamed: "BuyPlot", "Default Text")
    
    var plot: Plot!
    
    init(newPlot: Plot) {
        super.init()
        
        infoBodyImage = infoBodyImage.withRenderingMode(.alwaysTemplate)
        
        let infoBodyTexture = SKTexture(image: infoBodyImage)
        let infoBody = SKSpriteNode(texture: infoBodyTexture)
        
        
        addChild(infoBody)
        
        infoText.text = "Default text."
        infoText.numberOfLines = 0
        infoText.horizontalAlignmentMode = .center
        infoText.preferredMaxLayoutWidth = infoBody.size.width - 10
        infoText.fontColor = .black
        infoText.fontSize = 18
        infoText.zPosition = 1
        infoText.position = CGPoint(x: 0, y: 65 - infoText.fontSize)
        addChild(infoText)
        
        let allButtons = [plantCropButton, removeCropButton, resetPlotButton, buyPlotButton]
        let allFunctions = [#selector(plantCrop), #selector(removeCrop), #selector(resetPlot), #selector(buyPlot)]

        var space: CGFloat = 65
        for count in 0..<allButtons.count {
            allButtons[count].position = CGPoint(x: 0, y: space)
            allButtons[count].addTarget(self, newAction: allFunctions[count])
            allButtons[count].zPosition = 1
            space-=60
            addChild(allButtons[count])
        }
        
        buyPlotButton.position = allButtons[0].position
        buyPlotButton.label.fontColor = .black
        buyPlotButton.label.numberOfLines = 0
        buyPlotButton.label.preferredMaxLayoutWidth = infoBody.size.width - 40
        
        plot = newPlot
        
        isUserInteractionEnabled = true
    }
    
    func activate() {
        isHidden = false
        if let crop = plot.crop {
            if crop.currentStage == 1 {
                hide(false, true, false, false, true)
            }
            else {
                hide(false, false, true, true, true)
            }
        }
        else {
            hide(true, true, true, true, false)
            buyPlotButton.label.text = "Do you want to buy this plot for $\(plot.gameDelegate.getPriceOfNextPlot())?"
        }
    }
    
    func hide(_ resetPlotIsHidden: Bool, _ plantCropIsHidden: Bool, _ removeCropIsHidden: Bool, _ infoTextIsHidden: Bool, _ buyPlotIsHidden: Bool) {
        resetPlotButton.isHidden = resetPlotIsHidden
        plantCropButton.isHidden = plantCropIsHidden
        removeCropButton.isHidden = removeCropIsHidden
        infoText.isHidden = infoTextIsHidden
        buyPlotButton.isHidden = buyPlotIsHidden
    }
    
    func deactivate() {
        isHidden = true
    }
    
    @objc func plantCrop() {
        plot.crop!.gameDelegate.changeCropPickerState(isHidden: false, plot.crop)
    }
    
    @objc func removeCrop() {
        plot.changePlotFunctionTo("newCrop")
    }
    
    @objc func resetPlot() {
        plot.changePlotFunctionTo("plot")
    }
    
    @objc func buyPlot() {
        if plot.gameDelegate.updateMoney(changeInMoney: -plot.gameDelegate.getPriceOfNextPlot()) {
            plot.changePlotFunctionTo("plot")
            plot.gameDelegate.updatePurchaseablePlots()
        }
    }
    
    func changeInfoTextTo(_ newText: String) {
        infoText.text = newText
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
