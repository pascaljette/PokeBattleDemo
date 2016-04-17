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

protocol RandomPokemonFetcherDelegate: class {
    
    func didGetPokemon(success: Bool, result: Pokemon?, error: NSError?)
}

class RandomPokemonFetcher {
    
    typealias GetPokemonConnection = PokeApiConnection<GetPokemonRequest, GetPokemonResponse>
    
    weak var delegate: RandomPokemonFetcherDelegate?
    
    // TODO: AllPokemonList stays immutable for the whole lifecycle of the application.
    // Consider making it a singleton to avoid passing it all the time.
    private var allPokemonList: AllPokemonList
    
    init(allPokemonList: AllPokemonList) {
        
        self.allPokemonList = allPokemonList
    }
}

extension RandomPokemonFetcher {
    
    func fetch() {
        
        let pokemonUrl = allPokemonList.pokemonUrlStrings[Int(arc4random_uniform(UInt32(allPokemonList.pokemonUrlStrings.count)))]
        
        let call: GetPokemonConnection = GetPokemonConnection()
        let getPokemonRequest = GetPokemonRequest(fullUrl: pokemonUrl)
        
        call.onCompletion = { [weak self] (status, error, response) in
            
            guard let strongSelf = self else {
                
                return
            }
            
            switch status {
                
            case .Success:
                strongSelf.delegate?.didGetPokemon(true, result: response!.model, error: nil)
                
                // Cache the types right now.
                PokemonTypeCache.sharedInstance.downloadAndCacheMultiple(response!.model.types)
                
            case .ConnectionError:
                strongSelf.delegate?.didGetPokemon(false, result: nil, error: error)
                
            case .UrlError:
                strongSelf.delegate?.didGetPokemon(false, result: nil, error: error)
            }
        }
        
        call.execute(getPokemonRequest)
    }
}
