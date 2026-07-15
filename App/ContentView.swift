import SwiftUI
import CallKit

struct ContentView: View {
    @State private var contatti: [Contatto] = SharedContactStore.getTutti()
    @State private var mostraAggiunta = false
    @State private var messaggioStato: String?

    var body: some View {
        NavigationView {
            List {
                if let messaggio = messaggioStato {
                    Text(messaggio)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                ForEach(contatti) { contatto in
                    VStack(alignment: .leading) {
                        Text(contatto.nome).bold()
                        Text("\(contatto.numero) — \(contatto.tag.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: elimina)
            }
            .navigationTitle("Numero Sconosciuto")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { mostraAggiunta = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Aggiorna", action: ricaricaEstensione)
                }
            }
            .sheet(isPresented: $mostraAggiunta) {
                AggiungiContattoView { nuovo in
                    SharedContactStore.aggiungi(nuovo)
                    contatti = SharedContactStore.getTutti()
                    ricaricaEstensione()
                }
            }
        }
    }

    private func elimina(at offsets: IndexSet) {
        offsets.forEach { SharedContactStore.elimina(contatti[$0]) }
        contatti = SharedContactStore.getTutti()
        ricaricaEstensione()
    }

    /// Dice a iOS di ricaricare la Call Directory Extension con i dati aggiornati.
    /// Necessario ogni volta che la lista cambia — non è automatico.
    private func ricaricaEstensione() {
        // Sostituisci con il bundle identifier reale della tua estensione.
        let extensionID = "com.marioadj.numerosconosciuto.CallDirectoryExtension"
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: extensionID) { errore in
            DispatchQueue.main.async {
                if let errore = errore {
                    messaggioStato = "Errore aggiornamento: \(errore.localizedDescription)"
                } else {
                    messaggioStato = "Elenco aggiornato — verifica che l'estensione sia attiva in Impostazioni > Telefono > Blocco chiamate e ID."
                }
            }
        }
    }
}

struct AggiungiContattoView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var numero = ""
    @State private var nome = ""
    @State private var tag: TagTipo = .contatto
    var onSalva: (Contatto) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Numero (formato +39...)", text: $numero)
                    .keyboardType(.phonePad)
                TextField("Nome / etichetta", text: $nome)
                Picker("Tipo", selection: $tag) {
                    ForEach(TagTipo.allCases, id: \.self) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
            }
            .navigationTitle("Nuovo numero")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        guard !numero.isEmpty, !nome.isEmpty else { return }
                        let bloccato = (tag == .spam)
                        onSalva(Contatto(numero: numero, nome: nome, tag: tag, bloccato: bloccato))
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}
