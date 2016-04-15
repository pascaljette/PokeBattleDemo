//
//  IntroScreen.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/15/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation
import UIKit
import GearKit

class IntroScreenViewController : GKViewControllerBase {
    
    typealias GetPokemonListConnection = PokeApiConnection<GetPokemonListRequest, GetPokemonListResponse>
    typealias GetPokemonConnection = PokeApiConnection<GetPokemonRequest, GetPokemonResponse>
    
    var pokemonList: PokemonList = PokemonList()
    var initialDraw: [Pokemon] = []
    
    var dispatchGroup = dispatch_group_create();

    
    // TODO this should be data-oriented (plist)
    class var pokemonCountPerPlayer: Int {
        return 3
    }
    
    @IBOutlet weak var startButton: UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    @IBAction func startButtonPressed(sender: AnyObject) {
        
        activityIndicator.startAnimating()
        
        startButton.hidden = true
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            dispatch_group_wait(strongSelf.dispatchGroup, DISPATCH_TIME_FOREVER)
            
            strongSelf.proceedToBattleViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.stopAnimating()
        
        // TODO localize
        self.navigationItem.title = "Pokermon!"
        
        fetchPokemonList()
    }
    
    private func fetchPokemonList() {
        
        dispatch_group_enter(dispatchGroup)
        
        let call: GetPokemonListConnection = GetPokemonListConnection()
        
        call.onCompletion = { [weak self] (status, error, response) in
            
            guard let strongSelf = self else {
                
                return
            }
            
            
            defer {
                
                dispatch_group_leave(strongSelf.dispatchGroup)
            }
            
            switch status {
                
            case .Success:
                
                strongSelf.pokemonList = response?.model ?? PokemonList()
                strongSelf.prefetchPokemon(IntroScreenViewController.pokemonCountPerPlayer * 2)

            // TODO display error dialog
            case .ConnectionError:
                break
                
            // TODO display error dialog
            case .UrlError:
                break
            }
        }
        
        call.execute()
    }
    
    func prefetchPokemon(count: Int) {
        
        for _ in 0..<count {
            
            dispatch_group_enter(dispatchGroup)
            
            // No guarantee that we don't have duplicates, but that's OK.
            let randomPokemonUrl = pokemonList.pokemonUrlStrings[Int(arc4random_uniform(UInt32(pokemonList.pokemonUrlStrings.count)))]
            
            let getPokemonRequest = GetPokemonRequest(fullUrl: randomPokemonUrl)
            
            let call: GetPokemonConnection = GetPokemonConnection()
            
            call.onCompletion = { [weak self] (status, error, response) in
                
                guard let strongSelf = self else {
                    
                    return
                }
                
                defer {
                    
                    dispatch_group_leave(strongSelf.dispatchGroup)
                }
                
                switch status {
                
                case .Success:
                    
                    guard let modelInstance = response?.model else {
                        
                        return
                    }
                    
                    strongSelf.initialDraw.append(modelInstance)
                    
                // TODO display error dialog
                case .ConnectionError:
                    GKThread.dispatchOnUiThread {
                    }
                    
                // TODO display error dialog
                case .UrlError:
                    GKThread.dispatchOnUiThread {
                    }
                }
                
            }
            
            call.execute(getPokemonRequest)
        }
    }
    
    func proceedToBattleViewController() {
        
        // Might have to wait on the next UI cycle here, but it doesn't matter much because
        // this is not a performance bottleneck.
        GKThread.dispatchOnUiThread { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            let initialDrawPlayer1 = Array(strongSelf.initialDraw[0..<IntroScreenViewController.pokemonCountPerPlayer])
            let initialDrawPlayer2 = Array(strongSelf.initialDraw[IntroScreenViewController.pokemonCountPerPlayer..<strongSelf.initialDraw.count])

            strongSelf.navigationController?.pushViewController(
                BattleScreenViewController(pokemonList: strongSelf.pokemonList
                    , initialDrawPlayer1: initialDrawPlayer1
                    , initialDrawPlayer2: initialDrawPlayer2)
                , animated: true)
        }
    }
}
