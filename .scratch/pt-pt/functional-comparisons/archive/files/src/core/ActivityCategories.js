// SPDX-License-Identifier: GPL-3.0-or-later
.pragma library

// Labels are presentation only: ActivityInfo.section remains a filter identifier.
function labels() {
    return {
        "computer": qsTranslate("DialogHelp", "Computer"),
        "discovery": qsTranslate("DialogHelp", "Discovery"),
        "sciences": qsTranslate("DialogHelp", "Sciences"),
        "fun": qsTranslate("DialogHelp", "Fun"),
        "math": qsTranslate("DialogHelp", "Mathematics"),
        "puzzle": qsTranslate("DialogHelp", "Puzzles"),
        "reading": qsTranslate("DialogHelp", "Reading"),
        "strategy": qsTranslate("DialogHelp", "Strategy"),
        "memory": qsTranslate("DialogHelp", "Memory"),
        "mouse": qsTranslate("DialogHelp", "Mouse"),
        "keyboard": qsTranslate("DialogHelp", "Keyboard"),
        "money": qsTranslate("DialogHelp", "Money"),
        "color": qsTranslate("DialogHelp", "Colors"),
        "colors": qsTranslate("DialogHelp", "Colors"),
        "maze": qsTranslate("DialogHelp", "Mazes"),
        "addition": qsTranslate("DialogHelp", "Addition"),
        "braille": qsTranslate("DialogHelp", "Braille"),
        "subtraction": qsTranslate("DialogHelp", "Subtraction"),
        "mobile": qsTranslate("DialogHelp", "Mobile devices"),
        "multiplication": qsTranslate("DialogHelp", "Multiplication"),
        "division": qsTranslate("DialogHelp", "Division"),
        "logic": qsTranslate("DialogHelp", "Logic"),
        "arithmetic": qsTranslate("DialogHelp", "Arithmetic"),
        "arts": qsTranslate("Menu", "Fine Arts"),
        "music": qsTranslate("Menu", "Music"),
        "experiment": qsTranslate("Menu", "Experiment"),
        "history": qsTranslate("Menu", "History"),
        "geography": qsTranslate("Menu", "Geography"),
        "numeration": qsTranslate("Menu", "Numeration"),
        "measures": qsTranslate("Menu", "Measures"),
        "letters": qsTranslate("Menu", "Letters"),
        "words": qsTranslate("Menu", "Words"),
        "vocabulary": qsTranslate("Menu", "Vocabulary"),
    };
}

function format(section) {
    var translated = labels();
    return String(section).trim().split(/\s+/).filter(function(token) {
        return token.length > 0;
    }).map(function(token) {
        return translated[token] || token;
    }).join(", ");
}
