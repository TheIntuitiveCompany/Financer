//
//  Relation.swift
//  Financer
//
//  Created by Julian Schumacher on 01.12.22.
//

import Foundation

/// The Protocol all the
/// different Types of Relations have
/// to correspond to
internal protocol Relation : CaseIterable,
                                Identifiable,
                                Equatable,
                                RawRepresentable where RawValue == String {}
