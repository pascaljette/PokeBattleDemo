// The MIT License (MIT)
//
// Copyright (c) 2015 pascaljette
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import UIKit
import GearKit

class IntroScreenViewController : GKViewControllerBase {
    
    //
    // MARK: Nested types
    //
    enum Status {
        
        case IDLE
        case FETCHING_POKEMON_LIST
        case FETCHING_INITIAL_DRAW
        case READY
    }
    
    //
    // MARK: Stored properties
    //
    
    private let allPokemonFetcher: AllPokemonListFetcher
    
    private let multiplePokemonFetcher: MultiplePokemonFetcher
    
    private var pokemonList: AllPokemonList = AllPokemonList()
    
    private var initialDraw: [Pokemon] = []
    
    private let dispatchGroup = dispatch_group_create();
    
    private var loading: Bool = false {
        
        didSet {
            
            if loading {
                
                activityIndicator.startAnimating()
                startButton.hidden = true
            } else {
                
                activityIndicator.stopAnimating()
                startButton.hidden = false
            }
        }
    }
    
    private var status: Status = .IDLE
    
    //
    // MARK: IBOutlets
    //
    
    @IBOutlet weak var startButton: UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //
    // MARK: Initializers
    //

    init(allPokemonListFetcher: AllPokemonListFetcher, multiplePokemonFetcher: MultiplePokemonFetcher) {
        
        self.allPokemonFetcher = allPokemonListFetcher
        self.multiplePokemonFetcher = multiplePokemonFetcher
        
        super.init(nibName: "IntroScreenViewController", bundle: nil)
        
        allPokemonFetcher.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented (storyboard not supported)")
    }
}

extension IntroScreenViewController {
    
    //
    // MARK: UIViewController lifecycle
    //

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loading = false
        
        // TODO localize
        self.navigationItem.title = "Pokermon!"

        dispatch_group_enter(dispatchGroup)
        allPokemonFetcher.fetch()
        status = .FETCHING_POKEMON_LIST
    }
}

extension IntroScreenViewController {
    
    //
    // MARK: Computed properties
    //

    
}

extension IntroScreenViewController {
    
    private func proceedToBattleViewController() {
        
        switch status {
            
        case .READY:
            // Might have to wait on the next UI cycle here, but it doesn't matter much because
            // this is not a performance bottleneck.
            GKThread.dispatchOnUiThread { [weak self] in
                
                guard let strongSelf = self else {
                    
                    return
                }
                
                strongSelf.loading = false
                
                let player1: Player = Player(id: .PLAYER_1, pokemonDraw: Array(strongSelf.initialDraw[0..<GlobalConstants.NUMBER_OF_POKEMON_PER_PLAYER]))

                let player2: Player = Player(id: .PLAYER_2, pokemonDraw: Array(strongSelf.initialDraw[GlobalConstants.NUMBER_OF_POKEMON_PER_PLAYER..<strongSelf.initialDraw.count]))

                let pokemonFetcher = RandomPokemonFetcher(allPokemonList: strongSelf.pokemonList)
                
                strongSelf.navigationController?.pushViewController(
                    BattleScreenViewController(pokemonList: strongSelf.pokemonList
                        , player1: player1
                        , player2: player2
                        , pokemonFetcher: pokemonFetcher
                        , battleEngine: BattleEngine())
                    , animated: true)
            }

        case .IDLE:
            break
        
        case .FETCHING_POKEMON_LIST:
            break
        
        case .FETCHING_INITIAL_DRAW:
            break
        }
    }
}

extension IntroScreenViewController : AllPokemonListFetcherDelegate {
    
    //
    // MARK: AllPokemonListDelegate implementation
    //

    
    func didGetAllPokemonList(success: Bool, result: AllPokemonList?, error: NSError?) {
        
        if success {
            
            self.pokemonList = result ?? AllPokemonList()

            multiplePokemonFetcher.delegate = self
            
            multiplePokemonFetcher.fetch(self.pokemonList)
            
            status = .FETCHING_INITIAL_DRAW
        
        } else {
            
            status = .IDLE
            
            // TODO push this into GearKit
            let alertController = UIAlertController(title: "Error", message: "Could not retrieve list of all pokemon", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: { [weak self] in
                
                guard let strongSelf = self else {
                    
                    return
                }
                
                strongSelf.loading = false
            })
        }
    }
}

extension IntroScreenViewController : MultiplePokemonFetcherDelegate {
    
    //
    // MARK: MultiplePokemonFetcherDelegate implementation
    //
    
    func didGetPokemonArray(success: Bool, result: [Pokemon]?, error: NSError?) {
        
        defer {
            
            dispatch_group_leave(dispatchGroup)
        }
        
        if success {
            
            self.initialDraw = result ?? []
            status = .READY
            
        } else {
            
            status = .IDLE
            
            let alertController = UIAlertController(title: "Error", message: "Could not retrieve list of all pokemon", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: { [weak self] in
                
                guard let strongSelf = self else {
                    
                    return
                }
                
                strongSelf.loading = false
            })
        }
    }
}

extension IntroScreenViewController {
    
    //
    // MARK: IBActions
    //
    
    @IBAction func startButtonPressed(sender: AnyObject) {
        
        loading = true
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            dispatch_group_wait(strongSelf.dispatchGroup, DISPATCH_TIME_FOREVER)
            
            strongSelf.proceedToBattleViewController()
        }
    }
}

