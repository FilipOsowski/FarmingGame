//
//  Plot.swift
//  Game Test 9
//
//  Created by Cat Blue on 11/18/17.
//

import Foundation
import SpriteKit

class Plot: SKNode {
    var currentFunction: (() -> ())!
    
    var plotInfo: Info!
    
    var crop: Crop?
    
    var myGameViewController: GameViewController!
    
    var gameDelegate: GameDelegate!
    
    var selected = false
    var selecting = false
    
    var validTouch = false
    
    var ableToBeDeselected = false
    var lastSelectedPlot: Plot!
    
    var confirmButton: SKSpriteNode!
    var cancelButton: SKSpriteNode!
    
    let selectionButtons = ConfirmOrCancel()
    
    var grassTexture: SKTexture!
    
    let purchaseablePlot = SKTexture(imageNamed: "purchaseablePlot")
    let grassSelected = SKTexture(imageNamed: "grassSelected")
    
    var plotFunction: String = "purchaseablePlot"
    
    var plotSpriteNode: SKSpriteNode!
    
    var cropData: [String: Any]?
    
    var positionInArray: CGPoint!
    
    var currentTexture: SKTexture! {
        didSet {
            plotSpriteNode.texture = currentTexture
        }
    }
    
    init(newGameDelegate: GameDelegate, plotData: NSDictionary?, position: CGPoint? = nil) {
        
        gameDelegate = newGameDelegate
        super.init()

        
        positionInArray = position
        
        plotInfo = Info(newPlot: self)
        plotInfo.isHidden = true
        plotInfo.position = CGPoint(x: 0, y: 150)
        plotInfo.zPosition = 1
        addChild(plotInfo)
        
        plotSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        plotSpriteNode.name = "plot"
        addChild(plotSpriteNode)
        
        if let existingData = plotData {
            if let newCropData = existingData["cropData"] {
                cropData = newCropData as? [String: Any]
            }
            
            let coordinates = existingData["positionInArray"] as! [CGFloat]
            positionInArray = CGPoint(x: coordinates[0], y: coordinates[1])
            plotFunction = existingData["plotFunction"] as! String
        }
        
        grassTexture = SKTexture(imageNamed: "grass\(gameDelegate.getGrassNum(positionInArray: positionInArray))")
        
        changePlotFunctionTo(plotFunction)
        
        selectionButtons.position = CGPoint(x: 0, y: 100)
        selectionButtons.zPosition = 1
        selectionButtons.isHidden = true
        selectionButtons.delegate = self
        addChild(selectionButtons)
        
        lastSelectedPlot = self
        
        isUserInteractionEnabled = true
    }
    
    func update() {
        crop?.update()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if plotSpriteNode.contains(touch.location(in: self)) {
                validTouch = true
                
                if selected {
                    selecting = true
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        validTouch = false
        if selecting {
            for touch in touches {
                for node in self.scene!.nodes(at: touch.location(in: self.scene!)) {
                    if let possiblePlotSpriteNode = node as? SKSpriteNode {
                        if possiblePlotSpriteNode.name == "plot" {
                            let allPlots = gameDelegate.getPlots()
                            for plotArray in allPlots {
                                for plot in plotArray {
                                    plot?.deselect()
                                }
                            }
                            
                            let parentPlotNode = possiblePlotSpriteNode.parent as! Plot
                            if parentPlotNode.plotFunction != "plot" || gameDelegate.money < 10{
                                parentPlotNode.selectionButtons.disableConfirmButton()
                            }
                            else {
                                parentPlotNode.selectionButtons.enableConfirmButton()
                            }
                            
                            parentPlotNode.select()
                        }
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if plotInfo.isHidden == true {
            gameDelegate.closeInfo()
        }
        gameDelegate.changeCropPickerState(isHidden: true, nil)
        
        if validTouch && !selected && plotSpriteNode.calculateAccumulatedFrame().contains(touches.first!.location(in: self)) {
            if gameDelegate.validTouch() {
                currentFunction()
            }
        }
        
        if selecting && !selected {
            deselect()
            selecting = false
        }
        else if selecting && selected {
            selecting = false
        }
    }
    
    func changePlotFunctionTo(_ newPurpose: String) {
        plotFunction = newPurpose
        
        gameDelegate.closeInfo()
        crop?.removeFromParent()
        crop = nil
        
        switch plotFunction {
        case "savedCrop":
            crop = Crop(data: cropData, newGameDelegate: gameDelegate, newCropInfo: plotInfo)
            addChild(crop!)
            currentTexture = crop!.currentTexture
            
        case "newCrop":
            plotFunction = "savedCrop"
            crop = Crop(data: nil, newGameDelegate: gameDelegate, newCropInfo: plotInfo)
            addChild(crop!)
            currentTexture = crop!.currentTexture
            
        case "plot":
            currentTexture = grassTexture
            currentFunction = {
                self.presentShopScene()
            }
            
        case "purchaseablePlot":
            currentTexture = purchaseablePlot
            currentFunction = {
                if self.plotInfo.isHidden == false {
                    self.gameDelegate.closeInfo()
                }
                else {
                    self.plotInfo.activate()
                }
            }
            
        default:
            print("Function does not exist.")
            break
        }
    }
    
    func presentShopScene() {
        let shopScene = gameDelegate.getShopScene()
        self.scene?.view?.presentScene(shopScene)
        shopScene.activatedWithPlot = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func select() {
        crop?.isUserInteractionEnabled = false
        if plotFunction == "plot" {
            plotSpriteNode.texture = grassSelected
        }
        else {
            plotSpriteNode.colorBlendFactor = 1
            selectionButtons.disableConfirmButton()
        }
        
        if gameDelegate.money < 10 {
            selectionButtons.disableConfirmButton()
        }
        
        selectionButtons.isHidden = false
        selected = true
    }
    
    func deselect() {
        crop?.isUserInteractionEnabled = true
        if plotFunction == "plot" {
            plotSpriteNode.texture = grassTexture
        }
        else {
            plotSpriteNode.colorBlendFactor = 0
        }
        
        selectionButtons.isHidden = true
        selectionButtons.enableConfirmButton()
        selected = false
    }
    
    func getPositionInArray() -> [CGFloat] {
        let coordinates = [positionInArray.x, positionInArray.y]
        return coordinates
    }
    
    func getPlotData() -> NSMutableDictionary {
        let plotData = NSMutableDictionary()
        plotData["plotFunction"] = plotFunction
        plotData["positionInArray"] = getPositionInArray()
        plotData["cropData"] = crop?.getCropData()
        
        return plotData
    }
}

extension Plot: ConfirmOrCancelDelegate {
    func confirm() {
        if (gameDelegate.updateMoney(changeInMoney: -10)) {
            changePlotFunctionTo("newCrop")
            deselect()
        }
        
    }
    
    func cancel() {
        deselect()
    }
}
