// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"bark.ogg": "ladrar", "beat.ogg": "bater", "beg.ogg": "implorar", "bite.ogg": "morder", "blink.ogg": "piscar", "boil.ogg": "ferver", "break.ogg": "despedaçar", "call.ogg": "chamar", "catch.ogg": "apanhar", "chat.ogg": "conversar", "chop.ogg": "cortar", "clap.ogg": "bater palmas", "clean.ogg": "tomar banho", "cook.ogg": "cozinhar", "cough.ogg": "tossir", "crawl.ogg": "gatinhar", "croak.ogg": "coaxar", "cry.ogg": "chorar", "cut.ogg": "cortar", "dig.ogg": "cavar", "draw.ogg": "desenhar", "dream.ogg": "sonhar", "to_drink.ogg": "beber", "drive.ogg": "conduzir", "drool.ogg": "salivar", "dry.ogg": "secar", "eat.ogg": "comer", "feed.ogg": "alimentar", "fall.ogg": "cair", "fetch.ogg": "buscar", "find.ogg": "encontrar", "float.ogg": "flutuar", "fly.ogg": "voar", "freeze.ogg": "congelar", "growl.ogg": "rosnar", "hatch.ogg": "chocar", "hear.ogg": "ouvir", "howl.ogg": "uivar", "hug.ogg": "abraçar", "jump.ogg": "saltar", "kiss.ogg": "beijar", "kneel.ogg": "ajoelhar", "knit.ogg": "tricotar", "lick.ogg": "lamber", "look.ogg": "olhar", "meet.ogg": "travar conhecimento", "nap.ogg": "dormitar", "peck.ogg": "bicar", "play.ogg": "brincar", "plow.ogg": "lavrar", "pounce.ogg": "atacar", "pull.ogg": "puxar", "quarrel.ogg": "discutir", "read.ogg": "ler", "rip.ogg": "rasgar", "rise.ogg": "subir", "run.ogg": "correr", "scare.ogg": "assustar", "scratch.ogg": "arranhar", "scream.ogg": "gritar", "scribble.ogg": "rabiscar", "see.ogg": "ver", "shake.ogg": "chocalhar", "shave.ogg": "tosquiar", "sing.ogg": "cantar", "sip.ogg": "sorver", "sit.ogg": "sentar", "slam.ogg": "marcar", "sleep.ogg": "dormir", "smell.ogg": "cheirar", "smooch.ogg": "beijocar", "sniff.ogg": "farejar", "speak.ogg": "falar", "spill.ogg": "entornar", "splash.ogg": "salpicar", "spray.ogg": "aspergir", "spread.ogg": "espalhar", "spring.ogg": "pular", "squat.ogg": "agachar", "stare.ogg": "fitar", "sting.ogg": "aferroar", "stitch.ogg": "coser", "stop.ogg": "parar", "stretch.ogg": "esticar", "study.ogg": "estudar", "teach.ogg": "ensinar", "tear.ogg": "rasgar", "think.ogg": "pensar", "touch.ogg": "tocar", "wag.ogg": "abanar", "walk.ogg": "andar", "wash.ogg": "lavar", "whisper.ogg": "sussurrar", "win.ogg": "ganhar", "write.ogg": "escrever"}
    property var incidence:{"m": ["beg.ogg", "bite.ogg", "call.ogg", "clap.ogg", "clean.ogg", "eat.ogg", "feed.ogg", "lick.ogg", "meet.ogg", "nap.ogg", "slam.ogg", "sleep.ogg"], "r": ["bark.ogg", "beat.ogg", "beg.ogg", "bite.ogg", "blink.ogg", "boil.ogg", "break.ogg", "call.ogg", "catch.ogg", "chat.ogg", "chop.ogg", "clap.ogg", "clean.ogg", "cook.ogg", "cough.ogg", "crawl.ogg", "croak.ogg", "cry.ogg", "cut.ogg", "dig.ogg", "draw.ogg", "dream.ogg", "to_drink.ogg", "drive.ogg", "drool.ogg", "dry.ogg", "eat.ogg", "feed.ogg", "fall.ogg", "fetch.ogg", "find.ogg", "float.ogg", "fly.ogg", "freeze.ogg", "growl.ogg", "hatch.ogg", "hear.ogg", "howl.ogg", "hug.ogg", "jump.ogg", "kiss.ogg", "kneel.ogg", "knit.ogg", "lick.ogg", "look.ogg", "meet.ogg", "nap.ogg", "peck.ogg", "play.ogg", "plow.ogg", "pounce.ogg", "pull.ogg", "quarrel.ogg", "read.ogg", "rip.ogg", "rise.ogg", "run.ogg", "scare.ogg", "scratch.ogg", "scream.ogg", "scribble.ogg", "see.ogg", "shake.ogg", "shave.ogg", "sing.ogg", "sip.ogg", "sit.ogg", "slam.ogg", "sleep.ogg", "smell.ogg", "smooch.ogg", "sniff.ogg", "speak.ogg", "spill.ogg", "splash.ogg", "spray.ogg", "spread.ogg", "spring.ogg", "squat.ogg", "stare.ogg", "sting.ogg", "stitch.ogg", "stop.ogg", "stretch.ogg", "study.ogg", "teach.ogg", "tear.ogg", "think.ogg", "touch.ogg", "wag.ogg", "walk.ogg", "wash.ogg", "whisper.ogg", "win.ogg", "write.ogg"], "u": ["drive.ogg", "fetch.ogg", "float.ogg", "hear.ogg", "howl.ogg", "pull.ogg", "quarrel.ogg", "rise.ogg", "scare.ogg", "shave.ogg", "spring.ogg", "study.ogg", "whisper.ogg"], "q": ["shave.ogg"], "x": ["croak.ogg", "pull.ogg"], "t": ["beat.ogg", "chop.ogg", "clap.ogg", "clean.ogg", "cough.ogg", "crawl.ogg", "cut.ogg", "feed.ogg", "find.ogg", "float.ogg", "jump.ogg", "knit.ogg", "meet.ogg", "nap.ogg", "pounce.ogg", "quarrel.ogg", "scare.ogg", "scream.ogg", "shave.ogg", "sing.ogg", "sit.ogg", "spill.ogg", "stare.ogg", "stretch.ogg", "study.ogg", "touch.ogg"], "d": ["bark.ogg", "bite.ogg", "break.ogg", "draw.ogg", "drive.ogg", "nap.ogg", "quarrel.ogg", "sleep.ogg", "study.ogg", "walk.ogg"], "i": ["beg.ogg", "blink.ogg", "cook.ogg", "cough.ogg", "crawl.ogg", "drive.ogg", "drool.ogg", "feed.ogg", "fall.ogg", "hear.ogg", "howl.ogg", "kiss.ogg", "knit.ogg", "meet.ogg", "nap.ogg", "peck.ogg", "play.ogg", "quarrel.ogg", "rise.ogg", "scream.ogg", "scribble.ogg", "shave.ogg", "sleep.ogg", "smell.ogg", "smooch.ogg", "splash.ogg", "spray.ogg", "stare.ogg", "stretch.ogg", "teach.ogg"], "ç": ["break.ogg", "hug.ogg"], "l": ["bark.ogg", "beg.ogg", "clap.ogg", "drool.ogg", "feed.ogg", "float.ogg", "freeze.ogg", "jump.ogg", "kneel.ogg", "lick.ogg", "look.ogg", "plow.ogg", "read.ogg", "shake.ogg", "speak.ogg", "splash.ogg", "spread.ogg", "spring.ogg", "wash.ogg"], "j": ["kiss.ogg", "kneel.ogg", "smooch.ogg", "sniff.ogg"], "a": ["bark.ogg", "beat.ogg", "beg.ogg", "blink.ogg", "break.ogg", "call.ogg", "catch.ogg", "chat.ogg", "chop.ogg", "clap.ogg", "clean.ogg", "cook.ogg", "crawl.ogg", "croak.ogg", "cry.ogg", "cut.ogg", "dig.ogg", "draw.ogg", "dream.ogg", "drool.ogg", "dry.ogg", "feed.ogg", "fall.ogg", "fetch.ogg", "find.ogg", "float.ogg", "fly.ogg", "freeze.ogg", "growl.ogg", "hatch.ogg", "howl.ogg", "hug.ogg", "jump.ogg", "kiss.ogg", "kneel.ogg", "knit.ogg", "lick.ogg", "look.ogg", "meet.ogg", "nap.ogg", "peck.ogg", "play.ogg", "plow.ogg", "pounce.ogg", "pull.ogg", "rip.ogg", "scare.ogg", "scratch.ogg", "scream.ogg", "scribble.ogg", "shake.ogg", "shave.ogg", "sing.ogg", "sit.ogg", "slam.ogg", "smell.ogg", "smooch.ogg", "sniff.ogg", "speak.ogg", "spill.ogg", "splash.ogg", "spray.ogg", "spread.ogg", "spring.ogg", "squat.ogg", "stare.ogg", "sting.ogg", "stop.ogg", "stretch.ogg", "study.ogg", "teach.ogg", "tear.ogg", "think.ogg", "touch.ogg", "wag.ogg", "walk.ogg", "wash.ogg", "whisper.ogg", "win.ogg"], "p": ["beg.ogg", "blink.ogg", "break.ogg", "catch.ogg", "clap.ogg", "pull.ogg", "splash.ogg", "spray.ogg", "spread.ogg", "spring.ogg", "stop.ogg", "think.ogg"], "h": ["call.ogg", "catch.ogg", "clean.ogg", "cook.ogg", "crawl.ogg", "cry.ogg", "draw.ogg", "dream.ogg", "hatch.ogg", "kneel.ogg", "look.ogg", "meet.ogg", "scratch.ogg", "shake.ogg", "smell.ogg", "spread.ogg", "squat.ogg", "win.ogg"], "n": ["catch.ogg", "chat.ogg", "clean.ogg", "cook.ogg", "crawl.ogg", "draw.ogg", "dream.ogg", "drive.ogg", "feed.ogg", "find.ogg", "freeze.ogg", "growl.ogg", "meet.ogg", "play.ogg", "scratch.ogg", "sing.ogg", "sit.ogg", "spill.ogg", "teach.ogg", "think.ogg", "wag.ogg", "walk.ogg", "win.ogg"], "g": ["crawl.ogg", "freeze.ogg", "rip.ogg", "scream.ogg", "spray.ogg", "squat.ogg", "tear.ogg", "win.ogg"], "z": ["cook.ogg", "drive.ogg"], "s": ["blink.ogg", "break.ogg", "chat.ogg", "clap.ogg", "cough.ogg", "draw.ogg", "dream.ogg", "drool.ogg", "dry.ogg", "fetch.ogg", "growl.ogg", "jump.ogg", "quarrel.ogg", "rip.ogg", "rise.ogg", "scare.ogg", "scribble.ogg", "shave.ogg", "sip.ogg", "sit.ogg", "splash.ogg", "spray.ogg", "spread.ogg", "stitch.ogg", "stretch.ogg", "study.ogg", "teach.ogg", "tear.ogg", "think.ogg", "whisper.ogg", "write.ogg"], "o": ["beg.ogg", "bite.ogg", "chat.ogg", "chop.ogg", "clean.ogg", "cook.ogg", "cough.ogg", "croak.ogg", "cry.ogg", "cut.ogg", "dream.ogg", "drive.ogg", "eat.ogg", "find.ogg", "fly.ogg", "freeze.ogg", "growl.ogg", "hatch.ogg", "hear.ogg", "kneel.ogg", "knit.ogg", "look.ogg", "meet.ogg", "nap.ogg", "run.ogg", "shake.ogg", "shave.ogg", "sip.ogg", "sleep.ogg", "smooch.ogg", "spill.ogg", "sting.ogg", "stitch.ogg", "touch.ogg"], "c": ["blink.ogg", "call.ogg", "chat.ogg", "chop.ogg", "cook.ogg", "croak.ogg", "cry.ogg", "cut.ogg", "dig.ogg", "drive.ogg", "dry.ogg", "eat.ogg", "fall.ogg", "fetch.ogg", "find.ogg", "freeze.ogg", "hatch.ogg", "knit.ogg", "meet.ogg", "peck.ogg", "play.ogg", "pounce.ogg", "quarrel.ogg", "run.ogg", "scribble.ogg", "shake.ogg", "sing.ogg", "slam.ogg", "smell.ogg", "smooch.ogg", "splash.ogg", "squat.ogg", "stitch.ogg", "stretch.ogg", "touch.ogg", "write.ogg"], "f": ["boil.ogg", "float.ogg", "sniff.ogg", "speak.ogg", "stare.ogg", "sting.ogg"], "e": ["beat.ogg", "bite.ogg", "boil.ogg", "break.ogg", "chat.ogg", "clap.ogg", "draw.ogg", "to_drink.ogg", "dry.ogg", "eat.ogg", "feed.ogg", "find.ogg", "freeze.ogg", "kiss.ogg", "kneel.ogg", "lick.ogg", "meet.ogg", "read.ogg", "run.ogg", "see.ogg", "sip.ogg", "sit.ogg", "smell.ogg", "smooch.ogg", "sniff.ogg", "spill.ogg", "spray.ogg", "spread.ogg", "sting.ogg", "stitch.ogg", "stretch.ogg", "study.ogg", "teach.ogg", "think.ogg", "write.ogg"], "b": ["beat.ogg", "clap.ogg", "clean.ogg", "to_drink.ogg", "fetch.ogg", "hug.ogg", "kiss.ogg", "lick.ogg", "peck.ogg", "play.ogg", "rise.ogg", "scribble.ogg", "smooch.ogg", "wag.ogg"], "v": ["boil.ogg", "chat.ogg", "dig.ogg", "drool.ogg", "fly.ogg", "hear.ogg", "howl.ogg", "meet.ogg", "plow.ogg", "see.ogg", "sip.ogg", "wash.ogg", "write.ogg"]}
    property var counts:{"bark.ogg": {"l": 1, "a": 2, "d": 1, "r": 2}, "beat.ogg": {"b": 1, "a": 1, "t": 1, "e": 1, "r": 1}, "beg.ogg": {"i": 1, "m": 1, "p": 1, "l": 1, "o": 1, "r": 2, "a": 1}, "bite.ogg": {"m": 1, "o": 1, "r": 2, "d": 1, "e": 1}, "blink.ogg": {"p": 1, "i": 1, "s": 1, "c": 1, "a": 1, "r": 1}, "boil.ogg": {"f": 1, "e": 2, "r": 2, "v": 1}, "break.ogg": {"d": 2, "e": 2, "s": 1, "p": 1, "a": 2, "ç": 1, "r": 1}, "call.ogg": {"c": 1, "h": 1, "a": 2, "m": 1, "r": 1}, "catch.ogg": {"a": 3, "p": 1, "n": 1, "h": 1, "r": 1}, "chat.ogg": {"c": 1, "o": 1, "n": 1, "v": 1, "e": 1, "r": 2, "s": 1, "a": 1}, "chop.ogg": {"c": 1, "o": 1, "r": 2, "t": 1, "a": 1}, "clap.ogg": {"b": 1, "a": 3, "t": 1, "e": 1, "r": 1, "p": 1, "l": 1, "m": 1, "s": 1}, "clean.ogg": {"t": 1, "o": 2, "m": 1, "a": 2, "r": 1, "b": 1, "n": 1, "h": 1}, "cook.ogg": {"c": 1, "o": 1, "z": 1, "i": 1, "n": 1, "h": 1, "a": 1, "r": 1}, "cough.ogg": {"t": 1, "o": 1, "s": 2, "i": 1, "r": 1}, "crawl.ogg": {"g": 1, "a": 2, "t": 1, "i": 1, "n": 1, "h": 1, "r": 1}, "croak.ogg": {"c": 1, "o": 1, "a": 2, "x": 1, "r": 1}, "cry.ogg": {"c": 1, "h": 1, "o": 1, "r": 2, "a": 1}, "cut.ogg": {"c": 1, "o": 1, "r": 2, "t": 1, "a": 1}, "dig.ogg": {"c": 1, "a": 2, "v": 1, "r": 1}, "draw.ogg": {"d": 1, "e": 2, "s": 1, "n": 1, "h": 1, "a": 1, "r": 1}, "dream.ogg": {"s": 1, "o": 1, "n": 1, "h": 1, "a": 1, "r": 1}, "to_drink.ogg": {"b": 2, "e": 2, "r": 1}, "drive.ogg": {"c": 1, "o": 1, "n": 1, "d": 1, "u": 1, "z": 1, "i": 1, "r": 1}, "drool.ogg": {"s": 1, "a": 2, "l": 1, "i": 1, "v": 1, "r": 1}, "dry.ogg": {"s": 1, "e": 1, "c": 1, "a": 1, "r": 1}, "eat.ogg": {"c": 1, "o": 1, "m": 1, "e": 1, "r": 1}, "feed.ogg": {"a": 2, "l": 1, "i": 1, "m": 1, "e": 1, "n": 1, "t": 1, "r": 1}, "fall.ogg": {"c": 1, "a": 1, "i": 1, "r": 1}, "fetch.ogg": {"b": 1, "u": 1, "s": 1, "c": 1, "a": 1, "r": 1}, "find.ogg": {"e": 1, "n": 2, "c": 1, "o": 1, "t": 1, "r": 2, "a": 1}, "float.ogg": {"f": 1, "l": 1, "u": 2, "t": 1, "a": 1, "r": 1}, "fly.ogg": {"v": 1, "o": 1, "a": 1, "r": 1}, "freeze.ogg": {"c": 1, "o": 1, "n": 1, "g": 1, "e": 1, "l": 1, "a": 1, "r": 1}, "growl.ogg": {"r": 2, "o": 1, "s": 1, "n": 1, "a": 1}, "hatch.ogg": {"c": 2, "h": 1, "o": 1, "a": 1, "r": 1}, "hear.ogg": {"o": 1, "u": 1, "v": 1, "i": 1, "r": 1}, "howl.ogg": {"u": 1, "i": 1, "v": 1, "a": 1, "r": 1}, "hug.ogg": {"a": 3, "b": 1, "r": 2, "ç": 1}, "jump.ogg": {"s": 1, "a": 2, "l": 1, "t": 1, "r": 1}, "kiss.ogg": {"b": 1, "e": 1, "i": 1, "j": 1, "a": 1, "r": 1}, "kneel.ogg": {"a": 2, "j": 1, "o": 1, "e": 1, "l": 1, "h": 1, "r": 1}, "knit.ogg": {"t": 2, "r": 2, "i": 1, "c": 1, "o": 1, "a": 1}, "lick.ogg": {"l": 1, "a": 1, "m": 1, "b": 1, "e": 1, "r": 1}, "look.ogg": {"o": 1, "l": 1, "h": 1, "a": 1, "r": 1}, "meet.ogg": {"t": 2, "r": 2, "a": 2, "v": 1, "c": 2, "o": 2, "n": 2, "h": 1, "e": 2, "i": 1, "m": 1}, "nap.ogg": {"d": 1, "o": 1, "r": 2, "m": 1, "i": 1, "t": 1, "a": 1}, "peck.ogg": {"b": 1, "i": 1, "c": 1, "a": 1, "r": 1}, "play.ogg": {"b": 1, "r": 2, "i": 1, "n": 1, "c": 1, "a": 1}, "plow.ogg": {"l": 1, "a": 2, "v": 1, "r": 2}, "pounce.ogg": {"a": 3, "t": 1, "c": 1, "r": 1}, "pull.ogg": {"p": 1, "u": 1, "x": 1, "a": 1, "r": 1}, "quarrel.ogg": {"d": 1, "i": 2, "s": 1, "c": 1, "u": 1, "t": 1, "r": 1}, "read.ogg": {"l": 1, "e": 1, "r": 1}, "rip.ogg": {"r": 2, "a": 2, "s": 1, "g": 1}, "rise.ogg": {"s": 1, "u": 1, "b": 1, "i": 1, "r": 1}, "run.ogg": {"c": 1, "o": 1, "r": 3, "e": 1}, "scare.ogg": {"a": 2, "s": 3, "u": 1, "t": 1, "r": 1}, "scratch.ogg": {"a": 3, "r": 3, "n": 1, "h": 1}, "scream.ogg": {"g": 1, "r": 2, "i": 1, "t": 1, "a": 1}, "scribble.ogg": {"r": 2, "a": 2, "b": 1, "i": 1, "s": 1, "c": 1}, "see.ogg": {"v": 1, "e": 1, "r": 1}, "shake.ogg": {"c": 2, "h": 2, "o": 1, "a": 2, "l": 1, "r": 1}, "shave.ogg": {"t": 1, "o": 1, "s": 1, "q": 1, "u": 1, "i": 1, "a": 1, "r": 1}, "sing.ogg": {"c": 1, "a": 2, "n": 1, "t": 1, "r": 1}, "sip.ogg": {"s": 1, "o": 1, "r": 2, "v": 1, "e": 1}, "sit.ogg": {"s": 1, "e": 1, "n": 1, "t": 1, "a": 1, "r": 1}, "slam.ogg": {"m": 1, "a": 2, "r": 2, "c": 1}, "sleep.ogg": {"d": 1, "o": 1, "r": 2, "m": 1, "i": 1}, "smell.ogg": {"c": 1, "h": 1, "e": 1, "i": 1, "r": 2, "a": 1}, "smooch.ogg": {"b": 1, "e": 1, "i": 1, "j": 1, "o": 1, "c": 1, "a": 1, "r": 1}, "sniff.ogg": {"f": 1, "a": 2, "r": 2, "e": 1, "j": 1}, "speak.ogg": {"f": 1, "a": 2, "l": 1, "r": 1}, "spill.ogg": {"e": 1, "n": 2, "t": 1, "o": 1, "r": 2, "a": 1}, "splash.ogg": {"s": 1, "a": 2, "l": 1, "p": 1, "i": 1, "c": 1, "r": 1}, "spray.ogg": {"a": 1, "s": 1, "p": 1, "e": 1, "r": 2, "g": 1, "i": 1}, "spread.ogg": {"e": 1, "s": 1, "p": 1, "a": 2, "l": 1, "h": 1, "r": 1}, "spring.ogg": {"p": 1, "u": 1, "l": 1, "a": 1, "r": 1}, "squat.ogg": {"a": 3, "g": 1, "c": 1, "h": 1, "r": 1}, "stare.ogg": {"f": 1, "i": 1, "t": 1, "a": 1, "r": 1}, "sting.ogg": {"a": 2, "f": 1, "e": 1, "r": 3, "o": 1}, "stitch.ogg": {"c": 1, "o": 1, "s": 1, "e": 1, "r": 1}, "stop.ogg": {"p": 1, "a": 2, "r": 2}, "stretch.ogg": {"e": 1, "s": 1, "t": 1, "i": 1, "c": 1, "a": 1, "r": 1}, "study.ogg": {"e": 1, "s": 1, "t": 1, "u": 1, "d": 1, "a": 1, "r": 1}, "teach.ogg": {"e": 1, "n": 2, "s": 1, "i": 1, "a": 1, "r": 1}, "tear.ogg": {"r": 2, "a": 2, "s": 1, "g": 1}, "think.ogg": {"p": 1, "e": 1, "n": 1, "s": 1, "a": 1, "r": 1}, "touch.ogg": {"t": 1, "o": 1, "c": 1, "a": 1, "r": 1}, "wag.ogg": {"a": 3, "b": 1, "n": 1, "r": 1}, "walk.ogg": {"a": 2, "n": 1, "d": 1, "r": 1}, "wash.ogg": {"l": 1, "a": 2, "v": 1, "r": 1}, "whisper.ogg": {"s": 3, "u": 2, "r": 3, "a": 1}, "win.ogg": {"g": 1, "a": 2, "n": 1, "h": 1, "r": 1}, "write.ogg": {"e": 3, "s": 1, "c": 1, "r": 2, "v": 1}}
    property int lessonIndex:1
    property int configuredMode:5
    property int configuredCase:2
    property bool externalWords:true
    property var completed:[]
    property int expectedQuestions:0
    property int physicalSelections:0
    property int mouseSelections:0
    Component.onCompleted: {
        // Configure before the normal first start, retaining the CLI lesson.
        items.currentMode=configuredMode;
        items.currentLetterCase=configuredCase;
    }
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("WORD_FAILURE",JSON.stringify({actual:actual,expected:expected,message:message}));
        compare(actual,expected,message||"");
    }
    function keyFor(index) {
        var source=wordsModel.get(index).imgurl;
        return source.slice(source.lastIndexOf('/')+1).replace('.webp','.ogg');
    }
    function navigate(index) {
        activityBackground.forceActiveFocus();
        if(wordsView.currentIndex<0)keyClick(Qt.Key_Right);
        var columns=Math.max(1,Math.floor(wordsView.width/wordsView.cellWidth));
        for(var step=0;step<wordsModel.count*3 && wordsView.currentIndex!==index;step++) {
            var current=wordsView.currentIndex;
            var row=Math.floor(current/columns),targetRow=Math.floor(index/columns);
            keyClick(row<targetRow?Qt.Key_Down:row>targetRow?Qt.Key_Up:current<index?Qt.Key_Right:Qt.Key_Left);
            verify(wordsView.currentIndex!==current,"Arrow moves selection");
        }
        checked(wordsView.currentIndex,index,"Keyboard navigation reaches real card");
    }
    function choose(index,keyboardInput) {
        var before=wordsModel.get(index).selected;
        if(keyboardInput) {
            navigate(index);keyClick(Qt.Key_Space);
            physicalSelections++;
        } else {
            var card=wordsView.itemAtIndex(index);verify(card!==null);
            mouseClick(card,card.width/2,card.height/2,Qt.LeftButton,Qt.NoModifier,50);
            mouseSelections++;
        }
        checked(wordsModel.get(index).selected,!before,"One event toggles one card");
    }
    function test_complete_all_generated_questions() {
        wait(1800);
        wait(300);
        checked(items.currentLevel,lessonIndex);
        checked(ApplicationSettings.useExternalWordset(),externalWords);
        checked(activityBackground.englishFallback,false);
        checked(wordsModel.count,Math.min(configuredMode,Object.keys(expectedWords).length));
        var frequencies={},keys=[];
        for(var index=0;index<wordsModel.count;index++) {
            var key=keyFor(index);keys.push(key);
            checked(wordsModel.get(index).spelling,expectedWords[key]);
            for(var character in counts[key])frequencies[character]=(frequencies[character]||0)+counts[key][character];
        }
        var values=[];
        for(var letter in frequencies)values.push(frequencies[letter]);
        values.sort(function(a,b){return b-a;});
        expectedQuestions=Math.min(10,values.length);
        checked(score.numberOfSubLevels,expectedQuestions);
        var seen={};
        for(var questionIndex=0;questionIndex<expectedQuestions;questionIndex++) {
            tryCompare(items,"buttonsBlocked",false,5000);
            checked(score.currentSubLevel,questionIndex);
            var question=questionItem.text;
            verify(!seen[question]);seen[question]=true;
            verify(frequencies[question]>=values[expectedQuestions-1],"Question belongs to the ten most frequent characters, ties allowed");
            if(configuredCase===0)verify(questionItem.font.capitalization===Font.AllUppercase || questionItem.font.capitalization===Font.AllLowercase);
            else checked(questionItem.font.capitalization,configuredCase);
            for(var i=0;i<wordsModel.count;i++)checked(wordsModel.get(i).selected,false);
            if(questionIndex===0) {
                activityBackground.forceActiveFocus();keyClick(Qt.Key_Return);
                checked(score.currentSubLevel,0,"Empty answer is rejected");
                verify(items.buttonsBlocked);
                tryCompare(items,"buttonsBlocked",false,3000);
            }
            var selected=[];
            for(var cardIndex=0;cardIndex<wordsModel.count;cardIndex++) {
                var expected=incidence[question].indexOf(keys[cardIndex])!==-1;
                if(expected) {choose(cardIndex,questionIndex%2===0);selected.push(keys[cardIndex]);}
                checked(wordsModel.get(cardIndex).selected,expected);
            }
            verify(selected.length>0);
            if(questionIndex%2===0){activityBackground.forceActiveFocus();keyClick(Qt.Key_Return);}
            else mouseClick(ok);
            checked(score.currentSubLevel,questionIndex+1);
            completed.push({question:question,capitalization:questionItem.font.capitalization,selected:selected,cards:keys});
            console.log("LETTER_COMPLETED",JSON.stringify(completed[completed.length-1]));
            if(questionIndex===0)grabImage(pageView).save("__QA_OUTPUT__/first-question.png");
            if(questionIndex===expectedQuestions-1) {
                tryCompare(items,"currentLevel",(lessonIndex+1)%items.numberOfLevel,6500);
                checked(score.currentSubLevel,0);
            } else {
                tryCompare(score,"isWinAnimationPlaying",false,3500);
                tryCompare(items,"buttonsBlocked",false,2000);
            }
            wait(60);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,expectedQuestions:expectedQuestions,lesson:lessonIndex,externalWords:externalWords,mode:configuredMode,letterCase:configuredCase,physicalSelections:physicalSelections,mouseSelections:mouseSelections,completed:completed}));}
}
