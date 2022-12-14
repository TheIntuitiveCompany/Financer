//
//  UserEditor.swift
//  Financer
//
//  Created by Julian Schumacher on 07.01.23.
//

import SwiftUI

/// The View to edit a Users Data
internal struct UserEditor: View {
    
    /// The Action to dismiss this View
    @Environment(\.dismiss) private var dismiss : DismissAction
    
    /// The Context to interact with the
    /// Core Data Manager
    @Environment(\.managedObjectContext) private var viewContext
    
    /// The Firstname of the User
    @State private var firstname : String = ""
    
    /// The Lastname of the User
    @State private var lastname : String = ""
    
    /// The Date of Birth of this User
    @State private var dateOfBirth : Date = Date()
    
    /// Whether to use a date of birth or not
    @State private var useDateOfBirth : Bool = false
    
    /// Whether the Button is active (all Data are entered) or not.
    @State private var btnActive : Bool = false
    
    /// Whether ther Error for missing Arguments is displayed or not.
    @State private var errMissingArgumentsPresented : Bool = false
    
    /// The callback being executed when the Save or Done Button
    /// is tapped.
    private let callback : (User) -> Void
    
    /// The Initializer to add or edit
    /// a User.
    /// If you pass a User, it will be edited,
    /// otherwise a new User will be created
    internal init(
        action : @escaping (User) -> Void,
        user : User? = nil
    ) {
        self.callback = action
        if user != nil {
            _firstname = State(initialValue: user!.firstname!)
            _lastname = State(initialValue: user!.lastname!)
            if user!.dateOfBirth != nil {
                _dateOfBirth = State(initialValue: user!.dateOfBirth!)
            }
        }
    }
    
    var body: some View {
        GeometryReader {
            metrics in
            VStack {
                List {
                    Section {
                        TextField("Firstname", text: $firstname)
                            .textContentType(.givenName)
                        TextField("Lastname", text: $lastname)
                            .textContentType(.familyName)
                    } header: {
                        Text("Required")
                    } footer: {
                        Text("These Data are required to log in")
                    }
                    .onSubmit { checkBtn() }
                    .textInputAutocapitalization(.words)
                    .keyboardType(.asciiCapable)
                    Section {
                        datePicker()
                    } header: {
                        Text("Optional")
                    } footer: {
                        Text("You don't have to enter these Data, they're optional")
                    }
                }
                Button(action: action) {
                    Label(
                        "Save",
                        systemImage: "square.and.arrow.down"
                    )
                    .frame(
                        width: metrics.size.width / 1.2,
                        height: metrics.size.height / 15
                    )
                    .foregroundColor(.white)
                    .background(btnActive ? Color.blue : Color.gray)
                    .cornerRadius(20)
                }
                .alert(
                    "Missing Data",
                    isPresented: $errMissingArgumentsPresented
                ) {
                } message: {
                    Text("Please enter all required Data before you continue")
                }
            }
        }
        .navigationBarTitleDisplayMode(.automatic)
        .navigationBarBackButtonHidden()
        .textFieldStyle(.plain)
        .formStyle(.grouped)
        .toolbarRole(.navigationStack)
        .toolbar(.automatic, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    action()
                }
            }
        }
    }
    
    /// Builds, renders and returns the Date Picker
    /// for the Users Date of Birth
    @ViewBuilder
    private func datePicker() -> some View {
        Toggle("Use Date of Birth", isOn: $useDateOfBirth)
        if useDateOfBirth {
            DatePicker(
                "Date",
                selection: $dateOfBirth,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
        } else {
            EmptyView()
        }
    }
    
    /// Checks if all required Data are entered, and if so
    /// activates the Button.
    private func checkBtn() -> Void {
        btnActive = !firstname.isEmpty && !lastname.isEmpty
    }
    
    /// The action to create a Legal Person and pass
    /// it to the callback
    private func action() -> Void {
        if btnActive {
            let user = User(context: viewContext)
            user.firstname = firstname
            user.lastname = lastname
            if useDateOfBirth {
                user.dateOfBirth = dateOfBirth
            }
            callback(user)
            dismiss()
        } else {
            errMissingArgumentsPresented.toggle()
        }
    }
}

internal struct UserEditor_Previews: PreviewProvider {
    static var previews: some View {
        UserEditor(action: {
            _ in
            print("Preview Button Pressed")
        })
    }
}
