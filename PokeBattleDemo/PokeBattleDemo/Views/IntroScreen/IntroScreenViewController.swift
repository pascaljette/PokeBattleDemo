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
    
    /// Status of the fetching operations.
    enum Status {
        
        /// Initial state, fetching operations are not executing.
        case IDLE
        
        /// Fetching the list of all pokemons to retrieve info from their URLs.
        case FETCHING_POKEMON_LIST
        
        /// Fetching the initial draw for each player from the pokemon list.
        case FETCHING_INITIAL_DRAW
        
        /// Fetching operations completed, ready to proceed.
        case READY
    }
    
    //
    // MARK: IBOutlets
    //
    
    /// Start button.
    @IBOutlet weak var startButton: UIButton!
    
    /// Activity indicator.
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //
    // MARK: Stored properties
    //
    
    /// Reference on the fetcher that gets the full pokemon list.
    private let allPokemonFetcher: AllPokemonListFetcher
    
    /// Reference on the fetcher that gets detailed for each pokemon (chosen randomly).
    private let multiplePokemonFetcher: MultiplePokemonFetcher
    
    /// Reference on the pokemon list retrieved by the AllPokemonListFetcher.
    private var pokemonList: AllPokemonList = AllPokemonList()
    
    /// Initial draw containing all pokemon for all players..
    private var initialDraw: [Pokemon] = []
    
    /// Dispatch group for thread synchronization.
    private let dispatchGroup = dispatch_group_create();
    
    /// Current status of the view controller.
    private var status: Status = .IDLE
    
    /// Sets up elements with respect to the view controller's loading status.
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
    
    //
    // MARK: Initializers
    //

    /// Initialize with the proper injected properties.  Also sets the view controller's delegates.
    ///
    /// - parameter allPokemonListFetcher: Instance of the fetcher that gets the list of all pokemon.
    /// - parameter multiplePokemonFetcher: Instance of the fetcher that gets the initial draw for all players.
    init(allPokemonListFetcher: AllPokemonListFetcher, multiplePokemonFetcher: MultiplePokemonFetcher) {
        
        self.allPokemonFetcher = allPokemonListFetcher
        self.multiplePokemonFetcher = multiplePokemonFetcher
        
        super.init(nibName: "IntroScreenViewController", bundle: nil)
        
        allPokemonFetcher.delegate = self
    }
    
    /// Required initialiser.  Unsupported so make it crash as soon as possible.
    ///
    /// - parameter coder: Coder used to initialize the view controller (when instantiated from a storyboard).
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented (storyboard not supported)")
    }
}

extension IntroScreenViewController {
    
    //
    // MARK: UIViewController lifecycle
    //

    /// View did load.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO localize
        self.navigationItem.title = "Pokermon!"

        dispatch_group_enter(dispatchGroup)
        allPokemonFetcher.fetch()
        status = .FETCHING_POKEMON_LIST
    }
    
    /// View will appear.
    ///
    /// - parameter animated: Whether the view is animated when it appears.
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        loading = false
    }
}

extension IntroScreenViewController {
    
    //
    // MARK: Private utility methods
    //
    
    /// Check the current status of the viewcontroller and move to the next view controller if ready.
    /// Basically, there should be no way to get to this method without being in the ready state,
    /// but it is checked anyways as a sanity check.
    private func proceedToBattleViewController() {
        
        switch status {
            
        case .READY:
            // Might have to wait on the next UI cycle here, but it doesn't matter much because
            // this is not a performance bottleneck.
            GKThread.dispatchOnUiThread { [weak self] in
                
                guard let strongSelf = self else {
                    
                    return
                }
                                
                // Build player1 deck from the bottom half.
                let player1: Player = Player(id: .PLAYER_1, pokemonDraw: Array(strongSelf.initialDraw[0..<GlobalConstants.NUMBER_OF_POKEMON_PER_PLAYER]))

                // Build player2 deck from the upper half.
                let player2: Player = Player(id: .PLAYER_2, pokemonDraw: Array(strongSelf.initialDraw[GlobalConstants.NUMBER_OF_POKEMON_PER_PLAYER..<strongSelf.initialDraw.count]))

                // Build pokemon fetcher used in the battle screen.
                let pokemonFetcher = RandomPokemonFetcher(allPokemonList: strongSelf.pokemonList)
                
                strongSelf.navigationController?.pushViewController(
                    BattleScreenViewController(pokemonList: strongSelf.pokemonList
                        , player1: player1
                        , player2: player2
                        , pokemonFetcher: pokemonFetcher
                        , stateMachine: StateMachine()
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

    /// Did get the list of all possible pokemon.
    ///
    /// - parameter success: Whether the list retrieval succeeded.
    /// - parameter result: Retrieved list or nil on failure.
    /// - parameter error: Error object or nil on failure.
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
    
    /// Did get the pokemon array for the initial draw.
    ///
    /// - parameter success: Whether the list retrieval succeeded.
    /// - parameter result: Retrieved list or nil on failure.
    /// - parameter error: Error object or nil on failure.
    func didGetPokemonArray(success: Bool, result: [Pokemon]?, error: NSError?) {
        
        defer {
            
            dispatch_group_leave(dispatchGroup)
        }
        
        if success {
            
            self.initialDraw = result ?? []
            status = .READY
            
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

extension IntroScreenViewController {
    
    //
    // MARK: IBActions
    //
    
    /// Called when the start button (the big pokeball) is pressed..
    ///
    /// - parameter sender: Reference on the object sending the event.
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

