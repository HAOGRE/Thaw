//
//  SupportedLanguage.swift
//  Project: Thaw
//
//  Copyright (Ice) © 2023–2025 Jordan Baird
//  Copyright (Thaw) © 2026 Toni Förster
//  Licensed under the GNU GPLv3

import Foundation

/// A language that Thaw has translations for in its string catalog.
///
/// Each case corresponds to a BCP 47 language tag that maps to a compiled
/// `.lproj` directory in the app bundle. The list must stay in sync with
/// the languages declared in `Localizable.xcstrings`.
enum SupportedLanguage: String, CaseIterable, Identifiable {
    case cs
    case de
    case en
    case es
    case fr
    case hu
    case id
    case it
    case ja
    case ko
    case nl
    case pl
    case ptBR = "pt-BR"
    case ru
    case th
    case tr
    case uk
    case vi
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"

    var id: String {
        rawValue
    }

    /// The BCP 47 tag written to `AppleLanguages` in `UserDefaults`.
    var identifier: String {
        rawValue
    }

    /// The language name rendered in its own script (e.g. "简体中文").
    var localName: String {
        Locale(identifier: rawValue).localizedString(forIdentifier: rawValue) ?? rawValue
    }
}
