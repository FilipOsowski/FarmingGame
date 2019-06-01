//
//  CropPicker.swift
//  Game Test 4
//
//  Created by Cat Blue on 10/5/17.
//

import UIKit
import SpriteKit

class CropPicker: UIScrollView, UIScrollViewDelegate {
    
    var cropProperties: [NSMutableDictionary]!
    
    var seedLabels: [UILabel] = []
    
    var seedButtons: [UIButton] = []
    
    let gameDelegate: GameDelegate
    
    var seeds: [Int] = []
    
    var currentCrop: Crop!
    
    init(frame: CGRect, newGameDelegate: GameDelegate, cropProperties: [NSMutableDictionary]) {
        
        self.cropProperties = cropProperties
        
        gameDelegate = newGameDelegate
        
        super.init(frame: frame)
        
        seeds = gameDelegate.getSeeds()
        
        self.frame = frame
        backgroundColor = UIColor.white
        isPagingEnabled = false
        delegate = self
        backgroundColor = .red
        
        for x in 0..<seeds.count {
            let seedButton = UIButton()
            let seedLabelArray = [UILabel(), UILabel(), UILabel()]
            
            seedButton.setImage(UIImage(named: "seed\(x+1)") , for: .normal)

            seedButton.addTarget(self, action: #selector(useSeeds(button:)), for: .touchUpInside)
            
            for seedLabel in seedLabelArray {
                seedLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 20)
                addSubview(seedLabel)
            }
            
            seedLabels+=seedLabelArray
            seedButtons.insert(seedButton, at: x)
            addSubview(seedButton)
        }
    }
    
    func activate(withCrop: Crop) {
        currentCrop = withCrop
        contentOffset = CGPoint(x: 0, y: 0)
        updateSeeds()
        self.isHidden = false
    }
    
    func deactivate() {
        self.isHidden = true
        for seed in seedButtons {
            seed.isHidden = true
        }
    }
    
    @objc func useSeeds(button: UIButton) {
        var seedUsed: Int!
        var newSeeds = seeds
        if (button == seedButtons[0]) {
            newSeeds[0]-=1
            seedUsed = 0
        }
        if (button == seedButtons[1]) {
            newSeeds[1]-=1
            seedUsed = 1
        }
        if (button == seedButtons[2]) {
            newSeeds[2]-=1
            seedUsed = 2
        }
        if (gameDelegate.updateSeeds(changeInSeeds: newSeeds)) {
            deactivate()
            currentCrop.setCrop(newCropType: seedUsed)
            currentCrop.currentStage = 1
            currentCrop.newStage()
            
            updateSeeds()
        }
    }
    
    public func updateSeeds() {
        seeds = gameDelegate.getSeeds()

        var count = 0
        var labelCount = 0
        var multiplier: CGFloat = 0
        for seed in seeds {
            if seed <= 0 {
                seedButtons[count].isHidden = true
                
                for _ in 0..<3 {
                    seedLabels[labelCount].isHidden = true
                    
                    labelCount+=1
                }
            }
            else {
                seedButtons[count].frame = CGRect(x: 400 * multiplier + 50, y: self.frame.height/2 - 50, width: 100, height: 100)
                seedButtons[count].isHidden = false
                let frame = seedButtons[count].frame
                
                for x in 0..<3 {
                    seedLabels[labelCount].frame = CGRect(x: frame.origin.x + (frame.width * 1.1), y: frame.origin.y + (CGFloat(x) * frame.height/3), width: 1, height: 1)
                    seedLabels[labelCount].sizeToFit()
                    
                    if(labelCount % 3 == 0) {
                        seedLabels[labelCount].text = "\(seeds[count]) seed(s) left."

                    }
                    else if (labelCount % 3 == 1) {
                        seedLabels[labelCount].text = "\(cropProperties[count]["timeToGrow"]!) seconds to grow."
                    }
                    else {
                        seedLabels[labelCount].text = "\(cropProperties[count]["cropReward"]!)$ reward for harvesting."
                    }
                    
                    seedLabels[labelCount].sizeToFit()
                    seedLabels[labelCount].isHidden = false
                    
                    labelCount+=1
                }
                multiplier+=1
            }
            count+=1
        }
        
        self.contentSize = CGSize(width: CGFloat(400 * multiplier
            + 100), height: (self.frame.height - self.frame.height/4))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

