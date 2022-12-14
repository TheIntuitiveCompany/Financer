//
//  UserWrapper.swift
//  Financer
//
//  Created by Julian Schumacher on 04.01.23.
//

import Foundation

/// The Wrapper for a User Object used in this App.
/// It contains an optional User Object, just like the other Wrappers.
/// Unlike those other Wrappers, it also contains a double value for the bank
/// balance of the User, if the User is not logged in and with that no User is available.
internal final class UserWrapper : ObservableObject {
    
    /// The actual User Object for this App
    @Published internal final var user : User?
    
    /// The bank balance for an anonymous User, which means the User
    /// of the App has not been signed in yet.
    @Published internal final var anonymousBalance : Double = 0.00
    
    /// The initializer to create a Wrapper Object with a User
    /// passed down the initializer.
    /// Mostly used for testing and previews.
    internal init(user : User? = nil) {
        self.user = user
    }
    
    /// The enum that determines in
    /// which direction the amount of the new finance should
    /// be going
    private enum Direction {
        
        /// Add the amount to the total
        /// balance
        case up
        
        /// subtract the amount from the total
        /// balance
        case down
    }
    
    /// Computed variable returning and setting
    /// the anonymous or user balance depending
    /// on the current State of the User
    private var balance : Double {
        get { user != nil ? user!.balance : anonymousBalance }
        set { user != nil ? (user!.balance = newValue) : (anonymousBalance = newValue) }
    }
    
    /// Adjusts the balance depending on direction
    /// argument.
    ///
    /// This Function handles the User and anonymous Balance, depending on
    /// the Users currently logged in state
    private func adjustBalance(direction : Direction, amount : Double) -> Void {
        switch direction {
            case .up:
                balance += amount
            case .down:
                balance -= amount
        }
    }
    
    /// Function that should be called when a new
    /// Finance is added to the App and the User's
    /// balance should be updated
    internal func addFinance(_ finance : Finance) -> Void {
        if finance is Income {
            adjustBalance(direction: .up, amount: finance.amount)
        } else {
            adjustBalance(direction: .down, amount: finance.amount)
        }
    }
    
    /// Function called when a Finance is repalced.
    /// This removes the old Finances Data and updates it with
    /// the new Value calculated in.
    internal func replaceFinance(_ oldFinance : Finance, with newFinance: Finance) -> Void {
        if oldFinance is Income {
            adjustBalance(direction: .down, amount: oldFinance.amount)
        } else {
            adjustBalance(direction: .up, amount: oldFinance.amount)
        }
        if newFinance is Income {
            adjustBalance(direction: .up, amount: newFinance.amount)
        } else {
            adjustBalance(direction: .down, amount: newFinance.amount)
        }
    }
    
    /// Returns a Dictionary containing the Date and the Balance on the end of that day.
    /// The index specifies the number of days to go back
    internal func balance(
        days : Int? = nil,
        with finances : any RandomAccessCollection<Finance>
    ) -> [(date : Date, amount : Double)] {
        guard !finances.isEmpty else {
            return []
        }
        var amounts : [Date : Double] = [ : ]
        var dict : [(date : Date, amount : Double)] = []
        let calendar : Calendar = Calendar.current
        let today : Date = Date()
        let intervalInSeconds : TimeInterval = Date.now.timeIntervalSince(finances.last!.date!)
        let interval = intervalInSeconds / 86400
        for index in 0...Int(interval) {
            var i : Int = index
            i.negate()
            var date : Date = calendar.date(byAdding: .day, value: i, to: today)!
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            date = calendar.date(from: dateComponents)!
            let financesOnDay : [Finance] = finances.filter {
                let dateToCheck = calendar.dateComponents([.year, .month, .day], from: $0.date!)
                let components = dateComponents
                return dateToCheck.year == components.year && dateToCheck.month == components.month && dateToCheck.day == components.day
            }
            var amount : Double = 0
            financesOnDay.forEach {
                finance in
                amount += finance.amount
            }
            amounts[date] = amount
            var balanceOfTheDay = self.balance
            for previousAmounts in amounts {
                balanceOfTheDay -= previousAmounts.value
            }
            dict.append((date: date, amount : balanceOfTheDay))
            if let check = days, index >= check {
                break
            }
        }
        return dict
    }
}
