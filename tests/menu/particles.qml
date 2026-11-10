// SPDX-License-Identifier: GPL-3.0-or-later
// Seam: the real menu grid, its cards and the activity loader. Particle
// systems are found by walking the item tree under activitiesGrid and
// matching ParticleSystemStarLoader by its loaded source, not by type name.
TestCase {
    name: "MenuParticlesNative"
    when: activity.visible

    function ensure(value, message) {
        if (!value) console.log("MENU_PARTICLES_ASSERT_FAILED", message || "", new Error().stack);
        verify(value, message || "");
    }
    function textIn(item, text) {
        if (item.text !== undefined && String(item.text).indexOf(text) >= 0) return true;
        for (var i = 0; i < item.children.length; ++i)
            if (textIn(item.children[i], text)) return true;
        return false;
    }
    function icon(item, suffix) {
        if (item.source !== undefined && String(item.source).endsWith(suffix)) return item;
        for (var i = 0; i < item.children.length; ++i) {
            var found = icon(item.children[i], suffix); if (found) return found;
        }
        return null;
    }
    function isStarLoader(item) {
        return item.source !== undefined && item.status !== undefined && item.item !== undefined
               && String(item.source).endsWith("/src/core/ParticleSystemStar.qml");
    }
    // Counts ParticleSystemStarLoader instances, the particle systems they
    // actually loaded and the activity cards (delegates) under the grid.
    function census() {
        var result = { loaders: [], systems: 0, cards: 0 };
        function walk(item) {
            if (isStarLoader(item)) {
                result.loaders.push(item);
                if (item.item) ++result.systems;
            }
            if (item.activityInfoTreeItem !== undefined) ++result.cards;
            for (var i = 0; i < item.children.length; ++i) walk(item.children[i]);
        }
        walk(activitiesGrid);
        return result;
    }
    function report(stage, c) {
        console.log("MENU_PARTICLES", JSON.stringify({ stage: stage, loaders: c.loaders.length, systems: c.systems,
                                                       cards: c.cards, gridCount: activitiesGrid.count,
                                                       hasShader: ApplicationInfo.hasShader }));
    }
    function cardFor(text) {
        for (var d = 0; d < activitiesGrid.count; ++d) {
            var candidate = activitiesGrid.itemAtIndex(d);
            if (candidate && textIn(candidate, text)) return candidate;
        }
        return null;
    }

    function test_one_shared_particle_system() {
        wait(1500);
        // Strategy section: many cards, including Dominório.
        var strategy = -1;
        for (var s = 0; s < activity.sections.length; ++s)
            if (activity.sections[s].tag === "strategy") strategy = s;
        ensure(strategy >= 0, "Strategy section exists");
        mouseClick(section.itemAtIndex(strategy));
        tryVerify(function() { return activity.currentTag === "strategy"; }, 2000);
        wait(800);
        ensure(activitiesGrid.count >= 6, "Several activity cards in the grid");

        var before = census();
        report("menu", before);
        ensure(before.cards >= 6, "Several delegates are instantiated");
        ensure(ApplicationInfo.hasShader, "Particle loaders are active on this platform");
        ensure(before.loaders.length === 1, "Exactly one particle loader under activitiesGrid, got "
               + before.loaders.length + " for " + before.cards + " cards");
        ensure(before.systems === 1, "Exactly one loaded particle system under activitiesGrid");
        var shared = before.loaders[0];
        ensure(shared.objectName === "activityParticles", "Shared loader is the grid one");

        // Scroll so the clicked card is not at the content origin.
        var card = cardFor("Dominório");
        var index = -1;
        for (var d = 0; d < activitiesGrid.count; ++d)
            if (activitiesGrid.itemAtIndex(d) === card) index = d;
        ensure(index >= 0, "Dominório card in strategy section");
        activitiesGrid.positionViewAtIndex(index, GridView.Beginning);
        wait(300);
        card = activitiesGrid.itemAtIndex(index);
        ensure(card !== null && textIn(card, "Dominório"), "Dominório card still instantiated");
        console.log("MENU_PARTICLES_SCROLL", JSON.stringify({ index: index, contentY: activitiesGrid.contentY,
                                                              cardX: card.x, cardY: card.y }));

        mouseClick(card, card.width / 2, card.height / 2);
        // Geometry right after the click: the shared system covers the
        // clicked card exactly, in content coordinates (scroll-independent).
        var origin = shared.mapToItem(card, 0, 0);
        console.log("MENU_PARTICLES_GEOMETRY", JSON.stringify({ dx: origin.x, dy: origin.y,
                    width: shared.width, height: shared.height, cardWidth: card.width, cardHeight: card.height,
                    parentIsContent: shared.parent.parent === activitiesGrid.contentItem,
                    running: shared.item ? shared.item.running : null,
                    opacity: shared.item ? shared.item.opacity : null }));
        ensure(Math.abs(origin.x) < 0.5 && Math.abs(origin.y) < 0.5, "Particles positioned on the clicked card");
        ensure(Math.abs(shared.width - card.width) < 0.5 && Math.abs(shared.height - card.height) < 0.5,
               "Particles have the clicked card size");
        ensure(shared.item && shared.item.running && shared.item.opacity === 1, "Click bursts the shared system");

        tryVerify(function() { return activityLoader.item && activityLoader.item.visible; }, 5000);
        wait(800);
        var game = activityLoader.item;
        ensure(findChild(game, "dominorioBoard") !== null, "Clicking the card opens the activity");
        ensure(textIn(game, "Participante 1"), "Activity is playable");
        grabImage(pageView).save("__QA_OUTPUT__/activity.png");

        var home = icon(game, "bar_home.svg");
        ensure(home !== null, "Home button found");
        // The page may still be sliding in; click only once the button is
        // fully inside the window.
        var root = home.Window.window.contentItem;
        tryVerify(function() {
            var corner = home.mapToItem(root, home.width, home.height);
            return !pageView.busy && corner.x <= root.width && corner.y <= root.height;
        }, 5000, "Home button inside the window");
        mouseClick(home, home.width / 2, home.height / 2);
        tryCompare(pageView, "depth", 1, 2000);
        ensure(pageView.currentItem.isMenu, "Back at the menu");
        wait(500);
        var after = census();
        report("return", after);
        ensure(after.loaders.length === 1 && after.systems === 1, "Still one particle system after returning");
        grabImage(pageView).save("__QA_OUTPUT__/menu.png");
    }
    function cleanupTestCase() {
        if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
