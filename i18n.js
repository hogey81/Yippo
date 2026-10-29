/* Yippo vertalingen. De code in index.html schrijft Nederlands; deze laag vertaalt weergegeven tekst naar Engels/Spaans.
   Rijen: [nederlands, engels, spaans]. "{}" is een invulplek (getal, naam, ...). */
(function(){
const ROWS=[
["Je voortgang staat nu alleen op dit toestel. Bewaar hem met je e-mailadres, dan raak je hem nooit meer kwijt.","Your progress is only stored on this device right now. Save it with your email address and you will never lose it.","Tu progreso solo está guardado en este dispositivo. Guárdalo con tu correo electrónico y nunca lo perderás."],
["Record {}","Record {}","Récord {}"],
["Jij {}","You {}","Tú {}"],
["{} dag","{} day","{} día"],
["{} dagen","{} days","{} días"],
["Record: {} · 👤 Jij: {}","Record: {} · 👤 You: {}","Récord: {} · 👤 Tú: {}"],
["De Pinguïn-ijsvlakte","Penguin Ice Plain","Llanura helada de los pingüinos"],
["De Koala's","The Koalas","Los Koalas"],
["Keizerpinguïn","Emperor penguin","Pingüino emperador"],
["Zeeluipaard","Leopard seal","Foca leopardo"],
["Orka","Orca","Orca"],
["Bultrug","Humpback whale","Ballena jorobada"],
["Krill","Krill","Krill"],
["Reuzeninktvis","Colossal squid","Calamar colosal"],
["IJsvis","Icefish","Pez de hielo"],
["Zandloperdolfijn","Hourglass dolphin","Delfín cruzado"],
["Bij de keizerpinguïn houdt de vader het ei op zijn voeten warm, wel twee maanden lang.","A father emperor penguin keeps the egg warm on his feet for as long as two months.","El papá pingüino emperador mantiene el huevo caliente sobre sus patas durante hasta dos meses."],
["De zeeluipaard leeft op het zee-ijs rond Antarctica en eet onder meer krill, vis en pinguïns.","The leopard seal lives on the sea ice around Antarctica and eats krill, fish and penguins, among other things.","La foca leopardo vive sobre el hielo marino alrededor de la Antártida y come krill, peces y pingüinos, entre otras cosas."],
["Een orka blijft zijn hele leven bij zijn familiegroep.","An orca stays with its family group its whole life.","Una orca se queda con su grupo familiar toda la vida."],
["In de zomer eet de bultrug veel krill bij Antarctica, in de winter zwemt hij naar warmer water.","In summer the humpback whale eats lots of krill near Antarctica; in winter it swims to warmer water.","En verano la ballena jorobada come mucho krill cerca de la Antártida; en invierno nada hacia aguas más cálidas."],
["Krill zijn kleine garnaaltjes, maar er zijn er zo veel dat ze het belangrijkste eten zijn voor veel dieren bij Antarctica.","Krill are tiny shrimp-like animals, but there are so many that they are the main food for lots of animals near Antarctica.","El krill son pequeños animales parecidos a camarones, pero hay tantos que son el alimento principal de muchos animales cerca de la Antártida."],
["De reuzeninktvis heeft de grootste ogen van alle dieren: groter dan een voetbal.","The colossal squid has the biggest eyes of any animal: bigger than a football.","El calamar colosal tiene los ojos más grandes de todos los animales: más grandes que un balón de fútbol."],
["Het bloed van de ijsvis is niet rood, maar doorzichtig.","The blood of the icefish is not red, but see-through.","La sangre del pez de hielo no es roja, sino transparente."],
["De zandloperdolfijn zwemt als enige kleine dolfijn in het ijskoude water ver in het zuiden.","The hourglass dolphin is the only small dolphin that swims in the ice-cold water far in the south.","El delfín cruzado es el único delfín pequeño que nada en las aguas heladas del extremo sur."],
["Eet vis en krill","Eats fish and krill","Come pescado y krill"],
["Zee-ijs","Sea ice","Hielo marino"],
["Alle oceanen","All oceans","Todos los océanos"],
["Eet krill","Eats krill","Come krill"],
["Eet algen","Eats algae","Come algas"],
["Zuidelijke Oceaan","Southern Ocean","Océano Austral"],
["Diepzee","Deep sea","Mar profundo"],
["IJskoud water","Icy water","Agua helada"],
["Antarctica","Antarctica","Antártida"],
["Zee-ijs rond Antarctica","Sea ice around Antarctica","Hielo marino alrededor de la Antártida"],
["Alle oceanen, ook rond Antarctica","All oceans, including around Antarctica","Todos los océanos, también alrededor de la Antártida"],
["Alle oceanen, in de zomer bij Antarctica","All oceans, near Antarctica in summer","Todos los océanos, en verano cerca de la Antártida"],
["Zuidelijke Oceaan rond Antarctica","Southern Ocean around Antarctica","Océano Austral alrededor de la Antártida"],
["Diep in de Zuidelijke Oceaan","Deep in the Southern Ocean","En lo profundo del Océano Austral"],
["Dit dier leeft op en in het water, daarom is er geen landenkaart.","This animal lives on and in the water, so there is no country map.","Este animal vive sobre y dentro del agua, por eso no hay mapa de países."],
["Contact","Contact","Contacto"],
["Ik daag je uit!","I challenge you!","¡Te desafío!"],
["Verbreek mijn dagrecord!","Beat my daily record!","¡Supera mi récord del día!"],
["Kun jij mij verslaan?","Can you beat me?","¿Puedes ganarme?"],
["Download de app","Download the app","Descarga la app"],
["Binnenkort in Google Play","Coming soon on Google Play","Próximamente en Google Play"],
["Binnenkort in de App Store","Coming soon on the App Store","Próximamente en la App Store"],
["Meer info","More info","Más info"],
["SPONSOR GEZOCHT","SPONSOR WANTED","SE BUSCA PATROCINADOR"],
["Jouw bedrijf hier?","Your company here?","¿Tu empresa aquí?"],
["Laat je gezinsvriendelijke product of merk hier zien aan spelers. Mail ons voor de mogelijkheden.","Show your family-friendly product or brand to players here. Email us for the options.","Muestra aquí tu producto o marca familiar a los jugadores. Escríbenos para conocer las opciones."],
["Word sponsor","Become a sponsor","Hazte patrocinador"],
["Privacy","Privacy","Privacidad"],
["jij@voorbeeld.nl","you@example.com","tu@ejemplo.com"],
["Familie Jansen","The Smiths","Familia García"],
["level {}","level {}","nivel {}"],
["{} speler","{} player","{} jugador"],
["{} spelers","{} players","{} jugadores"],
["{} · {}/{}","{} · {}/{}","{} · {}/{}"],
["Wereld {} is open!","World {} is open!","¡El mundo {} está abierto!"],
["Wereld {}, {}, is open!","World {}, {}, is open!","¡El mundo {}, {}, está abierto!"],
["Volgend dier bij level {}:","Next animal at level {}:","Siguiente animal en el nivel {}:"],
["gast","guest","invitado"],
["Nieuwe puzzel vandaag · 🔥 {} {}","New puzzle today · 🔥 {} {}","Puzzle nuevo hoy · 🔥 {} {}"],
["Beste: {} · 🔥 {} {}","Best: {} · 🔥 {} {}","Mejor: {} · 🔥 {} {}"],
["Record: {} · 👤 Jij: {} · 🔥 {} {}","Record: {} · 👤 You: {} · 🔥 {} {}","Récord: {} · 👤 Tú: {} · 🔥 {} {}"],
["Dagelijks","Daily","Diario"],
["Dagelijkse puzzel","Daily puzzle","Puzzle diario"],
["Level {}","Level {}","Nivel {}"],
["Level","Level","Nivel"],
["Levels","Levels","Niveles"],
["Zetten {}","Moves {}","Movimientos {}"],
["Zetten","Moves","Movimientos"],
["Beste vandaag: {}","Best today: {}","Mejor de hoy: {}"],
["Geen zetten meer, schudden!","No moves left, shuffling!","¡No quedan movimientos, mezclando!"],
["inclusief {} bonus voor overgebleven zetten)","including {} bonus for remaining moves)","incluye {} de bonificación por los movimientos que sobran)"],
["Level gehaald!","Level complete!","¡Nivel superado!"],
["Score:","Score:","Puntos:"],
["Naar de dierentuin","To the zoo","Al zoológico"],
["Naar de kaart","To the map","Al mapa"],
["Volgend level","Next level","Siguiente nivel"],
["Bewaar je voortgang","Save your progress","Guarda tu progreso"],
["Opnieuw","Retry","Reintentar"],
["Net niet…","So close…","Casi…"],
["Je hebt geen zetten meer.","You're out of moves.","Te has quedado sin movimientos."],
["Opnieuw proberen","Try again","Intentar de nuevo"],
["{} punten in {} zetten","{} points in {} moves","{} puntos en {} movimientos"],
["punten in {} zetten","points in {} moves","puntos en {} movimientos"],
["Reeks: {} {}","Streak: {} {}","Racha: {} {}"],
["Beste van vandaag:","Today's best:","Mejor de hoy:"],
["Reeks:","Streak:","Racha:"],
["Morgen staat er een nieuwe puzzel klaar. Kun jij vandaag nog meer punten halen?","A new puzzle will be ready tomorrow. Can you score even more today?","Mañana habrá un nuevo puzzle. ¿Puedes conseguir aún más puntos hoy?"],
["Scorebord","Leaderboard","Clasificación"],
["Scorebord & leagues","Leaderboard & leagues","Clasificación y ligas"],
["Delen","Share","Compartir"],
["Gekopieerd! Plak het in je chat.","Copied! Paste it in your chat.","¡Copiado! Pégalo en tu chat."],
["Nog een keer","Play again","Otra vez"],
["Menu","Menu","Menú"],
["Plek {} van {} wereldwijd","Rank {} of {} worldwide","Puesto {} de {} en el mundo"],
["Geen verbinding, je score wordt later verstuurd","No connection, your score will be sent later","Sin conexión, tu puntuación se enviará más tarde"],
["Score versturen…","Sending score…","Enviando puntuación…"],
["Nieuw record!","New record!","¡Nuevo récord!"],
["Klaar!","Done!","¡Listo!"],
["Geen verbinding. Probeer het later opnieuw.","No connection. Please try again later.","Sin conexión. Inténtalo de nuevo más tarde."],
["Die code bestaat niet.","That code doesn't exist.","Ese código no existe."],
["Deze league zit vol (max. 50 spelers).","This league is full (max. 50 players).","Esta liga está llena (máx. 50 jugadores)."],
["Je zit al in 10 leagues.","You're already in 10 leagues.","Ya estás en 10 ligas."],
["Vul een geldige naam in.","Enter a valid name.","Escribe un nombre válido."],
["Deze score is te oud om te versturen.","This score is too old to send.","Esta puntuación es demasiado antigua para enviarla."],
["Deze score kan niet worden verstuurd.","This score can't be sent.","No se puede enviar esta puntuación."],
["Gastaccounts staan nog uit in Supabase.","Guest accounts are still switched off.","Las cuentas de invitado aún están desactivadas."],
["Inloggen als gast is niet gelukt. Probeer het later opnieuw.","Couldn't sign in as a guest. Please try again later.","No se pudo entrar como invitado. Inténtalo más tarde."],
["Opslaan is niet gelukt.","Saving didn't work.","No se pudo guardar."],
["Die code klopt niet of is verlopen. Vraag een nieuwe code aan.","That code is wrong or has expired. Request a new code.","Ese código es incorrecto o ha caducado. Pide uno nuevo."],
["Dit e-mailadres lijkt niet te kloppen.","This email address doesn't look right.","Este correo no parece correcto."],
["Even geduld: je kunt over een minuutje een nieuwe code aanvragen.","Hold on: you can request a new code in a minute.","Un momento: podrás pedir un código nuevo en un minuto."],
["Geen account gevonden met dit e-mailadres.","No account found with this email address.","No hay ninguna cuenta con este correo."],
["Er ging iets mis. Probeer het later opnieuw.","Something went wrong. Please try again later.","Algo salió mal. Inténtalo de nuevo más tarde."],
["Jouw naam","Your name","Tu nombre"],
["Zo zien anderen je op het scorebord.","This is how others see you on the leaderboard.","Así te ven los demás en la clasificación."],
["Opslaan","Save","Guardar"],
["Wereldwijd","Worldwide","Mundial"],
["Laden…","Loading…","Cargando…"],
["Vandaag","Today","Hoy"],
["Nog niemand vandaag. Wees de eerste!","Nobody yet today. Be the first!","Todavía nadie hoy. ¡Sé el primero!"],
["Speel de dagelijkse puzzel","Play the daily puzzle","Juega el puzzle diario"],
["Jouw leagues","Your leagues","Tus ligas"],
["Speel met familie of vrienden in je eigen league. Maak er een en deel de code, of doe mee met de code van iemand anders.","Play with family or friends in your own league. Create one and share the code, or join with someone else's code.","Juega con tu familia o amigos en tu propia liga. Crea una y comparte el código, o únete con el código de otra persona."],
["Nieuwe league","New league","Nueva liga"],
["Meedoen met code","Join with code","Unirse con código"],
["Deze league bestaat niet meer.","This league no longer exists.","Esta liga ya no existe."],
["Speler","Player","Jugador"],
["speler","player","jugador"],
["spelers","players","jugadores"],
["Uitnodigen","Invite","Invitar"],
["Verlaat league","Leave league","Salir de la liga"],
["League verlaten?","Leave league?","¿Salir de la liga?"],
["Je verdwijnt uit \"{}\". Je kunt later opnieuw meedoen met de code.","You'll leave \"{}\". You can rejoin later with the code.","Saldrás de \"{}\". Podrás volver a unirte con el código."],
["Ja, verlaat","Yes, leave","Sí, salir"],
["Blijven","Stay","Quedarme"],
["Een league maken mag alleen een ouder doen. Jij kunt wel meedoen met een code!","Only a parent can create a league. But you can join with a code!","Solo un adulto puede crear una liga. ¡Pero tú puedes unirte con un código!"],
["Geef je league een naam, bijvoorbeeld je familie.","Give your league a name, for example your family.","Ponle un nombre a tu liga, por ejemplo tu familia."],
["Maak league","Create league","Crear liga"],
["Die naam kan niet.","That name isn't allowed.","Ese nombre no está permitido."],
["League gemaakt!","League created!","¡Liga creada!"],
["Deel deze code met je familie en vrienden:","Share this code with your family and friends:","Comparte este código con tu familia y amigos:"],
["Later","Later","Más tarde"],
["Annuleren","Cancel","Cancelar"],
["Welkom bij","Welcome to","Te damos la bienvenida a"],
["Meedoen met een league","Join a league","Unirse a una liga"],
["Vul de code van 5 tekens in.","Enter the 5-character code.","Escribe el código de 5 caracteres."],
["Meedoen","Join","Unirse"],
["Een code heeft 5 tekens.","A code has 5 characters.","Un código tiene 5 caracteres."],
["Uitnodiging","Invitation","Invitación"],
["Je bent uitgenodigd voor een league met de code","You've been invited to a league with the code","Te han invitado a una liga con el código"],
["Meedoen?","Join?","¿Unirte?"],
["Ja, meedoen","Yes, join","Sí, unirme"],
["Nee, bedankt","No thanks","No, gracias"],
["Doe mee met mijn {}-league \"{}\"!","Join my {} league \"{}\"!","¡Únete a mi liga {} \"{}\"!"],
["Code: {}","Code: {}","Código: {}"],
["Even een vraag","Quick question","Una pregunta rápida"],
["Wat is je geboortejaar? Dan passen we het spel aan jouw leeftijd aan.","What is your birth year? Then we can adapt the game to your age.","¿Cuál es tu año de nacimiento? Así adaptamos el juego a tu edad."],
["We bewaren je geboortejaar niet.","We don't save your birth year.","No guardamos tu año de nacimiento."],
["Kies je geboortejaar","Choose your birth year","Elige tu año de nacimiento"],
["Doorgaan","Continue","Continuar"],
["Niemand ziet je antwoord.","Nobody sees your answer.","Nadie ve tu respuesta."],
["Kies je dierennaam","Choose your animal name","Elige tu nombre de animal"],
["Zo blijft je echte naam privé!","This keeps your real name private!","¡Así tu nombre real sigue siendo privado!"],
["Dit wordt mijn naam","This will be my name","Este será mi nombre"],
["Verras me","Surprise me","Sorpréndeme"],
["Welkom,","Welcome,","Hola,"],
["Welkom, {}!","Welcome, {}!","¡Hola, {}!"],
["Kies je naam","Choose your name","Elige tu nombre"],
["Dit zie je op het scorebord. Gebruik liever niet je volledige naam.","You'll see this on the leaderboard. Better not use your full name.","Esto saldrá en la clasificación. Mejor no uses tu nombre completo."],
["Toch liever een dierennaam","I'd rather have an animal name","Mejor un nombre de animal"],
["Vul een naam in.","Enter a name.","Escribe un nombre."],
["Die naam kan niet. Kies een andere.","That name isn't allowed. Choose another.","Ese nombre no está permitido. Elige otro."],
["Naam opgeslagen","Name saved","Nombre guardado"],
["Vraag een ouder","Ask a parent","Pregunta a un adulto"],
["Jij kunt gewoon blijven spelen!","You can just keep playing!","¡Tú puedes seguir jugando sin problema!"],
["Oké","OK","Vale"],
["Een e-mailadres koppelen mag alleen een ouder doen.","Only a parent can link an email address.","Solo un adulto puede vincular un correo electrónico."],
["Wil je je voortgang bewaren? Vraag een ouder om hulp.","Want to save your progress? Ask a parent for help.","¿Quieres guardar tu progreso? Pide ayuda a un adulto."],
["Inloggen","Sign in","Iniciar sesión"],
["Vul het e-mailadres van je account in. Je krijgt een code van 6 cijfers.","Enter the email address of your account. You'll get a 6-digit code.","Escribe el correo de tu cuenta. Recibirás un código de 6 cifras."],
["Vul je e-mailadres in en je levels, scores en leagues blijven bewaard, ook op een nieuwe telefoon. Geen wachtwoord nodig!","Enter your email address and your levels, scores and leagues stay saved, even on a new phone. No password needed!","Escribe tu correo y tus niveles, puntuaciones y ligas se guardan, incluso en un teléfono nuevo. ¡No necesitas contraseña!"],
["Stuur me een code","Send me a code","Envíame un código"],
["Versturen…","Sending…","Enviando…"],
["Check je mail","Check your email","Revisa tu correo"],
["We hebben een code van 6 cijfers gestuurd naar","We sent a 6-digit code to","Hemos enviado un código de 6 cifras a"],
["Plak","Paste","Pegar"],
["Controleer code","Check code","Comprobar código"],
["Niets ontvangen? Kijk ook in je spam.{}","Nothing received? Check your spam folder too.{}","¿No ha llegado nada? Mira también en el spam.{}"],
["Staat dit adres niet bij een account, dan komt er geen mail.","If this address isn't linked to an account, no email will arrive.","Si esta dirección no pertenece a ninguna cuenta, no llegará ningún correo."],
["Opnieuw sturen ({})","Send again ({})","Reenviar ({})"],
["Opnieuw sturen","Send again","Reenviar"],
["Ander e-mailadres","Different email address","Otro correo"],
["Controleren…","Checking…","Comprobando…"],
["Kopieer eerst de code uit je mail","First copy the code from your email","Primero copia el código de tu correo"],
["Houd het vakje ingedrukt en kies Plakken","Press and hold the box and choose Paste","Mantén pulsado el cuadro y elige Pegar"],
["Nieuwe code onderweg","New code on its way","Código nuevo en camino"],
["Gelukt!","Done!","¡Listo!"],
["Je voortgang is nu veilig bewaard{}.","Your progress is now safely saved{}.","Tu progreso está ahora a salvo{}."],
["en teruggehaald","and restored","y recuperado"],
["Op een nieuwe telefoon log je in met {}.","On a new phone you sign in with {}.","En un teléfono nuevo inicias sesión con {}."],
["Verder spelen","Keep playing","Seguir jugando"],
["Naam wijzigen","Change name","Cambiar nombre"],
["Andere dierennaam","Other animal name","Otro nombre de animal"],
["Eigen naam kiezen","Choose your own name","Elegir mi propio nombre"],
["Ingelogd als","Signed in as","Sesión iniciada como"],
["Je voortgang wordt bewaard. Op een nieuwe telefoon log je in met dit e-mailadres.","Your progress is saved. On a new phone you sign in with this email address.","Tu progreso se guarda. En un teléfono nuevo inicias sesión con este correo."],
["Je speelt als","You're playing as","Juegas como"],
["Account","Account","Cuenta"],
["Bewaar mijn voortgang","Save my progress","Guardar mi progreso"],
["Ik heb al een account","I already have an account","Ya tengo una cuenta"],
["Heb je al een account? Inloggen","Already have an account? Sign in","¿Ya tienes cuenta? Inicia sesión"],
["Uitloggen","Sign out","Cerrar sesión"],
["Uitloggen?","Sign out?","¿Cerrar sesión?"],
["Je voortgang blijft bewaard in je account.","Your progress stays saved in your account.","Tu progreso sigue guardado en tu cuenta."],
["Ja, uitloggen","Yes, sign out","Sí, cerrar sesión"],
["Account verwijderen","Delete account","Eliminar cuenta"],
["Account verwijderen?","Delete account?","¿Eliminar cuenta?"],
["Je naam, scores, leagues en voortgang worden definitief verwijderd. Dit kan niet ongedaan worden gemaakt.","Your name, scores, leagues and progress will be permanently deleted. This can't be undone.","Tu nombre, puntuaciones, ligas y progreso se borrarán para siempre. No se puede deshacer."],
["Ja, alles verwijderen","Yes, delete everything","Sí, borrar todo"],
["Sluiten","Close","Cerrar"],
["(nog geen)","(none yet)","(ninguno aún)"],
["dag","day","día"],
["dagen","days","días"],
["binnenkort","soon","pronto"],
["De Zebra's","The Zebras","Las Cebras"],
["De Zebra-weide","Zebra Meadow","Prado de las Cebras"],
["De Lama's","The Llamas","Las Llamas"],
["De Lama-bergen","Llama Mountains","Montañas de las Llamas"],
["De Pinguïns","The Penguins","Los Pingüinos"],
["De Panda's","The Pandas","Los Pandas"],
["De Flamingo's","The Flamingos","Los Flamencos"],
["Zebra","Zebra","Cebra"],
["Giraf","Giraffe","Jirafa"],
["Nijlpaard","Hippo","Hipopótamo"],
["Olifant","Elephant","Elefante"],
["Neushoorn","Rhino","Rinoceronte"],
["Luipaard","Leopard","Leopardo"],
["Gorilla","Gorilla","Gorila"],
["Leeuw","Lion","León"],
["Lama","Llama","Llama"],
["Alpaca","Alpaca","Alpaca"],
["Condor","Condor","Cóndor"],
["Andesflamingo","Andean flamingo","Flamenco andino"],
["Brilbeer","Spectacled bear","Oso de anteojos"],
["Viscacha","Viscacha","Vizcacha"],
["Vicuña","Vicuña","Vicuña"],
["Poema","Puma","Puma"],
["Eenhoorn","Unicorn","Unicornio"],
["Draak","Dragon","Dragón"],
["Elke zebra heeft unieke strepen, net als jouw vingerafdruk.","Every zebra has unique stripes, just like your fingerprint.","Cada cebra tiene rayas únicas, igual que tu huella dactilar."],
["Een giraf heeft net als jij zeven nekwervels, maar de zijne zijn veel langer.","A giraffe has seven neck bones just like you, but its bones are much longer.","Una jirafa tiene siete vértebras en el cuello como tú, pero las suyas son mucho más largas."],
["Een nijlpaard kan zijn bek ongelooflijk wijd opendoen.","A hippo can open its mouth incredibly wide.","Un hipopótamo puede abrir la boca increíblemente grande."],
["Olifanten leven in familiegroepen onder leiding van de oudste moeder.","Elephants live in family groups led by the oldest mother.","Los elefantes viven en grupos familiares dirigidos por la madre más vieja."],
["De hoorn van een neushoorn is gemaakt van hetzelfde spul als jouw nagels.","A rhino's horn is made of the same stuff as your fingernails.","El cuerno de un rinoceronte está hecho de lo mismo que tus uñas."],
["Een luipaard sleept zijn eten soms omhoog in een boom.","A leopard sometimes drags its food up into a tree.","A veces un leopardo sube su comida a un árbol."],
["Gorilla's leven in een groep onder leiding van een zilverrug.","Gorillas live in a group led by a silverback.","Los gorilas viven en un grupo dirigido por un espalda plateada."],
["De brul van een leeuw is tot wel 8 kilometer ver te horen.","A lion's roar can be heard up to 8 kilometres away.","El rugido de un león se oye hasta a 8 kilómetros."],
["Lama's zijn nieuwsgierig, dragen zware pakken in de bergen en kunnen spugen als ze boos zijn.","Llamas are curious, carry heavy loads in the mountains and can spit when they're angry.","Las llamas son curiosas, cargan bultos pesados en las montañas y pueden escupir cuando se enfadan."],
["De wol van een alpaca is zacht en warm. Er worden truien van gemaakt.","Alpaca wool is soft and warm. Sweaters are made from it.","La lana de la alpaca es suave y cálida. Se hacen jerséis con ella."],
["De Andescondor is een van de grootste vliegende vogels ter wereld.","The Andean condor is one of the biggest flying birds in the world.","El cóndor andino es una de las aves voladoras más grandes del mundo."],
["Een Andesflamingo is roze door de algen die hij eet, en hij woont op zoutmeren hoog in de bergen.","An Andean flamingo is pink from the algae it eats, and it lives on salt lakes high in the mountains.","Un flamenco andino es rosa por las algas que come, y vive en lagos salados en lo alto de las montañas."],
["De brilbeer is de enige beer die in Zuid-Amerika leeft.","The spectacled bear is the only bear that lives in South America.","El oso de anteojos es el único oso que vive en Sudamérica."],
["Een viscacha is een knaagdier, familie van de chinchilla, en woont tussen de rotsen in de bergen.","A viscacha is a rodent, related to the chinchilla, and lives among the rocks in the mountains.","Una vizcacha es un roedor, pariente de la chinchilla, y vive entre las rocas de las montañas."],
["De vicuña is de kleinste kameelachtige en heeft heel fijne wol.","The vicuña is the smallest camel relative and has very fine wool.","La vicuña es el camélido más pequeño y tiene una lana muy fina."],
["Een poema kan heel hoog springen en leeft in bergen, bossen en woestijnen, van Canada tot Zuid-Amerika.","A puma can jump really high and lives in mountains, forests and deserts, from Canada to South America.","Un puma puede saltar muy alto y vive en montañas, bosques y desiertos, desde Canadá hasta Sudamérica."],
["Eenhoorns bestaan alleen in sprookjes... en in Yippo!","Unicorns only exist in fairy tales... and in Yippo!","Los unicornios solo existen en los cuentos... ¡y en Yippo!"],
["Draken spuwen vuur en zijn dol op een lange reeks.","Dragons breathe fire and love a long streak.","Los dragones echan fuego y adoran una racha larga."],
["Planteneter","Plant eater","Herbívoro"],
["Vooral planten","Mostly plants","Sobre todo plantas"],
["Vleeseter","Meat eater","Carnívoro"],
["Aaseter","Scavenger","Carroñero"],
["Algen en kleine diertjes","Algae and tiny animals","Algas y animalitos"],
["Savanne","Savanna","Sabana"],
["Savanne en bos","Savanna and forest","Sabana y bosque"],
["Bos en savanne","Forest and savanna","Bosque y sabana"],
["Regenwoud","Rainforest","Selva tropical"],
["Bergbos","Mountain forest","Bosque de montaña"],
["Rotsen","Rocks","Rocas"],
["Hooggebergte","High mountains","Alta montaña"],
["Zoutmeren in de bergen","Salt lakes in the mountains","Lagos salados en las montañas"],
["Rivieren en meren","Rivers and lakes","Ríos y lagos"],
["Bijna overal","Almost everywhere","Casi en todas partes"],
["Oost- en zuidelijk Afrika","East and southern Africa","África oriental y meridional"],
["Afrika, onder de Sahara","Africa, south of the Sahara","África, al sur del Sáhara"],
["Afrika onder de Sahara, plus een klein gebied in India","Africa south of the Sahara, plus a small area in India","África al sur del Sáhara, más una pequeña zona en la India"],
["Afrika en Azië (twee soorten)","Africa and Asia (two species)","África y Asia (dos especies)"],
["Zuidelijk Afrika en Zuid-Azië (de soort verschilt)","Southern Africa and South Asia (the species differs)","África meridional y Asia meridional (la especie varía)"],
["Afrika en grote delen van Azië","Africa and large parts of Asia","África y gran parte de Asia"],
["Midden-Afrika","Central Africa","África central"],
["Andes in Zuid-Amerika","Andes in South America","Los Andes en Sudamérica"],
["Andes en de kust van Zuid-Amerika","Andes and the coast of South America","Los Andes y la costa de Sudamérica"],
["Hoge Andes","High Andes","Altos Andes"],
["Noordelijke Andes","Northern Andes","Andes del norte"],
["Noord-, Midden- en Zuid-Amerika","North, Central and South America","Norteamérica, Centroamérica y Sudamérica"],
["Een gehouden dier: mensen fokken lama's al heel lang.","A farm animal: people have kept llamas for a very long time.","Un animal doméstico: la gente cría llamas desde hace mucho tiempo."],
["Een gehouden dier: mensen fokken alpaca's voor hun wol.","A farm animal: people keep alpacas for their wool.","Un animal doméstico: la gente cría alpacas por su lana."],
["Afrika","Africa","África"],
["Azië","Asia","Asia"],
["Europa","Europe","Europa"],
["Noord-Amerika","North America","Norteamérica"],
["Zuid-Amerika","South America","Sudamérica"],
["Oceanië","Oceania","Oceanía"],
["Mijn wereldkaart","My world map","Mi mapa del mundo"],
["Werelddelen ontdekt: {} / {}","Continents discovered: {} / {}","Continentes descubiertos: {} / {}"],
["Verzamel meer dieren om nieuwe werelddelen te ontdekken!","Collect more animals to discover new continents!","¡Consigue más animales para descubrir nuevos continentes!"],
["Kaart laden…","Loading map…","Cargando mapa…"],
["Leeft alleen in verhalen","Only lives in stories","Solo vive en los cuentos"],
["Mooi!","Nice!","¡Genial!"],
["Ongeveer: de kaart kleurt hele landen.{}","Roughly: the map colours whole countries.{}","Aproximado: el mapa colorea países enteros.{}"],
["Verzameld bij level {}","Collected at level {}","Conseguido en el nivel {}"],
["Verzameld bij level","Collected at level","Conseguido en el nivel"],
["Fantasiedier","Fantasy animal","Animal fantástico"],
["Bronnen","Sources","Fuentes"],
["De dierenfeiten zijn in eigen woorden geschreven op basis van Wikipedia (CC BY-SA) en gegevens van IUCN. De landenkaart komt van Natural Earth (publiek domein). Leefgebieden zijn een grove indicatie.","The animal facts are written in our own words based on Wikipedia (CC BY-SA) and data from IUCN. The country map comes from Natural Earth (public domain). Habitats are a rough indication.","Los datos de los animales están escritos con nuestras propias palabras a partir de Wikipedia (CC BY-SA) y datos de la UICN. El mapa de países procede de Natural Earth (dominio público). Los hábitats son solo una indicación aproximada."],
["Hier leeft de {}","Where the {} lives","Dónde vive: {}"],
["Mijn dierentuin · {} / {}","My zoo · {} / {}","Mi zoológico · {} / {}"],
["Fantasiedieren · {}/{}","Fantasy animals · {}/{}","Animales fantásticos · {}/{}"],
["opent vrijdag 18:00 · {}","opens Friday 18:00 · {}","abre el viernes a las 18:00 · {}"],
["Speel level {} om de {} te verzamelen.","Play level {} to collect the {}.","Juega el nivel {} para conseguir: {}."],
["Speel de dagelijkse puzzel {} om de {} te krijgen.","Play the daily puzzle {} to get the {}.","Juega el puzzle diario {} para conseguir: {}."],
["Nog niet verzameld","Not collected yet","Aún no conseguido"],
["NIEUW DIER!","NEW ANIMAL!","¡ANIMAL NUEVO!"],
["NIEUW!","NEW!","¡NUEVO!"],
["Mijn dierentuin","My zoo","Mi zoológico"],
["Bekijk je dierentuin","See your zoo","Mira tu zoológico"],
["{} {} op rij","{} {} in a row","{} {} seguidos"],
["nog {}d {}u","{}d {}h left","quedan {}d {}h"],
["nog {}u {}m","{}h {}m left","quedan {}h {}m"],
["Wereld {}, {}, is open! {}","World {}, {}, is open! {}","¡El mundo {}, {}, está abierto! {}"],
["Wereld {} is open! {}","World {} is open! {}","¡El mundo {} está abierto! {}"],
["{} · tik op ▶ bovenin","{} · tap ▶ at the top","{} · toca ▶ arriba"],
["Wereld {}: {}","World {}: {}","Mundo {}: {}"],
["Wereld {} · {} · {}/{}","World {} · {} · {}/{}","Mundo {} · {} · {}/{}"],
["Wereld {} gehaald!","World {} complete!","¡Mundo {} superado!"],
["Nieuw dier: {}!","New animal: {}!","¡Animal nuevo: {}!"],
["Hangbrug!","Suspension bridge!","¡Puente colgante!"],
["Jij bent hier!","You are here!","¡Estás aquí!"],
["Volgend dier bij level {}: {}","Next animal at level {}: {}","Siguiente animal en el nivel {}: {}"],
["Alle dieren verzameld!","All animals collected!","¡Todos los animales conseguidos!"],
["Speel level {}","Play level {}","Jugar nivel {}"],
["Speel eerst level {}","First play level {}","Primero juega el nivel {}"],
["De volgende wereld komt binnenkort. Kom vrijdag om 18:00 terug!","The next world is coming soon. Come back on Friday at 18:00!","El siguiente mundo llega pronto. ¡Vuelve el viernes a las 18:00!"],
["Verzamel je eerste dier bij level 5!","Collect your first animal at level 5!","¡Consigue tu primer animal en el nivel 5!"],
["Beste: {}","Best: {}","Mejor: {}"],
["Nieuwe puzzel vandaag","New puzzle today","Puzzle nuevo hoy"],
["Level {} · {} {}","Level {} · {} {}","Nivel {} · {} {}"],
["Geluid","Sound","Sonido"],
["Geluid uit","Sound off","Sonido apagado"],
["Geluid aan","Sound on","Sonido encendido"],
["Druk nogmaals op terug om af te sluiten","Press back again to exit","Pulsa atrás otra vez para salir"],
["Zo speel je","How to play","Cómo se juega"],
["Sleep een dier naar een buur (of tik er twee aan). Maak","Drag an animal to a neighbour (or tap two). Make","Arrastra un animal a su vecino (o toca dos). Forma"],
["3 of meer gelijke","3 or more matching","3 o más iguales"],
["dieren op een rij, dan verdwijnen ze!","animals in a row and they disappear!","animales en fila y ¡desaparecen!"],
["4 op een rij","4 in a row","4 en fila"],
["wist een hele rij of kolom (pijltje!)","clears a whole row or column (arrow!)","borra una fila o columna entera (¡flecha!)"],
["2×2 vierkantje","2×2 square","cuadrado de 2×2"],
["wist een gebied van 3×3","clears a 3×3 area","borra una zona de 3×3"],
["L- of T-vorm","L or T shape","forma de L o T"],
["wist een rij én kolom","clears a row and a column","borra una fila y una columna"],
["5 op een rij","5 in a row","5 en fila"],
["wissel hem met een dier en alle dieren van die soort verdwijnen","swap it with an animal and all animals of that kind disappear","cámbialo con un animal y desaparecen todos los de ese tipo"],
["Wissel een speciaal dier met een buur, of tik hem twee keer, om hem te activeren. Twee speciale dieren naast elkaar wisselen geeft een mega-effect!","Swap a special animal with a neighbour, or tap it twice, to activate it. Swapping two special animals next to each other gives a mega effect!","Cambia un animal especial con un vecino, o tócalo dos veces, para activarlo. ¡Cambiar dos animales especiales juntos da un efecto mega!"],
["haalt één dier weg, 🔀 schudt het bord. 🧊 ijs verdwijnt als je er een setje op maakt.","removes one animal, 🔀 shuffles the board. 🧊 ice disappears when you make a match on it.","quita un animal, 🔀 mezcla el tablero. 🧊 el hielo desaparece cuando haces un grupo encima."],
["Begrepen!","Got it!","¡Entendido!"],
["Dagelijks (beste: {})","Daily (best: {})","Diario (mejor: {})"],
["Naar menu","To menu","Al menú"],
["Pauze","Pause","Pausa"],
["Even wachten…","Just a moment…","Un momento…"],
["Tik op een dier om het weg te halen","Tap an animal to remove it","Toca un animal para quitarlo"],
["Wissel dieren, maak setjes, bouw een dierentuin vol combo's!","Swap animals, make matches, build a zoo full of combos!","¡Cambia animales, haz combinaciones y construye un zoológico lleno de combos!"],
["Spelen","Play","Jugar"],
["Hoe werkt het?","How does it work?","¿Cómo funciona?"],
["Leagues","Leagues","Ligas"],
["Met vrienden","With friends","Con amigos"],
["Menu","Menu","Menú"],
["Kies een level","Choose a level","Elige un nivel"],
["Terug","Back","Atrás"],
["Wereld","World","Mundo"],
["Mijn leagues","My leagues","Mis ligas"],
["Naam","Name","Nombre"],
["Taal","Language","Idioma"],
["Kies je taal","Choose your language","Elige tu idioma"],
];
const LANGS={nl:'Nederlands',en:'English',es:'Español'};
const IDX={en:1,es:2};
let lang='nl',obs=null;
const maps={en:new Map(),es:new Map()},pats={en:[],es:[]},cache={en:new Map(),es:new Map()},miss=new Set();
const esc=s=>s.replace(/[.*+?^${}()|[\]\\]/g,'\\$&');
ROWS.forEach(r=>{['en','es'].forEach(L=>{
  const nl=r[0],to=r[IDX[L]];
  if(nl.indexOf('{}')>=0){
    const parts=nl.split('{}');
    pats[L].push({re:new RegExp('^'+parts.map(esc).join('(.*?)')+'$','s'),to,len:nl.length});
  }else maps[L].set(nl,to);
})});
['en','es'].forEach(L=>pats[L].sort((a,b)=>b.len-a.len));
const PRE=/^[^\p{L}\p{N}{]*/u,SUF=/[\s\p{Extended_Pictographic}\uFE0F\u200D▶◀→←↻]*$/u;
function cap(L,x){
  const m=maps[L],w=/^(\s*)([\s\S]*?)(\s*)$/.exec(x);
  if(w[1]||w[3])return w[1]+cap(L,w[2])+w[3];
  if(m.has(x))return m.get(x);
  const c=x.charAt(0).toUpperCase()+x.slice(1);
  if(c!==x&&m.has(c)){const t=m.get(c);return t.charAt(0).toLowerCase()+t.slice(1)}
  return x;
}
function core(L,c){
  const m=maps[L];
  if(m.has(c))return m.get(c);
  const ps=pats[L];
  for(let i=0;i<ps.length;i++){
    const r=ps[i],mm=r.re.exec(c);
    if(mm){let k=0;return r.to.replace(/\{(\d?)\}/g,(_,n)=>cap(L,mm[n?+n:++k]||''))}
  }
  return null;
}
function tr(s){
  if(lang==='nl'||!s)return s;
  const L=lang,ca=cache[L];
  if(ca.has(s))return ca.get(s);
  let out=s;
  if(/\p{L}{2}/u.test(s)){
    const pre=PRE.exec(s)[0],rest=s.slice(pre.length),suf=SUF.exec(rest)[0],c=rest.slice(0,rest.length-suf.length);
    const t=c&&core(L,c);
    if(t!==null&&t!==''&&t!==undefined)out=pre+t+suf;
    else if(c&&!/^[\W\d_]*$/u.test(c))miss.add(s);
  }
  ca.set(s,out);return out;
}
function trLines(s){return lang==='nl'?s:String(s).split('\n').map(tr).join('\n')}
/* DOM: bewaar de Nederlandse tekst per node, zodat wisselen van taal altijd vanaf het origineel vertaalt */
const nodes=new WeakMap();
function doText(n){
  const v=n.nodeValue,rec=nodes.get(n);
  const o=rec&&rec.t===v?rec.o:v;
  const t=lang==='nl'?o:tr(o);
  if(t!==v)n.nodeValue=t;
  nodes.set(n,{o,t});
}
const ATTRS=['placeholder','title','aria-label'];
function doAttrs(el){
  const rec=el.__i18n||(el.__i18n={});
  for(const a of ATTRS){
    const v=el.getAttribute(a);if(v===null)continue;
    const r=rec[a],o=r&&r.t===v?r.o:v,t=lang==='nl'?o:tr(o);
    if(t!==v)el.setAttribute(a,t);
    rec[a]={o,t};
  }
}
function walk(root){
  if(root.nodeType===3){doText(root);return}
  if(root.nodeType!==1)return;
  if(root.tagName==='SCRIPT'||root.tagName==='STYLE')return;
  doAttrs(root);
  const w=document.createTreeWalker(root,NodeFilter.SHOW_TEXT|NodeFilter.SHOW_ELEMENT,{acceptNode:n=>n.nodeType===1&&(n.tagName==='SCRIPT'||n.tagName==='STYLE')?NodeFilter.FILTER_REJECT:NodeFilter.FILTER_ACCEPT});
  let n;while((n=w.nextNode())){if(n.nodeType===3)doText(n);else doAttrs(n)}
}
function start(){
  if(obs||lang==='nl')return;
  obs=new MutationObserver(recs=>{
    for(const r of recs){
      if(r.type==='characterData')doText(r.target);
      else if(r.type==='attributes')doAttrs(r.target);
      else r.addedNodes.forEach(walk);
    }
  });
  obs.observe(document.body,{childList:true,subtree:true,characterData:true,attributes:true,attributeFilter:ATTRS});
}
function setLang(l){
  if(!LANGS[l])l='nl';
  lang=l;document.documentElement.lang=l;
  if(obs){obs.disconnect();obs=null}
  if(document.body){walk(document.body);start()}
}
window.I18N={LANGS,get lang(){return lang},setLang,tr,trLines,miss:()=>[...miss],detect(){
  const n=String((navigator.languages&&navigator.languages[0])||navigator.language||'en').toLowerCase();
  return n.startsWith('nl')?'nl':n.startsWith('es')?'es':'en';
}};
})();
