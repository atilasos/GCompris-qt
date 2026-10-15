TestCase {
    name: "ChronologyAllLevels"
    when: items.numberOfLevel > 0
    property int solved: 0
    property int rejected: 0
    property int moved: 0
    property bool restarted: false
    property string phase: "initialization"

    function checkpoint(label) {
        phase = label;
        console.log("NATIVE_SEQUENCE_STEP", label, items.currentLevel, items.originListModel.count, items.targetListModel.count);
    }
    function findElement(node, placeholder, filename) {
        if (node.placeholderName === placeholder && typeof node.elementValue === "string"
                && (!filename || node.elementValue.indexOf(filename) !== -1)) return node;
        var children = node.children;
        if (!children) return null;
        for (var i = 0; i < children.length; ++i) {
            var found = findElement(children[i], placeholder, filename);
            if (found) return found;
        }
        return null;
    }
    function dragTo(item, destination) {
        verify(item !== null);
        var point = destination.mapToItem(item, destination.width - 30, destination.height - 30);
        mouseDrag(item, item.width / 2, item.height / 2,
                  point.x - item.width / 2, point.y - item.height / 2,
                  Qt.LeftButton, Qt.NoModifier, 30);
        wait(600);
        moved++;
    }
    function submitOrder(prefix, numbers) {
        for (var i = 0; i < numbers.length; ++i) {
            var file = prefix + "-0" + numbers[i] + ".svg";
            var element = findElement(originPlaceholder, "origin", file);
            dragTo(element, targetPlaceholder);
            if (items.targetListModel.count !== i+1) console.error("NATIVE_ASSERT_DROP", file, items.targetListModel.count, i+1);
            compare(items.targetListModel.count, i + 1);
        }
        compare(items.originListModel.count, 0);
        compare(ok.visible, true);
        mouseClick(ok);
    }
    function barButton(node, suffix) {
        if (typeof node.clicked === "function" && String(node.source).indexOf(suffix) !== -1) return node;
        if (!node.children) return null;
        for (var index = 0; index < node.children.length; ++index) {
            var found = barButton(node.children[index], suffix);
            if (found) return found;
        }
        return null;
    }
    function navigation() {
        var next = barButton(bar, "bar_next.svg");
        var previous = barButton(bar, "bar_previous.svg");
        verify(next !== null && previous !== null);
        mouseClick(next);
        compare(items.currentLevel, 1);
        mouseClick(previous);
        compare(items.currentLevel, 0);
        mouseClick(previous);
        compare(items.currentLevel, 2);
        mouseClick(next);
        compare(items.currentLevel, 0);
    }
    function test_submit_complete_all_levels() {
        wait(1500);
        compare(items.numberOfLevel, 3);
        var prefixes = ["garden", "moon", "tuxtree"];
        for (var level = 0; level < 3; ++level) {
            tryCompare(bonus, "isPlaying", false, 5000);
            wait(700);
            checkpoint("wrong-order");
            compare(items.currentLevel, level);
            compare(items.originListModel.count, 4);
            compare(items.targetListModel.count, 0);
            compare(ok.visible, false);
            verify(items.instruction.text.indexOf("imagens") !== -1);
            submitOrder(prefixes[level], [2, 1, 3, 4]);
            compare(bonus.isWin, false);
            compare(items.targetListModel.get(0).borderColor, "#D94444");
            compare(items.targetListModel.get(1).borderColor, "#D94444");
            compare(items.targetListModel.get(2).borderColor, "#62BA62");
            rejected++;
            grabImage(activityBackground).save("__QA_OUTPUT__/level-" + (level + 1) + "-wrong.png");
            tryCompare(bonus, "isPlaying", false, 5000);
            compare(items.currentLevel, level);

            if (level === 0) {
                checkpoint("reorder-target");
                var second = findElement(targetPlaceholder, "target", "garden-01.svg");
                var first = findElement(targetPlaceholder, "target", "garden-02.svg");
                var targetPoint = first.mapToItem(second, first.width / 2, first.height / 2);
                mouseDrag(second, second.width / 2, second.height / 2,
                          targetPoint.x - second.width / 2, targetPoint.y - second.height / 2,
                          Qt.LeftButton, Qt.NoModifier, 30);
                wait(600);
                verify(items.targetListModel.get(0).elementValue.indexOf("garden-01.svg") !== -1);
                verify(items.targetListModel.get(1).elementValue.indexOf("garden-02.svg") !== -1);
                moved++;
            }

            checkpoint("return-to-origin");
            while (items.targetListModel.count > 0) {
                var target = findElement(targetPlaceholder, "target", "");
                dragTo(target, originPlaceholder);
            }
            compare(items.originListModel.count, 4);
            compare(items.targetPlaceholder.colorResetRequired, false);
            compare(ok.visible, false);

            checkpoint("correct-order");
            submitOrder(prefixes[level], [1, 2, 3, 4]);
            compare(bonus.isWin, true);
            for (var index = 0; index < 4; ++index) {
                verify(items.targetListModel.get(index).elementValue.indexOf(prefixes[level] + "-0" + (index + 1) + ".svg") !== -1);
                compare(items.targetListModel.get(index).borderColor, "#62BA62");
            }
            solved++;
            grabImage(activityBackground).save("__QA_OUTPUT__/level-" + (level + 1) + "-correct.png");
            tryCompare(items, "currentLevel", (level + 1) % 3, 8000);
        }
        checkpoint("restart");
        compare(solved, 3);
        compare(rejected, 3);
        activityBackground.stop();
        activityBackground.start();
        compare(items.currentLevel, 0);
        compare(items.originListModel.count, 4);
        compare(items.targetListModel.count, 0);
        restarted = true;
        checkpoint("navigation");
        navigation();
        grabImage(activityBackground).save("__QA_OUTPUT__/restart.png");
    }
    function cleanupTestCase() {
        grabImage(activityBackground).save("__QA_OUTPUT__/final.png");
        console.log("NATIVE_SEQUENCE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount,
            solved:solved, rejected:rejected, moved:moved, restarted:restarted, phase:phase}));
    }
}
