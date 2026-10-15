// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "FirstPortugueseKeyboard"
    when: activity.visible && items.typedText !== null
    property var unicodeInput
    property var observations: []
    property var realPlayer: null
    property var audioProbe: ({})
    SignalSpy { id: doneSpy; target: activity.audioVoices; signalName: "done" }
    function initTestCase() {
        wait(1600);
        ApplicationSettings.isAudioVoicesEnabled = true;
        realPlayer = findPlayer(activity.audioVoices);
        verify(realPlayer !== null, "Observe the application's original MediaPlayer");
        unicodeInput = Qt.createQmlObject('import "file:__QA_SOURCE__/build/functional-input"; UnicodeInput {}', this);
        compare(ApplicationInfo.getVoicesLocale(items.locale), "pt");
    }
    function findPlayer(root) {
        if(root.position !== undefined && root.playbackState !== undefined && root.duration !== undefined) return root;
        if(root.data) for(var i = 0; i < root.data.length; i++) {
            var player = findPlayer(root.data[i]);
            if(player) return player;
        }
        return null;
    }
    function expectedVoice(character) {
        var code = character.toLowerCase().charCodeAt(0).toString(16).toUpperCase();
        while(code.length < 4) code = "0" + code;
        return "/pt/alphabet/U" + code + ".ogg";
    }
    function checkCharacter(character, method) {
        compare(typedText.text, character.toUpperCase());
        var suffix = expectedVoice(character);
        tryVerify(function() { return String(activity.audioVoices.source).endsWith(suffix); }, 3000);
        observations.push({input:character, displayed:typedText.text, method:method,
                           voice:String(activity.audioVoices.source)});
    }
    function findKey(item, text) {
        if(item.specialKey !== undefined && item.text !== undefined && item.text === text) return item;
        if(item.children) for(var i = 0; i < item.children.length; i++) {
            var found = findKey(item.children[i], text);
            if(found) return found;
        }
        return null;
    }
    function clickKey(text) {
        var key = findKey(keyboard, text);
        verify(key !== null, "Visual key exists: " + text);
        mouseClick(key);
    }
    function test_a_physical_letters_digits_and_portuguese_characters() {
        var basic = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        var accents = "àáâãçéêíóôõúÀÁÂÃÇÉÊÍÓÔÕÚ";
        for(var visible of [false, true]) {
            ApplicationSettings.isVirtualKeyboard = visible;
            wait(200);
            for(var character of basic) {
                textinput.forceActiveFocus();
                keyClick(character);
                checkCharacter(character, "keyClick");
            }
            for(var accented of accents) {
                verify(unicodeInput.commit(textinput, accented));
                checkCharacter(accented, "inputMethod");
            }
        }
        doneSpy.clear();
        verify(unicodeInput.commit(textinput, "ç"));
        tryVerify(function() {
            return String(activity.audioVoices.source).endsWith("/pt/alphabet/U00E7.ogg")
                && realPlayer.playbackState === 1 && realPlayer.position > 0
                && realPlayer.duration > 0 && realPlayer.hasAudio;
        }, 5000);
        audioProbe = {source:String(activity.audioVoices.source), position:realPlayer.position,
                      duration:realPlayer.duration, hasAudio:realPlayer.hasAudio,
                      playbackState:realPlayer.playbackState};
        tryVerify(function() { return doneSpy.count > 0; }, 10000);
        grabImage(activityBackground).save("__QA_OUTPUT__/portuguese-character.png");
    }
    function test_b_visual_keyboard_and_special_controls() {
        ApplicationSettings.isVirtualKeyboard = true;
        wait(1600);
        for(var character of "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") {
            clickKey(character);
            checkCharacter(character, "mouseClick");
        }
        clickKey(keyboard.backspace);
        compare(typedText.text, "");
        clickKey("A");
        compare(typedText.text, "A");
        clickKey(keyboard.newline);
        compare(typedText.text, "");
        clickKey(" ");
        compare(typedText.text, " ");
    }
    function cleanupTestCase() {
        console.log("NATIVE_BABY_KEYBOARD_RESULT", JSON.stringify({
            failures:qtest_results.failCount, passes:qtest_results.passCount,
            observations:observations, voiceDone:doneSpy.count, audioProbe:audioProbe
        }));
    }
}
