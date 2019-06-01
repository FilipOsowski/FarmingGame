//
//  ShopScene.swift
//  Game Test 7
//
//  Created by Conant High School on 11/7/17.
//

import UIKit
import SpriteKit

class ShopScene: SKScene, UIScrollViewDelegate {
    var cropProperties: [NSMutableDictionary]!
    
    var gameDelegate: GameDelegate!
    
    var seeds: [Int]! {
        didSet {
            updateLabels()
        }
    }
    
    var seedNodes: [SKSpriteNode] = []
    var seedLabels: [SKLabelNode] = []
    
    var buyPlot: SKSpriteNode!
    
    var activatedWithPlot: Plot?
    
    init(size: CGSize, cropProperties: [NSMutableDictionary], gameDelegate: GameDelegate) {
        super.init(size: size)
        
        self.gameDelegate = gameDelegate
        
        seeds = gameDelegate.getSeeds()
        
        var space: CGFloat = 100
        for x in 0..<seeds.count {
            seedNodes.insert(SKSpriteNode(imageNamed: "seed\(x + 1)"), at: (x))
            seedNodes[x].setScale(0.2)
            seedNodes[x].position = CGPoint(x: space, y: frame.height/3)
            
            let label = SKLabelNode(fontNamed: "Apple SD Gothic Neo")
            label.numberOfLines = 0
            label.text = "You have \(seeds[x]) \n Costs \((x + 1) * 10)$"
            label.fontSize = 30
            label.position = CGPoint(x: space, y: frame.height/3 - seedNodes[x].calculateAccumulatedFrame().height * 1.3)
            
            seedLabels.insert(label, at: x)
            addChild(seedLabels[x])
            addChild(seedNodes[x])
            space+=(frame.width - 200)/2
        }
        
        buyPlot = SKSpriteNode(imageNamed: "preparePlot")
        buyPlot.position = CGPoint(x: frame.width/2, y: frame.height/3 * 2)
        addChild(buyPlot)

        let label = SKLabelNode(fontNamed: "Apple SD Gothic Neo")
        label.text = "Prepare plot for planting for $10."
        label.position = CGPoint(x: frame.width/2, y: frame.height/3 * 2 - buyPlot.calculateAccumulatedFrame().height * 1.3)
        addChild(label)
    }
    
    func updateLabels() {
        for x in 0..<seedLabels.count {
            seedLabels[x].text = "You have \(seeds[x]) \n Costs \((x + 1) * 10)$"
        }
    }
    
    override func didMove(to view: SKView) {
        gameDelegate.closeInfo()
        gameDelegate.changeCropPickerState(isHidden: true, nil)
        activatedWithPlot = nil
        backgroundColor = .blue
        seeds = gameDelegate.getSeeds()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            for node in self.nodes(at: touch.location(in: self)) {
                for x in 0...2 {
                    if node == seedNodes[x] && gameDelegate.updateMoney(changeInMoney: Double(-((x + 1) * 10))) {
                        var newSeeds: [Int]! = seeds
                        newSeeds[x]+=1
                        let _ = gameDelegate.updateSeeds(changeInSeeds: newSeeds)
                        seeds = gameDelegate.getSeeds()
                        purchaseAnimation(pos: node.position)
                    }
                }
                if node == buyPlot {
                    let allPlots = gameDelegate.getPlots()
                    
                    if activatedWithPlot != nil {
                        activatedWithPlot!.select()
                    }
                    else {
                        var foundPlot = false
                        for plotArray in allPlots {
                            for plot in plotArray {
                                plot?.deselect()
                                if !foundPlot {
                                    if let existingPlot = plot {
                                        if existingPlot.plotFunction == "plot" {
                                            existingPlot.select()
                                            foundPlot = true
                                        }
                                    }
                                }
                            }
                        }
                    }

                    self.view!.presentScene(gameDelegate.getGameScene())
                }
            }
        }
    }
    
    func purchaseAnimation(pos: CGPoint) {
        let purchaseAnimation = SKLabelNode(fontNamed: "Apple SD Gothic Neo")
        let fadeAway = SKAction.sequence([SKAction.fadeOut(withDuration: 0.75), SKAction.removeFromParent()])
        let moveUp = SKAction.move(to: CGPoint(x: pos.x, y: pos.y + 100), duration: 0.75)
        
        let completeAnimation = SKAction.group([fadeAway, moveUp])
        
        purchaseAnimation.text = "+1"
        purchaseAnimation.fontSize = 100
        purchaseAnimation.position = CGPoint(x: pos.x, y: pos.y + 50)
        addChild(purchaseAnimation)
        purchaseAnimation.run(completeAnimation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
