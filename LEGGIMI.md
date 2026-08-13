# Ricettario → APK Android

Questi sono i **sorgenti** per generare un'app Android (APK) installabile dal tuo
ricettario. L'app è una WebView che carica `www/index.html` (la versione standalone
con `localStorage`): funziona **offline** e salva le ricette sul dispositivo.

Hai due strade. Scegli quella che preferisci.

---

## STRADA A — Online gratuito (nessun software da installare)

La più veloce: carichi i file e ti scarichi l'APK.

1. Crea uno **ZIP** della cartella `www` (deve contenere `index.html` nella radice
   dello zip). In alternativa molti servizi accettano direttamente il singolo
   `index.html`.
2. Vai su uno di questi servizi (free):
   - **AppsGeyser** (appsgeyser.com) → modello *HTML/ZIP to APK*.
   - **WebIntoApp** (webintoapp.com/html-to-app) → carica lo ZIP del progetto.
   - **AI SaaS Zone HTML to APK** → genera un *progetto Android Studio* completo
     (utile se poi vuoi i sorgenti nativi).
3. Imposta nome ("Ricettario"), icona, colori, e attiva l'eventuale opzione
   *offline / DOM storage* se presente.
4. Genera e scarica l'**APK**, copialo sul telefono e installalo
   (abilita "origini sconosciute" / "installa app sconosciute").

> Nota onesta: nei piani gratuiti questi servizi aggiungono spesso **branding o
> banner pubblicitari** e un loro package name. Per un'app personale va benissimo;
> se vuoi un APK "pulito" e tuo al 100%, usa la Strada B.

> PWABuilder NON è l'ideale qui: produce una *Trusted Web Activity* che punta a un
> sito **ospitato online**, mentre noi vogliamo un'app **locale/offline**.

---

## STRADA D — Cloud, zero installazioni (GitHub Actions)

Se non vuoi installare NIENTE sul PC, compila l'APK nel cloud:
1. Crea un repository GitHub gratuito e carica tutto il contenuto di questa cartella
   (incluso `.github/workflows/build-apk.yml`).
2. Apri la scheda **Actions**: la build parte da sola (o premi **Run workflow**).
3. A fine build scarica l'APK dagli **Artifacts** (`ricettario-apk`).
Nessun JDK/SDK/Gradle da installare: li mette il runner di GitHub.

## STRADA B — Windows portable (APK tuo, gratis e open source) con Cordova

Nessun installer "di sistema": bastano tre strumenti in versione **portable (zip)**.

### 1. Strumenti portable da scompattare (es. in `C:\portable\`)
- **Node.js** (zip "Windows Binary x64") → `C:\portable\node`  (richiesto Node ≥ 20.17)
- **JDK 17** (Eclipse Temurin, zip) → `C:\portable\jdk-17`
- **Android SDK – Command line tools only** (zip) → scompatta in
  `C:\portable\android-sdk\cmdline-tools\latest\`
  (la cartella deve chiamarsi esattamente `latest`)

### 2. Installa i pezzi dell'SDK (una volta sola)
Apri il **Prompt dei comandi** e imposta le variabili:

```bat
set "JAVA_HOME=C:\portable\jdk-17"
set "ANDROID_HOME=C:\portable\android-sdk"
set "PATH=C:\portable\node;%JAVA_HOME%\bin;%ANDROID_HOME%\cmdline-tools\latest\bin;%PATH%"

sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"
```
Accetta le licenze:
```bat
sdkmanager --licenses
```

### 3. Installa Cordova (in locale al progetto, niente -g necessario)
Dalla cartella di questo progetto (`ricettario-cordova`):
```bat
npm install
```
(installa `cordova-android`; per il comando `cordova` puoi usare `npx cordova ...`)

### 4. Compila l'APK
Modifica le prime 3 righe di **`build.bat`** coi tuoi percorsi e poi:
```bat
build.bat
```
oppure manualmente:
```bat
npx cordova platform add android
npx cordova build android
```

### 5. Risultato
L'APK di debug è qui:
```
platforms\android\app\build\outputs\apk\debug\app-debug.apk
```
Copialo sul telefono e installalo.

> Versioni di riferimento (giugno 2026): **cordova-android 14** → **JDK 17**,
> **API 35**, **Node ≥ 20.17**, Gradle (gestito da Cordova). Se usi cordova-android 13,
> resta JDK 17 ma API 34.

---

## In alternativa: `cordova create` da zero
Se preferisci far generare a Cordova l'intera struttura e poi inserire i nostri file:
```bat
npx cordova create ricettario com.lorenzo.ricettario Ricettario
cd ricettario
:: sostituisci www\index.html con il nostro, e config.xml con il nostro
npx cordova platform add android
npx cordova build android
```

---

## Note sui dati e sullo scambio ricette
- Le ricette sono salvate con **localStorage** (chiave `ricettario_v1`): restano sul
  telefono tra un avvio e l'altro. Ogni ricetta ha un **ID univoco**.
- Sezione **Scambia** dell'app:
  - **Esporta**: selezioni le ricette (manualmente o tutte) e generi un file `.json`.
    Nel browser parte il download; **nell'app Android** il file viene salvato e si apre
    il menu **Condividi** (WhatsApp, email, ecc.) per inviarlo a chi ha l'app.
  - **Importa**: scegli un file ricevuto; l'app mostra l'anteprima e segnala
    **Nuova / Nome esistente / Già presente**. I doppioni (stesso ID) sono esclusi
    automaticamente; scegli quali importare (solo nuove, tutte le importabili, manuale).
- Per la condivisione/scrittura file e per lo schermo sempre acceso servono tre plugin
  Cordova (già indicati in `config.xml` e `package.json`):
  `cordova-plugin-file`, `cordova-plugin-x-socialsharing`, `cordova-plugin-insomnia`.
  Se non vengono installati in automatico, aggiungili a mano:
  ```bat
  npx cordova plugin add cordova-plugin-file cordova-plugin-x-socialsharing cordova-plugin-insomnia
  ```
  L'**importazione** funziona anche senza plugin (usa il selettore file della WebView).

## Altre funzioni dell'app
- **Foto delle ricette**: aggiungi fino a 6 foto per ricetta (la prima è la copertina).
  Le immagini vengono ridotte e compresse in automatico e salvate in **IndexedDB**
  (le ricette restano leggere in localStorage). Compaiono come copertina nelle card e
  come galleria nella scheda. Nell'export c'è la spunta **"Includi foto"** (file più
  pesante); in import le foto vengono ricreate. Le foto condivise da duplicati/varianti
  sono gestite a conteggio di riferimenti: si eliminano solo quando nessuna ricetta le usa.
- **Ricerca intelligente**: tollera accenti mancanti e piccoli refusi
  (es. "tiramisu" trova "Tiramisù", "risoto" trova "Risotto", "parmig" trova "Parmigiano").
- **Autosave della bozza**: mentre inserisci o modifichi una ricetta, la bozza viene
  salvata da sola; se chiudi per sbaglio, alla riapertura ti viene proposto di riprenderla.
- **Annulla / Ripeti** nel form (frecce in alto o Ctrl+Z / Ctrl+Y) per ingredienti e passaggi.
- **Arrotondamento intelligente** delle quantità quando cambi le porzioni: niente "266,6 g"
  (diventa 265) e gli ingredienti a pezzo (uova, spicchi…) restano interi.
- **Lettura vocale**: in modalità cucina puoi leggere il passaggio a voce (utile a mani
  occupate) con una modalità **automatica** che legge da sola ogni nuovo passaggio; dalla
  scheda c'è "Leggi" per ascoltare tutti i passaggi in sequenza. Usa la sintesi vocale del
  dispositivo (voce italiana se disponibile). Nota: nella WebView Android il supporto vocale
  può variare; nel browser/PWA funziona regolarmente.
- **Modalità cucina**: vista a schermo intero, un passaggio alla volta con testo grande;
  si avanza con tap, swipe o frecce, con barra di avanzamento e accesso rapido agli
  ingredienti (alle porzioni impostate). All'ingresso attiva da sola lo schermo sempre acceso.
- **Note e valutazione**: ogni ricetta ha le tue note e un voto da 1 a 5 stelle.
  Le **note viaggiano** con la ricetta quando la esporti (spesso sono consigli utili);
  **voto e preferiti restano personali** e non vengono condivisi.
- **Schermo acceso** (scheda ricetta): impedisce lo spegnimento del display mentre cucini.
  Nell'app usa `cordova-plugin-insomnia`; nel browser la Screen Wake Lock API.
- **Preferiti** (stellina) e **Recenti**: filtri rapidi nel ricettario.
- **Duplica**: crea una copia modificabile della ricetta (nuovo ID univoco).
- **Etichette (tag)**: libere, separate da virgola; filtrabili e ricercabili.
  Viaggiano insieme alla ricetta quando la esporti.
- **Riordino passaggi**: frecce su/giù nel form di gestione.
- **Lista della spesa**: somma gli ingredienti di più ricette alle porzioni scelte
  (solo se nome e unità coincidono; "q.b." e unità diverse restano voci separate).
  Salvata a parte, con voci libere e spunte.
- **Stampa / PDF**: dalla scheda ricetta stampa le dosi **attualmente impostate**
  (in Android: Stampa → "Salva come PDF").

## APK firmato per release (facoltativo)
Per un APK di release firmato:
```bat
npx cordova build android --release -- ^
  --keystore=miakey.keystore --storePassword=PWD --alias=alias --password=PWD
```
(prima crea il keystore con `keytool -genkey -v -keystore miakey.keystore -alias alias -keyalg RSA -keysize 2048 -validity 10000`)
