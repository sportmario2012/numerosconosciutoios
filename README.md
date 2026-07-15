# Numero Sconosciuto — iOS

## Limite architetturale (da capire prima di tutto)
iOS **non permette** overlay su chiamate in arrivo e **non permette** di leggere
il numero in tempo reale durante lo squillo (bloccato per privacy da iOS 13+).
L'unico meccanismo ufficiale è **CallKit Call Directory Extension**: carichi in
anticipo una lista statica di numeri con etichetta; è **il sistema operativo**,
non la tua app, a mostrare quell'etichetta sotto il numero nella schermata di
chiamata nativa di iOS. Nessuna UI personalizzata possibile.

Di conseguenza l'app fa questo:
- Schermata per aggiungere/gestire numeri con tag (Contatto/Spam/Azienda)
- Ogni numero taggato "Spam" può anche essere bloccato direttamente da iOS
- Al salvataggio, l'app dice a iOS di ricaricare l'estensione (`CXCallDirectoryManager.reloadExtension`)
- iOS mostra l'etichetta nativa alla prossima chiamata da quel numero

## Struttura
- `App/` — app SwiftUI principale (lista, aggiunta, ricarica estensione)
- `CallDirectoryExtension/` — l'estensione che iOS interroga davvero
- `project.yml` — spec XcodeGen, genera il `.xcodeproj` reale
- `.github/workflows/build-ios.yml` — CI su runner macOS

## Come buildare senza un Mac

### Opzione A — build di verifica (gratis, nessun setup)
Push su `main` o `workflow_dispatch` manuale su GitHub Actions: il job
`build-verifica` compila il progetto (non firmato) solo per controllare che
non ci siano errori. Non produce un IPA installabile.

### Opzione B — IPA firmato e installabile
Lancia manualmente il workflow (tab Actions > Run workflow) dopo aver
configurato questi secret nel repo (Settings > Secrets and variables > Actions):

| Secret | Cosa contiene |
|---|---|
| `APPLE_CERTIFICATE_P12_BASE64` | Certificato di firma in formato `.p12`, codificato base64 |
| `APPLE_CERTIFICATE_PASSWORD` | Password del `.p12` |
| `APPLE_PROVISIONING_PROFILE_B64` | Provisioning profile `.mobileprovision`, codificato base64 |
| `APPLE_TEAM_ID` | Il tuo Team ID da developer.apple.com |

Serve un **Apple ID** registrato su developer.apple.com (gratuito per generare
certificati "Development", a pagamento — 99$/anno — per profili stabili di
lunga durata e per capability più complete). Puoi generare certificato e CSR
anche senza Mac, con OpenSSL da riga di comando, seguendo la guida Apple sui
certificati (il portale accetta un CSR generato ovunque).

Passi sul portale Apple Developer:
1. **Certificates** → crea certificato, scarica, converti in `.p12`
2. **Identifiers** → registra `com.marioadj.numerosconosciuto` e
   `com.marioadj.numerosconosciuto.CallDirectoryExtension`, abilita **App
   Groups** su entrambi, crea il gruppo `group.com.marioadj.numerosconosciuto`
3. **Profiles** → crea un provisioning profile per ciascun target
4. Converti i file in base64 (`base64 -w0 file.p12` su Linux) e incollali
   come secret GitHub

[UNCERTAIN] Se un account "personal team" gratuito basti per la capability
App Groups + Call Directory su device reale con validità oltre 7 giorni:
verificalo direttamente nel portale Apple Developer prima di investire tempo
in tutto il resto — se serve il programma a pagamento è meglio saperlo subito.

## Installazione dell'IPA risultante
Un IPA firmato con certificato "Development" si installa via:
- **Sideloadly** (Windows/Mac) — drag & drop dell'IPA, richiede solo Apple ID
- **AltStore** — stesso principio, richiede rinnovo periodico se Apple ID gratuito

## Dopo l'installazione
Vai su **Impostazioni > Telefono > Blocco chiamate e ID chiamante** e attiva
l'estensione "NumeroSconosciuto Extension" — senza questo passaggio manuale
iOS ignora l'estensione anche se installata.
