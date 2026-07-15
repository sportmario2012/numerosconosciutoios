import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        do {
            try aggiungiIdentificazioni(a: context)
            try aggiungiBlocchi(a: context)
        } catch {
            context.cancelRequest(withError: error)
            return
        }

        context.completeRequest()
    }

    /// iOS richiede che le entry siano aggiunte in ordine numerico crescente,
    /// separatamente per identificazione e per blocco.
    private func aggiungiIdentificazioni(a context: CXCallDirectoryExtensionContext) throws {
        let daIdentificare = SharedContactStore.getTutti()
            .compactMap { c -> (CXCallDirectoryPhoneNumber, String)? in
                guard let numero = numeroValido(c.numero) else { return nil }
                let etichetta = "\(c.tag.rawValue): \(c.nome)"
                return (numero, etichetta)
            }
            .sorted { $0.0 < $1.0 }

        for (numero, etichetta) in daIdentificare {
            context.addIdentificationEntry(withNextSequentialPhoneNumber: numero, label: etichetta)
        }
    }

    private func aggiungiBlocchi(a context: CXCallDirectoryExtensionContext) throws {
        let daBloccare = SharedContactStore.getTutti()
            .filter { $0.bloccato }
            .compactMap { numeroValido($0.numero) }
            .sorted()

        for numero in daBloccare {
            context.addBlockingEntry(withNextSequentialPhoneNumber: numero)
        }
    }

    /// Converte un numero E.164 (es. "+393331234567") nel formato Int64 richiesto da CallKit.
    private func numeroValido(_ numero: String) -> CXCallDirectoryPhoneNumber? {
        let pulito = numero.replacingOccurrences(of: "+", with: "")
        return CXCallDirectoryPhoneNumber(pulito)
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for context: CXCallDirectoryExtensionContext, withError error: Error) {
        // Log locale utile in debug — l'estensione non ha console visibile all'utente.
        NSLog("CallDirectoryHandler fallita: \(error.localizedDescription)")
    }
}
