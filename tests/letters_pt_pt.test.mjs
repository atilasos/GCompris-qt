// SPDX-License-Identifier: GPL-3.0-or-later
// Run: node --test tests/letters_pt_pt.test.mjs
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import test from 'node:test';
const root = new URL('../', import.meta.url);
const json = path => JSON.parse(readFileSync(new URL(path, root), 'utf8'));
function activity(name, script = name) {
    const attempted = [];
    const context = vm.createContext({
        console,
        GCompris: { ApplicationInfo: { getVoicesLocale: () => 'pt', getLocaleFilePath: p => p, ratio: 1,
            localeSort: words => words.sort((a, b) => a.localeCompare(b, 'pt-PT')) },
            ApplicationSettings: { isAudioVoicesEnabled: false } },
        Core: {}
    });
    vm.runInContext(readFileSync(new URL(`src/activities/${name}/${script}.js`, root), 'utf8')
        .replace(/^\.(?:pragma|import).*$/gm, ''), context);
    const parse = path => {
        attempted.push(path);
        try { return json(path.replace(/^qrc:\/gcompris\//, '').replace(/^:\/gcompris\//, '')); }
        catch (error) { if (error.code === 'ENOENT') return null; throw error; }
    };
    return { context, parse, attempted };
}

test('click_on_letter: Portugal loads five vowels and the full 26-letter alphabet in both cases', () => {
    for (const mode of ['lowercase', 'uppercase']) {
        const { context: game, parse, attempted } = activity('click_on_letter');
        game.items = { parser: { parseFromUrl: parse } };
        game.locale = 'pt'; game.mode = mode;
        game.loadLevels();
        assert.equal(attempted.length, 1, 'No English fallback');
        assert.ok(attempted[0].endsWith('levels-pt.json'));
        assert.equal(game.levels[0].questions.toLowerCase(), 'a|e|i|o|u');
        assert.ok(game.validateLevels(game.levels));
        const all = new Set(game.levels.flatMap(level => level.questions.toLowerCase().split('|')));
        assert.equal([...all].sort().join(''), 'abcdefghijklmnopqrstuvwxyz');
        for (const level of game.levels) {
            const answers = level.answers.split('|');
            for (const question of level.questions.split('|')) {
                assert.ok(answers.includes(question), `Missing answer for ${question}`);
                let score = 0;
                game.currentLetter = question;
                game.items = { trainModel: { get: index => ({ letter: answers[index] }) },
                    score: { get currentSubLevel() { return score; }, set currentSubLevel(value) { score = value; },
                        playWinAnimation() {} }, winSound: { play() {} } };
                assert.equal(game.checkAnswer(answers.indexOf(question)), true);
                assert.equal(score, 1);
                const wrong = answers.findIndex(answer => answer !== question);
                assert.equal(game.checkAnswer(wrong), false);
                assert.equal(score, 1);
            }
        }
    }
});

test('gletters: Portugal uses its own progressive list, retaining digits, case and Portuguese accents', () => {
    const { context: game, parse } = activity('gletters');
    const data = parse('qrc:/gcompris/src/activities/gletters/resource/default-pt.json');
    assert.ok(data, 'Portugal must not receive default-en.json');
    assert.equal(data.locale, 'pt');
    assert.equal(data.levels[0].words.join(''), 'aeiou');
    assert.equal(data.levels[3].words.join(''), 'abcdefghijklmnopqrstuvwxyz');
    assert.equal(data.levels[4].words.join(''), '1234567890');
    const chars = new Set(data.levels.flatMap(level => level.words));
    for (const char of 'àáâãéêíóôõúçÀÁÂÃÉÊÍÓÔÕÚÇ') assert.ok(chars.has(char), char);
    const layouts = [];
    for (const [index, level] of data.levels.entries()) {
        assert.equal(Number(level.level), index + 1);
        assert.equal(new Set(level.words).size, level.words.length);
        assert.ok(level.words.every(word => word.length === 1));
        game.items = { currentLevel: index, keyboard: {}, ourActivity: { useDataset: false },
            score: {}, locale: 'pt_PT', wordDropTimer: {},
            wordlist: { getLevelWordList: () => level, getMaxSubLevel: () => 0, initRandomWord() {} } };
        // Qt creates and animates falling objects after this seam. Keep the real level/key population.
        game.initSubLevel = () => {};
        game.initLevel();
        const layout = game.items.keyboard.layout.flat().map(key => key.label);
        for (const char of level.words) {
            assert.ok(layout.includes(char) ||
                (game.items.keyboard.shiftKey && layout.includes(char.toLowerCase())) ||
                (game.items.keyboard.shiftKey && layout.includes(char.toUpperCase())), `Unreachable key ${char}`);
        }
        layouts.push(layout);
        assert.equal(game.items.score.numberOfSubLevels, level.words.length);
    }
    assert.ok(layouts.flat().includes('ç'));
});

function wordlist(parse, defaultFilename) {
    const qml = readFileSync(new URL('src/core/Wordlist.qml', root), 'utf8');
    const functions = [...qml.matchAll(/^    function [\s\S]*?^    }/gm)].map(match => match[0]).join('\n');
    const context = vm.createContext({ parser: { parseFromUrl: parse }, defaultFilename,
        console: { log() {} }, error() {}, maxLevel: 0, wordList: {}, useDefault: true,
        Core: { shuffle: data => data } });
    vm.runInContext(functions, context);
    return context;
}

test('readingh and readingv: explicit Portugal locale selects Portuguese words on first visit', () => {
    for (const locale of ['pt_PT', 'pt_PT.UTF-8', 'system']) {
        const { context: game, parse, attempted } = activity('readingh');
        game.GCompris.ApplicationInfo.getLocaleFilePath = path => path.replace('$LOCALE', 'pt');
        game.Core.getInitialLevel = () => 0;
        game.initLevel = () => {};
        const list = wordlist(parse, 'qrc:/gcompris/src/activities/wordsgame/resource/default-en.json');
        game.start({ locale, wordlist: list, score: {} });
        assert.equal(list.wordList.locale, 'pt', `${locale} must never fall straight to English`);
        assert.ok(!attempted.some(path => path.endsWith('default-en.json')));
        assert.equal(list.wordList.levels[0].words[0], 'amigo');
    }
});

test('shared gletters, wordsgame and keyboard training select Portuguese before fallback', () => {
    for (const [name, resources] of [['gletters', 'gletters'], ['gletters', 'wordsgame'], ['keyboard_training', 'gletters']]) {
        const { context: game, parse, attempted } = activity(name);
        game.GCompris.DownloadManager = { updateResource() {} };
        game.GCompris.GCompris = { VOICES: 1 };
        game.Core.getInitialLevel = () => 0;
        game.initLevel = () => {};
        const dataSetUrl = `qrc:/gcompris/src/activities/${resources}/resource/`;
        const list = wordlist(parse, dataSetUrl + 'default-en.json');
        const items = { locale: 'pt_PT.UTF-8', wordlist: list, dataSetUrl, ourActivity: { dataSetUrl } };
        if (name === 'gletters') game.start(items, false, 'letter', 1);
        else game.start(items);
        assert.equal(list.wordList.locale, 'pt');
        assert.ok(!attempted.some(path => /-(en|pt_BR)\.json$/.test(path)));
    }
});

test('Portuguese accents and cedilla require the matching keyboard character in both cases', () => {
    for (const uppercaseMode of [false, true]) {
        for (const letter of 'àáâãéêíóôõúç') {
            const { context: game } = activity('keyboard_training');
            let score = 0;
            const answers = [];
            game.GCompris.ApplicationInfo.getAudioFilePath = path => path;
            game.Core.getSoundFilenamForChar = char => `U${char.toUpperCase().charCodeAt(0).toString(16).padStart(4, '0')}.ogg`;
            game.items = { uppercaseMode, questionText: uppercaseMode ? letter.toUpperCase() : letter,
                inputLocked: false, client: { sendToServer: correct => answers.push(correct) },
                errorRectangle: { startAnimation() {} }, badAnswerSound: { play() {} },
                particle: { burst() {} }, audioVoices: { stop() {}, append() {} },
                score: { get currentSubLevel() { return score; }, set currentSubLevel(value) { score = value; },
                    playWinAnimation() {} }, locale: 'pt_PT' };
            const unaccented = letter.normalize('NFD').replace(/\p{M}/gu, '');
            game.processKeyPress(unaccented);
            assert.deepEqual(answers, [false]);
            assert.equal(score, 0);
            game.items.inputLocked = false;
            game.processKeyPress(letter);
            assert.deepEqual(answers, [false, true]);
            assert.equal(score, 1);
        }
    }
});

test('shared vocabulary: Portuguese sample and full lessons load without English or Brazilian fallback', () => {
    for (const external of [false, true]) {
        const { context: game, parse, attempted } = activity('lang', 'lang_api');
        game.GCompris.ApplicationSettings.useExternalWordset = () => external;
        const result = game.loadDataset({ parseFromUrl: parse }, 'qrc:/gcompris/src/activities/lang/resource/', 'pt');
        assert.equal(result.englishFallback, false);
        assert.ok(!attempted.some(path => /content-(en|pt_BR)\.json$/.test(path)));
        const lessons = game.getAllLessons(result.dataset);
        assert.ok(lessons.length > 0);
        for (const lesson of lessons) {
            const words = game.getLessonWords(result.dataset, lesson);
            assert.ok(words.length > 0, `Empty lesson ${lesson.name}`);
            for (const word of words) {
                assert.equal(word.translatedTxt, result.dataset.contentText[word.voice.split('/').at(-1).replace('$CA', 'ogg')]);
                assert.equal(word.translatedTxt, word.translatedTxt.normalize('NFC'));
            }
        }
    }
});

test('Portuguese vocabulary uses current spelling and the Portugal word for refrigerator', () => {
    const content = json('src/activities/lang/resource/content-pt.json');
    assert.equal(content['parachute.ogg'], 'paraquedas');
    assert.equal(content['pear.ogg'], 'pera');
    const words = json('src/activities/wordsgame/resource/default-pt.json').levels.flatMap(level => level.words);
    assert.ok(words.includes('frigorífico'));
    assert.ok(!words.includes('geladeira'));
});
