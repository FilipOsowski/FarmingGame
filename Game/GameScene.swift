//
//  GameScene.swift
//  Game Test 2
//
//  Created by Cat Blue on 9/21/17.
//
//

import SpriteKit
import GameplayKit
import UserNotifications
import UIKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y - right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func / (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x/right, y: left.y/right)
}

class GameScene: SKScene, UIGestureRecognizerDelegate {
    var upperPinchLimit: CGFloat = 2
    var aspectRatio: CGFloat!
    
    var cropPicker: CropPicker!
    
    var myShopScene: ShopScene!
    
    var cropProperties: [NSMutableDictionary]!
    
    var money: Double = 1000

    var allPlots: [[Plot?]]!
    var allPlotsNode = SKNode()
    var numOfPlots = 0
    
    var seeds: [Int] = [3, 2, 1]
    
    var moneyLabel: UILabel!
    
    var lastPoint = CGPoint(x: 0, y: 0)

    var lastPinchScale: CGFloat = 1
    
    let plotBounds = SKSpriteNode(color: SKColor.white, size: CGSize(width: 0, height: 0))
    var nodeForBorderEffect1 = SKSpriteNode(color: SKColor.gray, size: CGSize(width: 0, height: 0))
    var nodeForBorderEffect2 = SKSpriteNode(color: SKColor.white, size: CGSize(width: 0, height: 0))
    
    init(size: CGSize, view: SKView) {
        super.init(size: size)

        NotificationCenter.default.addObserver(self, selector: #selector(saveGameData), name: NSNotification.Name(rawValue: "saveGameData"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(scheduleNotifications), name: NSNotification.Name(rawValue: "scheduleNotifications"), object: nil)

        aspectRatio = size.height/size.width
        
        cropProperties = [NSMutableDictionary(), NSMutableDictionary(),NSMutableDictionary()]
        cropProperties[0]["growingImage"] = "Growing"
        cropProperties[1]["growingImage"] = "Growing1"
        cropProperties[2]["growingImage"] = "Growing2"
        cropProperties[0]["readyToHarvestImage"] = "ReadyToHarvest"
        cropProperties[1]["readyToHarvestImage"] = "ReadyToHarvest1"
        cropProperties[2]["readyToHarvestImage"] = "ReadyToHarvest2"
        cropProperties[0]["cropReward"] = 20
        cropProperties[1]["cropReward"] = 40
        cropProperties[2]["cropReward"] = 80
        cropProperties[0]["timeToGrow"] = 5
        cropProperties[1]["timeToGrow"] = 10
        cropProperties[2]["timeToGrow"] = 20
        
        seeds = [1, 2, 3]
        
        cropPicker = CropPicker(frame: CGRect(x: 0, y: (self.frame.height - self.frame.height/4), width: self.frame.width, height: self.frame.height/4), newGameDelegate: self, cropProperties: cropProperties)
        cropPicker.isHidden = true
        view.addSubview(cropPicker)
            
        var plotData: [String: NSDictionary]?
        
        var allPlotsWidth: Int! = nil
        var allPlotsHeight: Int! = nil


        if let allData = loadGameData() {
            plotData = allData["plotData"] as? [String: NSDictionary]
            let gameData = allData["gameData"] as! [String: AnyObject]
            seeds = gameData["seeds"] as! [Int]
            money = gameData["money"]! as! Double
            allPlotsWidth = gameData["allPlotsWidth"] as! Int
            allPlotsHeight = gameData["allPlotsHeight"] as! Int
        }

        var toBeInitialized = false
        
        if allPlotsWidth == nil {
            allPlotsWidth = 5
            allPlotsHeight = 5
            toBeInitialized = true
        }
        
        allPlots = Array(repeating: Array(repeating: nil, count: allPlotsHeight), count: allPlotsWidth)
        var counter = 0
        
        for x in 0..<allPlotsWidth {
            for y in 0..<allPlotsHeight {
                if let existingPlotData = plotData?["\(x)\(y)"] {
                    allPlots[x][y] = Plot(newGameDelegate: self, plotData: existingPlotData, position: CGPoint(x: x, y: y))
                    print("Just made a plot.")
                    counter+=1
                }
                else if (x > 0 && x < 4 && y > 0 && y < 4 ) && toBeInitialized == true {
                    allPlots[x][y] = Plot(newGameDelegate: self, plotData: plotData?["\(x)\(y)"], position: CGPoint(x: x, y: y))
                    allPlots[x][y]?.changePlotFunctionTo("plot")
                }
            }
        }

        moneyLabel = UILabel()
        moneyLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 30)
        moneyLabel.text = "\(money)$"
        moneyLabel.frame = CGRect(x: frame.width - 200, y: 50, width: 1, height: 1)
        moneyLabel.textAlignment = .center
        moneyLabel.sizeToFit()
        view.addSubview(moneyLabel)

        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: 200, y: 200)
        addChild(cameraNode)
        camera = cameraNode

        addChild(allPlotsNode)
        
        updatePurchaseablePlots()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        cropPicker.deactivate()
        closeInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .white //Scene does not present w/o change?
        
        for plotArray in allPlots {
            for plot in plotArray {
                if plot?.selected == true {
                    plot!.select()
                }
            }
        }
    }
    
    func setUpPlots() {
        for child in allPlotsNode.children {
            if let _ = child as? Plot {
                child.removeFromParent()
            }
        }
        
        for x in 0..<allPlots.count {
            for y in 0..<allPlots[0].count {
                if let existingPlot = allPlots[x][y] {
                    allPlotsNode.addChild(existingPlot)
                    existingPlot.zPosition = 1

                    let plotPosition = allPlots[x][y]!.positionInArray!
                    allPlots[x][y]!.position = CGPoint(x: plotPosition.x * 100, y: plotPosition.y * 100)
                }
            }
        }
        updatePlotBounds()
    }

    func updatePlotBounds() {
        if plotBounds.parent == nil {
            allPlotsNode.addChild(plotBounds)
            plotBounds.position = CGPoint(x: 200, y: 200)
            plotBounds.size.height = CGFloat(allPlots[0].count) + 200 * aspectRatio
            plotBounds.size.width = CGFloat(allPlots.count) + 200

            allPlotsNode.addChild(nodeForBorderEffect1)
            nodeForBorderEffect1.zPosition = 0.5
            nodeForBorderEffect1.position = plotBounds.position
            
            allPlotsNode.addChild(nodeForBorderEffect2)
            nodeForBorderEffect2.zPosition = 0.75
            nodeForBorderEffect2.position = plotBounds.position
        }

        var height = 100 * CGFloat(allPlots[0].count) * 2
        var width = 100 * CGFloat(allPlots.count) * 2


        if (width * aspectRatio > height) {
            height = width * aspectRatio
        }
        else {
            width = height * (1/aspectRatio)
        }
        
        nodeForBorderEffect2.size.height = height - 100 * aspectRatio
        nodeForBorderEffect2.size.width = width - 100
        
        nodeForBorderEffect1.size.height = height
        nodeForBorderEffect1.size.width = width
        
        plotBounds.size.height = height + 200 * aspectRatio
        plotBounds.size.width = width + 200
    }
    
    func updatePurchaseablePlots() { //Original coordinate is (x, y) and adjacent coordinate is (coordinate.0, coordinate.1)
        let xLength = allPlots.count - 1
        let yLength = allPlots[0].count - 1

        var arrayShiftedBy: (Int, Int) = (0, 0) //If the array is extended, all coordinates change.

        for x in 0...xLength {
            for y in 0...yLength {
                if allPlots[x + arrayShiftedBy.0][y + arrayShiftedBy.1] != nil && allPlots[x + arrayShiftedBy.0][y + arrayShiftedBy.1]?.plotFunction != "purchaseablePlot" { //This is a crop who's adjacent plots should be checked.
                    
                    let adjacentPlots = [(x + 1, y), (x - 1, y), (x , y + 1), (x, y - 1)] //These are the coordinated of adjacent plots.
                    
                    for coordinate in adjacentPlots { //This checks all adjacent plots.
                        
                        if coordinate.0 == -1 || coordinate.0 == xLength + 1 || coordinate.1 == -1 || coordinate.1 == yLength + 1 { //This checks if the coordinate is out of bounds, confirming that a purchaseable plot should go there.
                            
                            if coordinate.0 == -1 { //If the array is shifted from zero, all future coordinates must be altered.

                                arrayShiftedBy.0 = 1

                                extendPlotArray(direction: "left")

                            }
                            else if coordinate.1 == -1 {

                                arrayShiftedBy.1 = 1
                                
                                extendPlotArray(direction: "down")

                            }
                            else if coordinate.0 == allPlots.count {

                                extendPlotArray(direction: "right")

                            }
                            else {
    
                                extendPlotArray(direction: "up")

                            }
                        }

                        if allPlots[coordinate.0 + arrayShiftedBy.0][coordinate.1 + arrayShiftedBy.1] == nil { //If one of the adjacent plots does not exist, it must become a purchaseable Plot.

                            let positionOfOriginalPlot = allPlots[x + arrayShiftedBy.0][y + arrayShiftedBy.1]!.positionInArray! //Position of the original plot that is being checked around.

                            let positionOfNewPlot =  CGPoint(x: Int(positionOfOriginalPlot.x) + coordinate.0 - x, y: Int(positionOfOriginalPlot.y) + coordinate.1 - y) //The position of the new plot depends on the plot it is adjacent to and its coordinate.

                            allPlots[coordinate.0 + arrayShiftedBy.0][coordinate.1 + arrayShiftedBy.1] = Plot(newGameDelegate: self, plotData: nil, position: positionOfNewPlot)

                        }
                    }
                }
            }
        }
        
        setUpPlots()
    }

    func extendPlotArray(direction: String) {

        var insertAt: Int!
        var verticalExtension: Bool!
        
        switch direction {
        case "up":
            insertAt = allPlots[0].count
            verticalExtension = true
        case "down":
            insertAt = 0
            verticalExtension = true
        case "left":
            insertAt = 0
            verticalExtension = false
        case "right":
            insertAt = allPlots.count
            verticalExtension = false
        default:
            print("Invalid direction")
            break
        }

        if verticalExtension {
            for count in 0..<allPlots.count {
                allPlots[count].insert(nil, at: insertAt)
            }
        }
        else {
            allPlots.insert(Array(repeating: nil, count: allPlots[0].count), at: insertAt)
        }
    }
    
    @objc func scheduleNotifications() {
        var nextBadgeNum: Int = 1
        
        var allCrops: [Crop] = []
        
        for plotArray in allPlots {
            for plot in plotArray {
                if let existingCrop = plot?.crop {
                    allCrops.append(existingCrop)
                }
            }
        }
        
        allCrops.sort(by: {$0.getNotificationTime() < $1.getNotificationTime()})

        for crop in allCrops {
            let message = crop.getNotificationMessage()
            let time = crop.getNotificationTime()

            if message != nil {
                scheduleNotificationWith(body: message!, intervalInSeconds: time, badgeNumber: nextBadgeNum)
                nextBadgeNum+=1
            }
        }
    }
    
    func scheduleNotificationWith(body: String, intervalInSeconds: TimeInterval, badgeNumber: Int) {
        let localNotification = UNMutableNotificationContent()

        localNotification.body = body
        localNotification.sound = UNNotificationSound.default()
        localNotification.badge = badgeNumber as NSNumber?

        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: intervalInSeconds, repeats: false)
        let request = UNNotificationRequest.init(identifier: body, content: localNotification, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    
    override func update(_ currentTime: TimeInterval) {
        for plotArray in allPlots {
            for plot in plotArray {
                plot?.update()
            }
        }
    }
    
    @objc func saveGameData() {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = documentDirectory.appending("/allData.plist")
        
        print(path)
        
        let plotData = NSMutableDictionary()
        
        for x in 0..<allPlots.count {
            for y in 0..<allPlots[0].count {
                if let existingPlot = allPlots[x][y] {
                    plotData["\(x)\(y)"] = existingPlot.getPlotData()
                }
            }
        }
        
        let gameData = NSMutableDictionary()
        
        gameData["money"] = money
        gameData["seeds"] = seeds
        gameData["allPlotsHeight"] = allPlots[0].count
        gameData["allPlotsWidth"] = allPlots.count

        let allData = NSMutableDictionary()
        
        allData["plotData"] = plotData
        allData["gameData"] = gameData
        
        allData.write(toFile: path, atomically: true)
    }
    
    func loadGameData() -> [String: AnyObject]? {
        let fileManager = FileManager.default
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = documentDirectory.appending("/allData.plist")
        print(path)
        
        if(fileManager.fileExists(atPath: path)) {
            let allData = NSDictionary(contentsOfFile: path)
            return allData as? [String : AnyObject]
        }
        else {
            return nil
        }
    }
}

extension GameScene: GameDelegate {
    
    func getGameScene() -> GameScene {
        return self
    }

    func getShopScene() -> ShopScene {
        return myShopScene
    }
    
    func getPriceOfNextPlot() -> Double {
        var count: Double = -8
        for plotArray in allPlots {
            for plot in plotArray {
                if plot?.plotFunction != nil && plot?.plotFunction != "purchaseablePlot" {
                    count+=1
                }
            }
        }
        return count * 5
    }

    func closeInfo() {
        for plotArray in allPlots {
            for plot in plotArray {
                plot?.plotInfo.isHidden = true
            }
        }
    }

    func validTouch() -> Bool {
        for plotArray in allPlots {
            for plot in plotArray {
                if plot?.selected == true {
                    return false
                }
            }
        }
        
        return true
    }

    func changeCropPickerState(isHidden: Bool, _ optionalCrop: Crop? = nil) {
        if isHidden == true {
            cropPicker.deactivate()
        }
        else {
            cropPicker.activate(withCrop: optionalCrop!)
            closeInfo()
        }
    }
    
    func getCropPickerHiddenState() -> Bool {
        return cropPicker.isHidden
    }

    func getGrassNum(positionInArray: CGPoint) -> Int {
        return ((Int(positionInArray.x)&1)^(Int(positionInArray.y)&1))
    }
    
    func getPlots() -> [[Plot?]] {
        return allPlots
    }
    
    func updateMoney(changeInMoney: Double) -> Bool {
        if (money + changeInMoney >= 0) {
            money = money + changeInMoney
            moneyLabel.text = "\(money)$"
            moneyLabel.sizeToFit()
            
            return true
        }
        return false
    }
    
    func updateSeeds(changeInSeeds: [Int]) -> Bool {
        for seed in changeInSeeds {
            if seed < 0 {
                return false
            }
        }
        
        seeds = changeInSeeds
        return true
    }

    func getCropProperties() -> [NSMutableDictionary] {
        return cropProperties
    }

    func getSeeds() -> [Int] {
        return seeds
    }
}

extension GameScene {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let _ = self.view {
            return true
        }
        return false
    }
    
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (cropPicker.isHidden == false && cropPicker.frame.contains(touch.location(in: self.view))) {
            return false
        }
        
        if let _ = gestureRecognizer as? UIPanGestureRecognizer {
            for node in nodes(at: touch.location(in: self)) {
                if let plot = node as? Plot {
                    if plot.selected == true {
                        return false
                    }
                }
            }
        }
        
        return true
    }

    func calculatePlotBoundsFrame() -> CGRect {
        let plotBoundsFrameInAllPlotsNode = plotBounds.calculateAccumulatedFrame()

        let maxCoordinatesInScene = allPlotsNode.convert(CGPoint(x: plotBoundsFrameInAllPlotsNode.maxX, y: plotBoundsFrameInAllPlotsNode.maxY), to: self)
        let minCoordinatesInScene = allPlotsNode.convert(CGPoint(x: plotBoundsFrameInAllPlotsNode.minX, y: plotBoundsFrameInAllPlotsNode.minY), to: self)


        return CGRect(origin: convert(plotBoundsFrameInAllPlotsNode.origin, from: allPlotsNode), size: CGSize(width: maxCoordinatesInScene.x - minCoordinatesInScene.x, height: maxCoordinatesInScene.y - minCoordinatesInScene.y))
    }
    
    @objc func pinched(pinch: UIPinchGestureRecognizer) {
        var scale = pinch.scale * lastPinchScale
        switch pinch.state {
        case .changed, .began:

            var anchorPoint = pinch.location(in: view) //Gets anchor point in UIView from pinch.

            anchorPoint = convertPoint(fromView: anchorPoint) //Converts point from UIView to the original anchor point in SKScene.
            
            if (plotBounds.size.width * scale < size.width) {
                scale = size.width/(plotBounds.size.width)
            }
            else if scale >= upperPinchLimit {
                scale = upperPinchLimit
            }

            if (plotBounds.size.width * scale - 0.0001 <= size.width || scale >= upperPinchLimit) {
                lastPinchScale = scale/pinch.scale
            }


            let anchorPointInMySKNode = allPlotsNode.convert(anchorPoint, from: self)

            allPlotsNode.setScale(scale)

            let mySKNodeAnchorPointInScene = convert(anchorPointInMySKNode, from: allPlotsNode)

            let translationOfAnchorInScene = (x: anchorPoint.x - mySKNodeAnchorPointInScene.x, y: anchorPoint.y - mySKNodeAnchorPointInScene.y)

            allPlotsNode.position = CGPoint(x: allPlotsNode.position.x + translationOfAnchorInScene.x, y: allPlotsNode.position.y + translationOfAnchorInScene.y)
            
            if let outOfBoundsBy = isOutOfBounds() {
                let alteredPosition = camera!.position - outOfBoundsBy
                camera!.position = alteredPosition
            }
            
        case .ended:
            lastPinchScale = scale
        default:
            break
        }
    }
    
    @objc func panned(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: view)
        let scaledTranslation = CGPoint(x: translation.x * camera!.xScale, y: translation.y * camera!.yScale)
        let cameraPos = camera!.position

        switch pan.state {
            case .changed:
                camera!.position = CGPoint(x: cameraPos.x - (scaledTranslation.x - lastPoint.x), y: cameraPos.y + (scaledTranslation.y - lastPoint.y))
                lastPoint = scaledTranslation
                
                if let outOfBoundsBy = isOutOfBounds() {
                    let alteredPosition = camera!.position - outOfBoundsBy
                    camera!.position = alteredPosition
                }
            case .ended:
                lastPoint = CGPoint(x: 0, y: 0)
            default:
                break
        }
    }
    
    func isOutOfBounds() -> CGPoint? {
        let pos = camera!.position
        let cameraBounds = CGRect(x: pos.x - size.width/2, y: pos.y - size.height/2, width: size.width, height: size.height)
        let plotBoundsRect = calculatePlotBoundsFrame()
        
        let origin = cameraBounds.origin
        let corners = [CGPoint(x: origin.x, y: origin.y),
                      CGPoint(x: origin.x + cameraBounds.width, y: origin.y),
                      CGPoint(x: origin.x, y: origin.y + cameraBounds.height),
                      CGPoint(x: origin.x + cameraBounds.width, y: origin.y + cameraBounds.height)]

        var moveBy = CGPoint(x: 0, y: 0)

        for point in corners {
            if !plotBoundsRect.contains(point) {
                var x: CGFloat = 0
                var y: CGFloat = 0
                if (point.x < plotBoundsRect.origin.x || point.x > plotBoundsRect.origin.x + plotBoundsRect.width) {
                    let distanceFromCamera = point.x - (plotBoundsRect.width/2 + plotBoundsRect.origin.x)
                    x = distanceFromCamera + (distanceFromCamera > 0 ? -plotBoundsRect.width/2 : plotBoundsRect.width/2)
                }

                if (point.y < plotBoundsRect.origin.y || point.y > plotBoundsRect.origin.y + plotBoundsRect.height) {
                    let distanceFromCamera = point.y - (plotBoundsRect.height/2 + plotBoundsRect.origin.y)
                    y = distanceFromCamera + (distanceFromCamera > 0 ? -plotBoundsRect.height/2 : plotBoundsRect.height/2)
                }

                moveBy = moveBy + CGPoint(x: x/2, y: -y/2)
            }
        }

        if moveBy != CGPoint(x: 0, y: 0) {
            return moveBy
        }

        return nil
    }
}
