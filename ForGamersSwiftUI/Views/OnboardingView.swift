//
//  OnboardingView.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/6/21.
//

import SwiftUI

struct OnboardingView: View {
    @State var communities: [Community] = []
    @State var selectedCommunities: [Community] = []
    @State private var isPresented = false
    
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns) {
                ForEach(communities, id: \.self) { item in
                    Text(item.communityName)
                        .background(selectedCommunities.contains(item) ? Color.blue : Color.yellow)
                        .onTapGesture {
                            print(item)
                            if !selectedCommunities.contains(item) {
                                selectedCommunities.append(item)
                            } else {
                                selectedCommunities.removeAll(where: { $0 == item })
                            }
                        }
                        .cornerRadius(3.0)
                }
            }
            
            if !selectedCommunities.isEmpty {
                Button(action: {
                    joinCommunities { (didJoin) in
                        if didJoin == true {
                            self.isPresented.toggle()
                        }
                    }
                }, label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color(red: 255 / 255, green: 115 / 255, blue: 115 / 255)))
                })
                .fullScreenCover(isPresented: $isPresented, content: {
                    TabBarView()
                })
            }
        }
        .onAppear {
            FirestoreManager.shared.getCommunities { (allCommunities, error) in
                if let error = error {
                    print(error)
                }
                
                if let allCommunities = allCommunities {
                    self.communities = allCommunities
                }
            }
        }
    }
    
    func joinCommunities(completion: @escaping (Bool) -> Void) {
        let myGroup = DispatchGroup()
        
        for community in selectedCommunities {
            myGroup.enter()
            FirestoreManager.shared.joinCommunity(communityName: community.communityName) { (didJoin) in
                if didJoin == true {
                    DatabaseManager.shared.updateUserForJoining(communityName: community.communityName) { (didUpdate) in
                        print(didUpdate)
                        myGroup.leave()
                    }
                }
            }
        }
        
        myGroup.notify(queue: .main) {
            print("Finished all requests.")
            completion(true)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
