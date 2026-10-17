// SPDX-License-Identifier: GPL-3.0-or-later
// Run: node --test tests/grammar_pt_pt.test.mjs
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import test from 'node:test';

const root = new URL('../', import.meta.url);
const source = readFileSync(new URL('src/activities/grammar_analysis/grammar_analysis.js', root), 'utf8')
    .replace(/^\.(?:pragma|import).*$/gm, '');

function model() {
    return {
        rows: [],
        get count() { return this.rows.length; },
        clear() { this.rows = []; },
        append(row) { this.rows.push(row); },
        get(index) { return this.rows[index]; }
    };
}

function loadActivity(activity) {
    const warnings = [];
    const context = vm.createContext({
        qsTr: text => text,
        console: { warn: message => warnings.push(message) },
        // Qt boundary: pt_PT resolves to the voice/data locale pt, covered by C++ tests.
        GCompris: {
            ApplicationInfo: { getVoicesLocale: () => 'pt', getLocaleFilePath: path => path },
            ApplicationSettings: { userDataPath: '/isolated-test-profile' }
        },
        Core: { localeNeedSpaces: () => true, isLeftToRightLocale: () => true }
    });
    vm.runInContext(source, context);
    context.grammarMode = activity === 'grammar_classes' ? '_classes' : '_analysis';
    context.dataSetUrl = `qrc:/gcompris/src/activities/${activity}/resource/`;
    context.items = {
        locale: 'pt_PT.UTF-8', syntaxModel: model(), datasetModel: model(),
        goalModel: model(), answerModel: model(), objective: {}, phrase: {}, response: {},
        inspector: {}, errors: {}, file: { exists: () => false },
        jsonParser: {
            parseFromUrl(path) {
                try {
                    return JSON.parse(readFileSync(new URL(path.replace('qrc:/gcompris/', ''), root), 'utf8'));
                } catch (error) {
                    if (error.code === 'ENOENT') return null;
                    throw error;
                }
            }
        }
    };
    context.loadDatas();
    return { context, warnings };
}

for (const activity of ['grammar_classes', 'grammar_analysis']) {
    test(`${activity}: Portugal loads its own dataset without English fallback`, () => {
        const { context, warnings } = loadActivity(activity);
        assert.equal(context.items.translationFile, `${activity}-pt.json`);
        assert.deepEqual(warnings, []);
        const labels = { nou: 'Nome', dtm: 'Determinante', adj: 'Adjetivo', prn: 'Pronome',
                         vrb: 'Verbo', adv: 'Advérbio', cjt: 'Conjunção', ppt: 'Preposição', itj: 'Interjeição', pdt: 'Preposição + determinante', ppr: 'Preposição + pronome' };
        for (const item of context.datas.syntax) {
            assert.equal(item.wordClass, labels[item.code]);
        }
        assert.ok(context.datas.levels.every(level => level.objective.startsWith('Identifica ')));
    });

    test(`${activity}: every level and exercise is valid in the real game parser`, () => {
        const { context } = loadActivity(activity);
        const reference = JSON.parse(readFileSync(new URL(`src/activities/${activity}/resource/${activity}-en.json`, root), 'utf8'));
        assert.ok(context.datas.levels.length > reference.levels.length);
        const englishSentences = new Set(Object.values(reference.dataset).flat().map(item => item.sentence));
        context.initSyntax();
        for (const [levelIndex, level] of context.datas.levels.entries()) {
            const exercises = context.datas.dataset[level.exercise];
            assert.ok(exercises.length >= 12, level.exercise);
            for (const exercise of exercises) {
                assert.ok(!/\s{2,}/u.test(exercise.sentence), `Repeated spaces: ${exercise.sentence}`);
                assert.ok(!englishSentences.has(exercise.sentence), `Untranslated sentence: ${exercise.sentence}`);
                const parsed = context.analyzeExercise(levelIndex, exercise);
                assert.equal(parsed.errors, '', `${level.exercise}: ${exercise.sentence}`);
                assert.ok(context.checkExercise(parsed), `Exercise would be silently filtered: ${exercise.sentence}`);
                for (const goal of level.goal.split(' ')) {
                    assert.ok(context.datas.syntax.some(item => item.code === goal), goal);
                }
            }
        }
        const count = context.datas.levels.length;
        context.checkLevels();
        assert.equal(context.datas.levels.length, count, 'No Portuguese level may disappear');
    });

    test(`${activity}: Portuguese contractions keep both grammatical classes`, () => {
        const { context } = loadActivity(activity);
        const exercises = Object.values(context.datas.dataset).flat();
        const rain = exercises.find(item => item.sentence === 'A chuva cai no jardim.');
        assert.ok(rain, 'Portuguese counterpart of the reported sentence must exist');
        assert.equal(rain.answer, 'dtm nou vrb ppt+dtm nou');
        context.initSyntax();
        const parsed = context.analyzeExercise(0, rain);
        assert.equal(parsed.errors, '');
        assert.equal(parsed.words[3], 'no');
        assert.equal(parsed.classes[3], 'ppt+dtm');
    });

    test(`${activity}: all Portuguese solutions are accepted and wrong answers rejected`, () => {
        const { context } = loadActivity(activity);
        context.initSyntax();
        let correct = 0;
        let incorrect = 0;
        Object.assign(context.items, {
            goodAnswerSound: { play() { correct++; } },
            badAnswerSound: { play() { incorrect++; } },
            score: { playWinAnimation() {} },
            errorRectangle: { startAnimation() {} },
            client: { sendToServer() {} }
        });
        let checked = 0;
        for (const [levelIndex, level] of context.datas.levels.entries()) {
            for (const exercise of context.datas.dataset[level.exercise]) {
                context.items.currentLevel = levelIndex;
                context.items.currentExercise = 0;
                context.items.datasetModel.clear();
                context.items.datasetModel.append({ exercise });
                context.buildAnswer();
                assert.equal(context.items.errors.text, '', exercise.sentence);
                const words = context.items.answerModel.rows.filter(row => row.code);
                assert.ok(words.every(row => !row.code.includes('+')), exercise.sentence);
                assert.equal(context.boxCount, words.length, exercise.sentence);
                for (const row of words) {
                    assert.ok(row.code === '_' || context.items.goalModel.rows.some(token => token.code === row.code),
                              `Missing selectable token: ${row.code} in ${exercise.sentence}`);
                }
                const cards = context.items.answerModel.rows.map(row => ({ expected: row.code, proposition: row.code }));
                context.items.rowAnswer = { count: cards.length, itemAt: index => cards[index] };
                context.checkResult();
                assert.equal(correct, checked + 1, exercise.sentence);
                assert.equal(context.items.currentExercise, 1);
                const answer = cards.find(card => card.expected.split('+').some(code => code && code !== '_'));
                assert.ok(answer, exercise.sentence);
                answer.proposition = '_';
                context.checkResult();
                assert.equal(incorrect, checked + 1, exercise.sentence);
                assert.equal(context.items.currentExercise, 1, 'Wrong answer must not advance');
                checked++;
            }
        }
    });
}

for (const activity of ['grammar_classes', 'grammar_analysis']) {
    test(`${activity}: contractions occupy one box with only the requested classes`, () => {
        const { context } = loadActivity(activity);
        context.initSyntax();
        const cases = [
            ['dtm nou', 'A chuva cai no jardim.', 'dtm nou vrb ppt+dtm nou', 'no', 'dtm'],
            ['dtm', 'A gata dorme na sala.', 'dtm nou vrb ppt+dtm nou', 'na', 'dtm'],
            ['ppt', 'A gata dorme na sala.', 'dtm nou vrb ppt+dtm nou', 'na', 'ppt'],
            ['nou', 'A chuva cai no jardim.', 'dtm nou vrb ppt+dtm nou', 'no', '_'],
            ['dtm nou ppt', 'O livro está na mochila.', 'dtm nou vrb ppt+dtm nou', 'na', 'pdt'],
            ['ppt prn', 'Eu gosto disto.', 'prn vrb ppt+prn', 'disto', 'ppr'],
            ['prn', 'Eu gosto disto.', 'prn vrb ppt+prn', 'disto', 'prn']
        ];
        for (const [goal, sentence, answer, word, expected] of cases) {
            // Multi-class goals belong to analysis; classes uses only the first goal.
            if (context.grammarMode === '_classes' && goal.includes(' ')) continue;
            context.datas.levels = [{ goal, objective: 'Identifica as classes.' }];
            context.items.currentLevel = 0;
            context.items.currentExercise = 0;
            context.items.datasetModel.clear();
            context.items.datasetModel.append({ exercise: { sentence, answer } });
            context.buildAnswer();
            const row = context.items.answerModel.rows.find(row => row.word === word);
            assert.equal(row.code, expected, `${sentence}: ${word} must have one box`);
            assert.equal(context.boxCount, sentence.replace(/[.!]/g, '').split(' ').length);
            assert.equal(context.items.boxIndexes.length, context.boxCount);
            if (expected !== '_') {
                assert.ok(context.items.goalModel.rows.some(row => row.code === expected));
            }
        }
    });
}

test('Datasets without a combined token retain separate boxes for merged classes', () => {
    const { context } = loadActivity('grammar_analysis');
    context.datas.syntax = context.datas.syntax.filter(entry => !entry.mergedClasses);
    context.initSyntax();
    context.datas.levels = [{ goal: 'dtm nou', objective: 'Find determiners and nouns.' }];
    context.items.currentLevel = 0;
    context.items.currentExercise = 0;
    context.items.datasetModel.append({ exercise: {
        sentence: 'A chuva cai no jardim.', answer: 'dtm nou vrb ppt+dtm nou'
    } });
    context.buildAnswer();
    assert.equal(context.items.answerModel.rows.find(row => row.word === 'no').code, '_+dtm');
    assert.equal(context.boxCount, 6);
});
