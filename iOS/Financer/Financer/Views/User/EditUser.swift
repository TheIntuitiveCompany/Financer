//
//  EditUser.swift
//  Financer
//
//  Created by Julian Schumacher on 08.01.23.
//

import SwiftUI

/// The view to edit the user
internal struct EditUser: View {
    
    /// The User Wrapper in the Environment containing the current User
    @EnvironmentObject private var userWrapper : UserWrapper
    
    /// Whether ther Error when saving is displayed or not.
    @State private var errSavingPresented : Bool = false
    
    var body: some View {
        NavigationStack {
            UserEditor(action: editUser, user: userWrapper.user!)
                .environmentObject(userWrapper)
                .navigationTitle("Edit User")
                .alert(
                    "Error",
                    isPresented: $errSavingPresented
                ) {
                    
                } message: {
                    Text(
                        "Error saving Data.\nPlease try again\n\nIf this Error occurs again, please contact the support."
                    )
                }
        }
    }
    
    /// The Function to edit the User being passed to the User Editor
    private func editUser(user : User) -> Void {
        
    }
}

struct EditUser_Previews: PreviewProvider {
    static var previews: some View {
        EditUser()
    }
}
