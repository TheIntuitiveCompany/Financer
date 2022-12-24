//
//  AddFinance.swift
//  Financer
//
//  Created by Julian Schumacher on 23.12.22.
//

import SwiftUI

/// The View to add a new Finance
internal struct AddFinance: View {
    
    /// The Type of this Finance
    private enum FinanceType : String, CaseIterable, Identifiable {
        // ID to conform to Identifiable
        var id : Self { self }
        
        /// The Finance is an income.
        case income
        
        /// The Finance is an expense.
        case expense
    }
    
    /// The Context used to interact with the Core Data
    /// Manager
    @Environment(\.managedObjectContext) private var viewContext
    
    /// The dismiss Action to dismiss this View.
    ///
    /// This is used, because this view is presented as a sheet or popover.
    @Environment(\.dismiss) private var dismiss : DismissAction
    
    /// The Text of the "Amount" Textfield
    @State private var amount : String = ""
    
    /// The Legal Person connected to this Finance
    @State private var legalPerson : LegalPerson?
    
    /// The Date this Finance referes to
    @State private var date : Date = Date()
    
    /// The Notes to this Finance
    @State private var notes : String = ""
    
    /// Whether the Button is active (all Fields are enter validly) or
    /// not.
    @State private var btnActive : Bool = false
    
    /// Whether ther Error for missing Arguments is displayed or not.
    @State private var errMissingArgumentsPresented : Bool = false
    
    /// Whether ther Error when saving is displayed or not.
    @State private var errSavingPresented : Bool = false
    
    /// The Type of this Finance
    @State private var financeType : FinanceType = .income
    
    /// Whether this View is in edit mode or not.
    private let edit : Bool
    
    /// The normal initializer to use
    /// this View to add a new Finance
    internal init() {
        edit = false
    }
    
    /// The Initializer if this view is used to
    /// edit a finance
    internal init(finance : Finance) {
        edit = true
        amount = String(finance.amount)
        legalPerson = finance.legalPerson
        date = finance.date!
        notes = finance.notes ?? ""
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader {
                metrics in
                VStack {
                    Picker("Type", selection: $financeType) {
                        ForEach(FinanceType.allCases) {
                            fT in
                            Text(fT.rawValue.capitalized)
                        }
                    }
                    .padding(.horizontal, 10)
                    .pickerStyle(.segmented)
                    Form {
                        Section {
                            TextField("Amount", text: $amount)
                                .keyboardType(.decimalPad)
                            NavigationLink {
                                LegalPersonPicker(
                                    legalPerson: $legalPerson
                                )
                            } label: {
                                legalPersonNavigationLabel()
                            }
                        } header: {
                            Text("General Information")
                        } footer: {
                            Text("It's required to enter these Information")
                        }
                        Section {
                            DatePicker(
                                "Date",
                                selection: $date,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.graphical)
                            TextField("Notes", text: $notes, axis: .vertical)
                                .lineLimit(5)
                                .keyboardType(.asciiCapable)
                        } header: {
                            Text("Optional Data")
                        } footer: {
                            VStack(alignment: .leading) {
                                Text("If you want to customize these Data, you can do so here.")
                                Text("Otherwise these Data will be inserted automatically.")
                            }
                        }
                    }
                    .animation(.easeIn, value: financeType)
                    Button(action: addFinance) {
                        Label(
                            "Save",
                            systemImage: "square.and.arrow.down"
                        )
                        .frame(
                            width: metrics.size.width / 1.2,
                            height: metrics.size.height / 15
                        )
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(20)
                    }
                    .alert(
                        "Missing Data",
                        isPresented: $errMissingArgumentsPresented
                    ) {
                    } message: {
                        Text("Please enter all Data before you continue")
                    }
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
            .textFieldStyle(.plain)
            .formStyle(.grouped)
            .navigationTitle("\(edit ? "Edit" : "Add") Finance")
            .navigationBarTitleDisplayMode(.automatic)
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
                        dismiss()
                    }
                }
            }
        }
    }
    
    /// Creates and adds the Finance to the Core Data.
    private func addFinance() -> Void {
        if btnActive {
            let finance : Finance
            switch financeType {
                case .income:
                    finance = Income(context: viewContext)
                case .expense:
                    finance = Expense(context: viewContext)
                default:
                    // Default to Expense because that's
                    // how it's done everywhere in this App.
                    finance = Expense(context: viewContext)
            }
            finance.amount = Double(amount)!
            finance.legalPerson = legalPerson
            finance.notes = notes
            finance.date = date
            do {
                try viewContext.save()
            } catch _ {
                errSavingPresented.toggle()
            }
        } else {
            errMissingArgumentsPresented.toggle()
        }
    }
    
    /// Builds and returns the label
    /// connected to the navigation Link which
    /// points to the Legal Person Picker
    @ViewBuilder
    private func legalPersonNavigationLabel() ->
    HStack<TupleView<(Text, Spacer, Text)>> {
        HStack {
            Text(financeType == .income ? "From" : "To")
            Spacer()
            Text(legalPerson?.name ?? "None")
                .foregroundColor(.gray)
        }
    }
}

struct AddFinance_Previews: PreviewProvider {
    static var previews: some View {
        AddFinance()
    }
}