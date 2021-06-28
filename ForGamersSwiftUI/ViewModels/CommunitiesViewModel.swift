//
//  CommunitiesViewModel.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import Foundation

class CommunitiesViewModel: ObservableObject {
    @Published var communities = [Community]()
    
    func getCommunities() {
        FirestoreManager.shared.getCommunities { (community, error) in
            if let community = community {
                self.communities = community
            }
            
            if let error = error {
                print(error)
            }
        }
    }
    
}
