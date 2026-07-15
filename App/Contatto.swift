import Foundation

enum TagTipo: String, Codable, CaseIterable {
    case contatto = "Contatto"
    case spam = "Spam"
    case azienda = "Azienda"
}

/// Numero in formato E.164 (es. +393331234567) — obbligatorio per CallKit.
struct Contatto: Codable, Identifiable, Equatable {
    var id: String { numero }
    var numero: String
    var nome: String
    var tag: TagTipo
    var bloccato: Bool = false // se true, l'estensione blocca la chiamata
}
