//
//  GameDelegate.swift
//  Game Test 4
//
//  Created by Cat Blue on 9/30/17.
//

import Foundation
import UIKit

protocol GameDelegate {
    
    var money: Double {get}
    
    func updateMoney(changeInMoney: Double) -> Bool
    
    func updateSeeds(changeInSeeds: [Int]) -> Bool
    
    func getSeeds() -> [Int]
    
    func getPlots() -> [[Plot?]]
    
    func getCropProperties() -> [NSMutableDictionary]
    
    func getGrassNum(positionInArray: CGPoint) -> Int
    
    func getGameScene() -> GameScene
    func getShopScene() -> ShopScene
    
    func changeCropPickerState(isHidden: Bool, _ optionalCrop: Crop?)
    func getCropPickerHiddenState() -> Bool
    
    func validTouch() -> Bool
    
    func closeInfo()
    
    func updatePurchaseablePlots()
    
    func getPriceOfNextPlot() -> Double
}
