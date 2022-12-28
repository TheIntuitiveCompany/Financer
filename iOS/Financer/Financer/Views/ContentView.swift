//
//  ContentView.swift
//  Financer
//
//  Created by Julian Schumacher on 21.12.22.
//

import SwiftUI
import CoreData

/// The first View shown to the User when opening
/// the App.
internal struct ContentView: View {
    /// The ViewContext to use when interacting with the Core Data Framework
    @Environment(\.managedObjectContext) private var viewContext
    
    // Preview Code Start
    // (Comment to build)
    //
    // This Code is used in development because it works with the preview.
    // Solution from: https://developer.apple.com/forums/thread/654126
    
    /// The Finances fetched from
    /// the Core Database
    @FetchRequest(fetchRequest: financeFetchRequest)
    private var finances : FetchedResults<Finance>
    
    /// This is the fetch Request to fetch all the Finances
    /// from the Core Data Persistence Storage
    static private var financeFetchRequest : NSFetchRequest<Finance> {
        let request = Finance.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \Finance.date,
                ascending: true
            )
        ]
        return request
    }
    // Preview Code End
    
    
    // Production Code Start
    // (Uncomment to build)
    //
    // This Code is used in production, becasue this Code
    // is generated by Apple and it is shorter.
    // This just doesn't work with the Preview
    
    /// The Finances fetched form the
    /// Code Database.
    //    @FetchRequest(
    //        sortDescriptors: [
    //            SortDescriptor(\Finance.date, order: .reverse)
    //        ]
    //    ) private var finances : FetchedResults<Finance>
    // Production Code End
    
    /// Whether the Add View is presented or not.
    @State private var addPresented : Bool = false
    
    /// Whether the details View for a finance is presented or not.
    @State private var detailsPresented : Bool = false
    
    /// The Finance for for which the details View should
    /// be generated.
    @State private var finance : Finance?
    
    var body: some View {
        NavigationStack {
            List(finances) {
                finance in
                Button {
                    self.finance = finance
                    if self.finance != nil {
                        detailsPresented.toggle()
                    }
                } label: {
                    label(finance)
                }
                .foregroundColor(.black)
            }
            Button {
                addPresented.toggle()
            } label: {
                Label("Add Finance", systemImage: "plus")
            }.sheet(
                isPresented: $addPresented,
                content: { AddFinance() }
            )
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.automatic)
            .sheet(item: $finance) {
                FinanceDetails(finance: $0)
            }
        }
    }
    
    /// Builds and returns the Label
    /// of a specific Finance List Object
    @ViewBuilder
    private func label(_ finance : Finance) -> some View {
        HStack {
            Image(systemName: finance is Income ? "plus" : "minus")
                .renderingMode(.original)
                .padding(.trailing, 8)
            VStack(alignment: .leading) {
                let amount : String = String(format: "%.2f$", finance.amount)
                Text(amount)
                    .font(.headline)
                    .foregroundColor(finance is Income ? .green : .red)
                // Legal Person isn't an optional Parameter, but still you have to use the ? because Swift Optional and Core Data Optional aren't the same thing
                Text(finance.legalPerson?.name ?? "Unknown")
                // Same with the Date as above with the legal Person.
                // Only with the difference that I'm enforcing the Date here.
                Text(finance.date!, format: .dateTime.day().month().year())
                    .foregroundColor(.gray)
            }
        }
    }
}

internal struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
