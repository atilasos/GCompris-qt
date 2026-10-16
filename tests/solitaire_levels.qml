// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "SolitairePublicLevelContract"
    when: activity.visible && items.numberOfLevel > 1
    property var visited: []
    function findButton(item, suffix) {
        if(item.source !== undefined && String(item.source).endsWith(suffix)) return item;
        if(item.children) for(var i = 0; i < item.children.length; i++) {
            var found = findButton(item.children[i], suffix);
            if(found) return found;
        }
        return null;
    }
    function initTestCase() { wait(1600); }
    function test_a_public_count_matches_four_boards() {
        compare(items.numberOfLevel, 4);
        compare(activity.numberOfLevel, 4, "ActivityBase must know all four boards");
    }
    function test_b_navigation_updates_public_current_level() {
        for(var direction of [1,-1]) {
            var button = findButton(bar, direction === 1 ? "bar_next.svg" : "bar_previous.svg");
            verify(button !== null);
            for(var step = 0; step < 4; step++) {
                var expected = (items.currentLevel + direction + 4) % 4;
                mouseClick(button);
                tryCompare(items, "currentLevel", expected);
                compare(activity.currentLevel, expected, "Public current level follows actual navigation");
                visited.push({direction:direction, current:activity.currentLevel, description:items.boardDescription});
                wait(300);
            }
        }
    }
    function cleanupTestCase() {
        console.log("NATIVE_SOLITAIRE_LEVELS_RESULT", JSON.stringify({
            failures:qtest_results.failCount, passes:qtest_results.passCount,
            total:activity.numberOfLevel, current:activity.currentLevel,
            engineTotal:items.numberOfLevel, engineCurrent:items.currentLevel,
            visited:visited
        }));
    }
}
