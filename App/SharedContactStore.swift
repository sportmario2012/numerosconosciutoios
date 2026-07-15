import Foundation

/// Store condiviso tra l'app principale e la Call Directory Extension.
/// Richiede un App Group configurato in entrambi i target
/// (es. "group.com.marioadj.numerosconosciuto" — sostituisci con il tuo).
enum SharedContactStore {

    static let appGroupID = "group.com.marioadj.numerosconosciuto"
    private static let chiave = "contatti_v1"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func getTutti() -> [Contatto] {
        guard let data = defaults?.data(forKey: chiave) else { return [] }
        return (try? JSONDecoder().decode([Contatto].self, from: data)) ?? []
    }

    static func salvaTutti(_ contatti: [Contatto]) {
        guard let data = try? JSONEncoder().encode(contatti) else { return }
        defaults?.set(data, forKey: chiave)
    }

    static func aggiungi(_ contatto: Contatto) {
        var lista = getTutti()
        lista.removeAll { $0.numero == contatto.numero }
        lista.append(contatto)
        salvaTutti(lista)
    }

    static func elimina(_ contatto: Contatto) {
        var lista = getTutti()
        lista.removeAll { $0.numero == contatto.numero }
        salvaTutti(lista)
    }
}
