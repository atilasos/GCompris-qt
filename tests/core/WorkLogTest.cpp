/* GCompris - WorkLogTest.cpp
 *
 * SPDX-FileCopyrightText: 2026 GCompris contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include <QTest>
#include <QTemporaryDir>
#include <QDirIterator>
#include <QSignalSpy>
#include "src/core/WorkLog.h"

class WorkLogTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:
    void completedRound();
    void firstOpeningOrderAndAccumulation();
    void repeatedStartIsIdempotent();
    void noCurrentActivityAndClear();
    void sessionNeverWritesToDisk();
};

void WorkLogTest::completedRound()
{
    WorkLog log;
    log.activityStarted(QStringLiteral("enumerate/Enumerate.qml"));
    QVERIFY(!log.entries().first().toMap().value("hasRounds").toBool());
    log.roundCompleted();
    QVERIFY(log.entries().first().toMap().value("hasRounds").toBool());
    QCOMPARE(log.entries().first().toMap().value("rounds").toInt(), 1);
}

void WorkLogTest::firstOpeningOrderAndAccumulation()
{
    WorkLog log;
    log.activityStarted(QStringLiteral("enumerate/Enumerate.qml"));
    log.roundCompleted();
    log.activityStarted(QStringLiteral("dominorio/Dominorio.qml"));
    log.activityStarted(QStringLiteral("enumerate/Enumerate.qml"));
    log.roundCompleted();
    QCOMPARE(log.entries().size(), 2);
    const auto first = log.entries()[0].toMap();
    const auto second = log.entries()[1].toMap();
    QCOMPARE(first.value("activityId").toString(), QStringLiteral("enumerate/Enumerate.qml"));
    QCOMPARE(first.value("rounds").toInt(), 2);
    QCOMPARE(second.value("activityId").toString(), QStringLiteral("dominorio/Dominorio.qml"));
    QVERIFY(!second.value("hasRounds").toBool());
    QCOMPARE(second.value("rounds").toInt(), 0);
    // The read model is a snapshot; callers cannot edit the session through it.
    auto copy = log.entries();
    copy.clear();
    QCOMPARE(log.entries().size(), 2);
}

void WorkLogTest::repeatedStartIsIdempotent()
{
    WorkLog log;
    QSignalSpy changed(&log, &WorkLog::entriesChanged);
    log.activityStarted(QStringLiteral("enumerate/Enumerate.qml"));
    log.roundCompleted();
    log.activityStarted(QStringLiteral("enumerate/Enumerate.qml"));
    log.activityStarted(QStringLiteral("enumerate/Enumerate.qml"));
    QCOMPARE(log.entries().size(), 1);
    QCOMPARE(log.entries().first().toMap().value("rounds").toInt(), 1);
    QCOMPARE(changed.size(), 2);
}

void WorkLogTest::noCurrentActivityAndClear()
{
    WorkLog log;
    log.roundCompleted();
    log.activityStarted(QString());
    log.activityStarted(QStringLiteral("menu/Menu.qml"));
    QVERIFY(log.entries().isEmpty());
    log.activityStarted(QStringLiteral("enumerate/Enumerate.qml"));
    log.roundCompleted();
    QSignalSpy changed(&log, &WorkLog::entriesChanged);
    log.clear();
    QCOMPARE(changed.size(), 1);
    QVERIFY(log.entries().isEmpty());
    log.roundCompleted();
    QVERIFY(log.entries().isEmpty());
    log.activityStarted(QStringLiteral("enumerate/Enumerate.qml"));
    QCOMPARE(log.entries().size(), 1);
    QVERIFY(!log.entries().first().toMap().value("hasRounds").toBool());
}

void WorkLogTest::sessionNeverWritesToDisk()
{
    QTemporaryDir profile;
    QVERIFY(profile.isValid());
    const QByteArray oldConfig = qgetenv("XDG_CONFIG_HOME");
    const QByteArray oldData = qgetenv("XDG_DATA_HOME");
    const QByteArray oldCache = qgetenv("XDG_CACHE_HOME");
    const QByteArray oldHome = qgetenv("HOME");
    for (const char *key : {"XDG_CONFIG_HOME", "XDG_DATA_HOME", "XDG_CACHE_HOME", "HOME"})
        qputenv(key, profile.path().toUtf8());
    QDirIterator before(profile.path(), QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Hidden,
                        QDirIterator::Subdirectories);
    const bool emptyBefore = !before.hasNext();
    {
        WorkLog log;
        log.activityStarted(QStringLiteral("enumerate/Enumerate.qml"));
        log.roundCompleted();
        log.activityStarted(QStringLiteral("dominorio/Dominorio.qml"));
        log.entries();
        log.clear();
        log.activityStarted(QStringLiteral("enumerate/Enumerate.qml"));
        log.roundCompleted();
    }
    WorkLog nextSession;
    const bool nextSessionEmpty = nextSession.entries().isEmpty();
    QDirIterator after(profile.path(), QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Hidden,
                       QDirIterator::Subdirectories);
    const bool emptyAfter = !after.hasNext();
    qputenv("XDG_CONFIG_HOME", oldConfig);
    qputenv("XDG_DATA_HOME", oldData);
    qputenv("XDG_CACHE_HOME", oldCache);
    qputenv("HOME", oldHome);
    QVERIFY(emptyBefore);
    QVERIFY(emptyAfter);
    QVERIFY(nextSessionEmpty);
}

QTEST_GUILESS_MAIN(WorkLogTest)
#include "WorkLogTest.moc"
