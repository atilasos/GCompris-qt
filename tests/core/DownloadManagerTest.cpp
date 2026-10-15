/* GCompris - DownloadManagerTest.cpp
 *
 * SPDX-FileCopyrightText: 2018 Alex Kovrigin <a.kovrigin0@gmail.com>
 * GCompris  (C) 2018 GCompris Developers <gcompris-devel@kde.org>
 *
 * Authors:
 *   Alex Kovrigin <a.kovrigin0@gmail.com>
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QObject>
#include <QTest>
#include <QString>
#include <QTemporaryDir>
#include <QProcess>
#include <QLibraryInfo>
#include <QTcpServer>
#include <QTcpSocket>
#include <QNetworkProxy>
#include <QSignalSpy>
#include <QScopeGuard>

#include "src/core/DownloadManager.h"
#include "src/core/ApplicationInfo.h"
#include "ApplicationSettingsMock.h"
/**
 * @brief The DownloadManagerTest class Unit tests class for DownloadManager testing
 * @sa DownloadManager
 */
class DownloadManagerTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    /**
     * @brief initTestCase Case for basic functionality of DownloadManager
     */
    void initTestCase()
    {
        ApplicationSettingsMock::getInstance()->setIsAutomaticDownloadsEnabled(false);
        downloadManager = DownloadManager::getInstance();
    }

    void test_getVoicesResourceForLocale_data()
    {
        QTest::addColumn<QString>("locale");
        QTest::addColumn<QString>("language");

        QTest::newRow("en_US") << "en_US" << "en_US";
        QTest::newRow("en_UK") << "en_UK" << "en";
        QTest::newRow("ru_RU") << "ru_RU" << "ru";
        QTest::newRow("de_DE") << "de_DE" << "de";
        QTest::newRow("fr_FR") << "fr_FR" << "fr";
    }
    void test_getVoicesResourceForLocale()
    {
        QFETCH(QString, locale);
        QFETCH(QString, language);

        DownloadManager::DownloadJob job{GCompris::ResourceType::NONE};
        job.file.setFileName(QFINDTESTDATA("Contents.test"));
        downloadManager->parseContents(&job);
        QCOMPARE(downloadManager->getVoicesResourceForLocale(locale),
                 QString("data3/voices-%1/voices-%2-2023-10-07-17-29-00.rcc").arg(COMPRESSED_AUDIO, language));
    }


    void test_onlineOlderIndexKeepsValidNewerVoicesAndOfflineRestart()
    {
        QTemporaryDir folder;
        QVERIFY(folder.isValid());
        auto *settings = ApplicationSettingsMock::getInstance();
        const QString originalCache = settings->cachePath();
        const auto restoreCache = qScopeGuard([&] { settings->setCachePath(originalCache); });
        settings->setCachePath(folder.path());
        auto *originalSingleton = DownloadManager::_instance;
        const auto restoreSingleton = qScopeGuard([&] { DownloadManager::_instance = originalSingleton; });
        const QString relative = QStringLiteral("data3/voices-") + QStringLiteral(COMPRESSED_AUDIO) + '/';
        const QString directory = folder.path() + '/' + relative;
        QVERIFY(QDir().mkpath(directory));
        const QString oldName = QStringLiteral("voices-pt-2026-01-01-00-00-00.rcc");
        const QString newName = QStringLiteral("voices-pt-2026-02-01-00-00-00.rcc");
        createVoiceRcc(directory + oldName, false);
        createVoiceRcc(directory + newName, true);
        const QString brazilName = QStringLiteral("voices-pt_BR-2026-01-01-00-00-00.rcc");
        createVoiceRcc(directory + brazilName, false);
        const QByteArray brazilContents = contentsLine(directory + brazilName);
        const QByteArray oldContents = contentsLine(directory + oldName) + brazilContents;
        QVERIFY(writeFixture(directory + QStringLiteral("Contents"), contentsLine(directory + newName) + brazilContents));

        QTcpServer server;
        QVERIFY(server.listen(QHostAddress::LocalHost));
        QStringList requests;
        const QMap<QString, QByteArray> responses = {
            {'/' + relative + QStringLiteral("Contents"), oldContents},
            {'/' + relative + oldName, fixtureBytes(directory + oldName)}
        };
        serveFixtures(server, responses, requests);
        {
            DownloadManager manager;
            const auto cleanup = qScopeGuard([&] {
                const auto resources = manager.registeredResources;
                for (const auto &resource : resources) manager.unregisterResource_locked(resource);
            });
            manager.accessManager.setProxy(QNetworkProxy::NoProxy);
            manager.serverUrl = QUrl(QStringLiteral("http://127.0.0.1:%1").arg(server.serverPort()));
            manager.initializeAssets();
            QCOMPARE(manager.getVoicesResourceForLocale(QStringLiteral("pt_PT")), relative + newName);
            QCOMPARE(manager.getVoicesResourceForLocale(QStringLiteral("pt_BR")), relative + brazilName);
            QVERIFY(manager.updateResource(GCompris::VOICES, {{QStringLiteral("locale"), QStringLiteral("pt_BR")}}));
            QSignalSpy completed(&manager, &DownloadManager::downloadFinished);
            QSignalSpy errors(&manager, &DownloadManager::error);
            QVERIFY(manager.downloadResource(GCompris::VOICES, {{QStringLiteral("locale"), QStringLiteral("pt")}}));
            QTRY_COMPARE_WITH_TIMEOUT(completed.size(), 1, 5000);
            QCOMPARE(manager.getVoicesResourceForLocale(QStringLiteral("pt_PT")), relative + newName);
            QCOMPARE(errors.size(), 0);
            QCOMPARE(manager.getVoicesResourceForLocale(QStringLiteral("pt_BR")), relative + brazilName);
            QCOMPARE(fixtureBytes(QStringLiteral(":/gcompris/data/voices-ogg/pt_BR/alphabet/U0061.ogg")), QByteArray("OggSoriginal"));
            QCOMPARE(requests, QStringList{'/' + relative + QStringLiteral("Contents")});
            QCOMPARE(fixtureBytes(QStringLiteral(":/gcompris/data/voices-ogg/pt/alphabet/U00E7.ogg")), QByteArray("OggSnew-accent"));
        }
        server.close();
        {
            DownloadManager restarted;
            const auto cleanup = qScopeGuard([&] {
                const auto resources = restarted.registeredResources;
                for (const auto &resource : resources) restarted.unregisterResource_locked(resource);
            });
            restarted.initializeAssets();
            QCOMPARE(restarted.getVoicesResourceForLocale(QStringLiteral("pt_PT")), relative + newName);
            QVERIFY(restarted.updateResource(GCompris::VOICES, {{QStringLiteral("locale"), QStringLiteral("pt")}}));
            QCOMPARE(fixtureBytes(QStringLiteral(":/gcompris/data/voices-ogg/pt/alphabet/U00E7.ogg")), QByteArray("OggSnew-accent"));
        }
    }


    void test_onlineVoiceUpdatesAndRepair_data()
    {
        QTest::addColumn<QString>("state");
        QTest::addColumn<bool>("remoteNewer");
        QTest::newRow("newer-upstream") << QStringLiteral("valid") << true;
        QTest::newRow("missing-newer-local") << QStringLiteral("missing") << false;
        QTest::newRow("corrupt-newer-local") << QStringLiteral("corrupt") << false;
    }

    void test_onlineVoiceUpdatesAndRepair()
    {
        QFETCH(QString, state);
        QFETCH(bool, remoteNewer);
        QTemporaryDir folder;
        QVERIFY(folder.isValid());
        auto *settings = ApplicationSettingsMock::getInstance();
        const QString originalCache = settings->cachePath();
        const auto restoreCache = qScopeGuard([&] { settings->setCachePath(originalCache); });
        settings->setCachePath(folder.path());
        auto *originalSingleton = DownloadManager::_instance;
        const auto restoreSingleton = qScopeGuard([&] { DownloadManager::_instance = originalSingleton; });
        const QString relative = QStringLiteral("data3/voices-") + QStringLiteral(COMPRESSED_AUDIO) + '/';
        const QString directory = folder.path() + '/' + relative;
        QVERIFY(QDir().mkpath(directory));
        const QString localName = QStringLiteral("voices-pt-2026-02-01-00-00-00.rcc");
        const QString remoteName = remoteNewer ? QStringLiteral("voices-pt-2026-03-01-00-00-00.rcc") : QStringLiteral("voices-pt-2026-01-01-00-00-00.rcc");
        createVoiceRcc(directory + localName, true);
        createVoiceRcc(directory + remoteName, remoteNewer);
        const QByteArray localContents = contentsLine(directory + localName);
        const QByteArray remoteContents = contentsLine(directory + remoteName);
        const QByteArray remoteBytes = fixtureBytes(directory + remoteName);
        QVERIFY(QFile::remove(directory + remoteName));
        QVERIFY(writeFixture(directory + QStringLiteral("Contents"), localContents));
        if (state == QLatin1String("missing")) QVERIFY(QFile::remove(directory + localName));
        else if (state == QLatin1String("corrupt")) QVERIFY(writeFixture(directory + localName, QByteArray("damaged RCC")));
        QTcpServer server;
        QVERIFY(server.listen(QHostAddress::LocalHost));
        QStringList requests;
        const QMap<QString, QByteArray> responses = {
            {'/' + relative + QStringLiteral("Contents"), remoteContents},
            {'/' + relative + remoteName, remoteBytes}
        };
        serveFixtures(server, responses, requests);
        DownloadManager manager;
        const auto cleanup = qScopeGuard([&] {
            const auto resources = manager.registeredResources;
            for (const auto &resource : resources) manager.unregisterResource_locked(resource);
        });
        manager.accessManager.setProxy(QNetworkProxy::NoProxy);
        manager.serverUrl = QUrl(QStringLiteral("http://127.0.0.1:%1").arg(server.serverPort()));
        manager.initializeAssets();
        QSignalSpy completed(&manager, &DownloadManager::downloadFinished);
        QSignalSpy errors(&manager, &DownloadManager::error);
        QVERIFY(manager.downloadResource(GCompris::VOICES, {{QStringLiteral("locale"), QStringLiteral("pt")}}));
        QTRY_COMPARE_WITH_TIMEOUT(completed.size(), 1, 5000);
        QCOMPARE(errors.size(), 0);
        QCOMPARE(manager.getVoicesResourceForLocale(QStringLiteral("pt_PT")), relative + remoteName);
        QCOMPARE(requests, QStringList({'/' + relative + QStringLiteral("Contents"), '/' + relative + remoteName}));
        QCOMPARE(fixtureBytes(directory + remoteName), remoteBytes);
        QVERIFY(QFile::exists(QStringLiteral(":/gcompris/data/voices-ogg/pt/alphabet/U0061.ogg")));
        QCOMPARE(QFile::exists(QStringLiteral(":/gcompris/data/voices-ogg/pt/alphabet/U00E7.ogg")), remoteNewer);
    }

    void test_offlineRestartPrefersNewerCachedIndexOverOlderPackagedIndex_data()
    {
        QTest::addColumn<QString>("state");
        QTest::newRow("valid-cache") << QStringLiteral("valid");
        QTest::newRow("same-filename-different-checksum") << QStringLiteral("collision");
        QTest::newRow("missing-cache") << QStringLiteral("missing");
        QTest::newRow("corrupt-cache") << QStringLiteral("corrupt");
    }

    void test_offlineRestartPrefersNewerCachedIndexOverOlderPackagedIndex()
    {
        QFETCH(QString, state);
        const bool expectedNewer = state == QLatin1String("valid") || state == QLatin1String("collision");
        const QString oldName = QStringLiteral("voices-pt-2026-01-01-00-00-00.rcc");
        const QString fixture = qEnvironmentVariable("GCOMPRIS_RESTART_RESOURCE_FIXTURE");
        const QString relative = QStringLiteral("data3/voices-") + QStringLiteral(COMPRESSED_AUDIO) + '/';
        const QString newName = state == QLatin1String("collision") ? oldName : QStringLiteral("voices-pt-2026-02-01-00-00-00.rcc");
        if (!fixture.isEmpty()) {
            ApplicationSettingsMock::getInstance()->setCachePath(fixture + QStringLiteral("/cache"));
            DownloadManager manager;
            manager.initializeAssets();
            QCOMPARE(manager.getVoicesResourceForLocale(QStringLiteral("pt_PT")), relative + (expectedNewer ? newName : oldName));
            QVERIFY(manager.updateResource(GCompris::VOICES, {{QStringLiteral("locale"), QStringLiteral("pt")}}));
            QCOMPARE(QFile::exists(QStringLiteral(":/gcompris/data/voices-ogg/pt/alphabet/U00E7.ogg")), expectedNewer);
            return;
        }
        QTemporaryDir folder;
        QVERIFY(folder.isValid());
        const QString packaged = QDir::cleanPath(folder.path() + QStringLiteral("/bin/") + QStringLiteral(GCOMPRIS_DATA_FOLDER) + QStringLiteral("/rcc/")) + '/' + relative;
        const QString cached = folder.path() + QStringLiteral("/cache/") + relative;
        QVERIFY(QDir().mkpath(packaged));
        QVERIFY(QDir().mkpath(cached));
        createVoiceRcc(packaged + oldName, false);
        createVoiceRcc(cached + newName, true);
        QVERIFY(writeFixture(packaged + QStringLiteral("Contents"), contentsLine(packaged + oldName)));
        QVERIFY(writeFixture(cached + QStringLiteral("Contents"), contentsLine(cached + newName)));
        if (state == QLatin1String("missing")) QVERIFY(QFile::remove(cached + newName));
        else if (state == QLatin1String("corrupt")) QVERIFY(writeFixture(cached + newName, QByteArray("damaged RCC")));
        const QString child = folder.path() + QStringLiteral("/bin/") + QFileInfo(QCoreApplication::applicationFilePath()).fileName();
        QVERIFY(QDir().mkpath(folder.path() + QStringLiteral("/bin")));
        QVERIFY(QFile::copy(QCoreApplication::applicationFilePath(), child));
        auto environment = QProcessEnvironment::systemEnvironment();
        environment.insert(QStringLiteral("GCOMPRIS_RESTART_RESOURCE_FIXTURE"), folder.path());
        environment.insert(QStringLiteral("PATH"), QCoreApplication::applicationDirPath() + QDir::listSeparator() + environment.value(QStringLiteral("PATH")));
        QProcess process;
        process.setProcessEnvironment(environment);
        process.start(child, {QStringLiteral("test_offlineRestartPrefersNewerCachedIndexOverOlderPackagedIndex:") + QString::fromLatin1(QTest::currentDataTag())});
        QVERIFY(process.waitForFinished(10000));
        QCOMPARE(process.exitStatus(), QProcess::NormalExit);
        const QByteArray output = process.readAllStandardOutput() + process.readAllStandardError();
        QVERIFY2(process.exitCode() == 0, output.constData());
    }

    void test_haveLocalResource_data()
    {
        QTest::addColumn<QString>("resource");
        QTest::addColumn<bool>("expected_success");

        QTest::newRow("invalid.invalid") << "invalid.invalid" << false;
        QTest::newRow("no.no") << "no.no" << false;
        QTest::newRow("money.rcc") << "money.rcc" << true;
        QTest::newRow("penalty.rcc") << "penalty.rcc" << true;
    }
    void test_haveLocalResource()
    {
        QFETCH(QString, resource);
        QFETCH(bool, expected_success);

        QVERIFY(expected_success == downloadManager->haveLocalResource(resource));
    }

    void test_downloadResource_data()
    {
        QTest::addColumn<GCompris::ResourceType>("resource");

        QTest::newRow("wordset") << GCompris::ResourceType::WORDSET;
        QTest::newRow("wordset_2") << GCompris::ResourceType::WORDSET;
    }
    void test_downloadResource()
    {
        QFETCH(GCompris::ResourceType, resource);

        QVERIFY(downloadManager->downloadResource(resource));
        QVERIFY(!downloadManager->downloadResource(resource));
        downloadManager->abortDownloads();
    }

    void test_updateResource_data()
    {
        QTest::addColumn<GCompris::ResourceType>("resource");
        QTest::addColumn<bool>("expected_success");

        QTest::newRow("wordset") << GCompris::ResourceType::WORDSET << false;
        QTest::newRow("none") << GCompris::ResourceType::NONE << false;
    }
    void test_updateResource()
    {
        QFETCH(GCompris::ResourceType, resource);
        QFETCH(bool, expected_success);

       QVERIFY(expected_success == downloadManager->updateResource(resource, {}));
    }

    void test_downloadIsRunning_data()
    {
        QTest::addColumn<GCompris::ResourceType>("resource");

        QTest::newRow("wordset") << GCompris::ResourceType::WORDSET;
    }
    void test_downloadIsRunning()
    {
        QFETCH(GCompris::ResourceType, resource);

        downloadManager->abortDownloads();
        QVERIFY(!downloadManager->downloadIsRunning());
        QVERIFY(downloadManager->downloadResource(resource));
        QVERIFY(downloadManager->downloadIsRunning());
        downloadManager->abortDownloads();
    }

    void test_registerResource_data()
    {
        QTest::addColumn<QString>("resource");
        QTest::addColumn<bool>("expected_success");

        QTest::newRow("invalid.rcc") << "invalid.rcc" << false;
        QTest::newRow("money.rcc") << "money.rcc" << true;
    }
    void test_registerResource()
    {
        QFETCH(QString, resource);
        QFETCH(bool, expected_success);

        QVERIFY(expected_success == downloadManager->registerResource(resource));
    }

    void test_isDataRegistered_data()
    {
        QTest::addColumn<QString>("resource");
        QTest::addColumn<QString>("register_mode");

        QTest::newRow("invalid.rcc") << "invalid.rcc" << "invalid";
        QTest::newRow("mosaic.rcc") << "mosaic.rcc" << "not_registered";
    }
    void test_isDataRegistered()
    {
        QFETCH(QString, resource);
        QFETCH(QString, register_mode);

        if(register_mode == "not_registered") {
            QVERIFY(!downloadManager->isDataRegistered(resource));
        }
        else if(register_mode == "invalid") {
            QVERIFY(!downloadManager->registerResource(resource));
            QVERIFY(!downloadManager->isDataRegistered(resource));
        }
        else {
            QVERIFY(false);
        }
    }
    
private:
    static QByteArray fixtureBytes(const QString &path)
    {
        QFile file(path);
        if (!file.open(QIODevice::ReadOnly)) return {};
        return file.readAll();
    }

    static bool writeFixture(const QString &path, const QByteArray &bytes)
    {
        QFile file(path);
        return file.open(QIODevice::WriteOnly) && file.write(bytes) == bytes.size();
    }

    static QByteArray contentsLine(const QString &path)
    {
        return QCryptographicHash::hash(fixtureBytes(path), QCryptographicHash::Md5).toHex()
            + "  " + QFileInfo(path).fileName().toUtf8() + '\n';
    }

    static void createVoiceRcc(const QString &path, bool withAccent)
    {
        QVERIFY(writeFixture(path + QStringLiteral(".ogg"), QByteArray("OggSoriginal")));
        QVERIFY(writeFixture(path + QStringLiteral(".accent.ogg"), QByteArray("OggSnew-accent")));
        const QByteArray name = QFileInfo(path).fileName().toUtf8();
        const QByteArray locale = QFileInfo(path).fileName().section('-', 1, 1).toUtf8();
        QByteArray xml = "<RCC><qresource prefix=\"/gcompris/data/voices-ogg/" + locale + "\"><file alias=\"alphabet/U0061.ogg\">" + name + ".ogg</file>";
        if (withAccent) xml += "<file alias=\"alphabet/U00E7.ogg\">" + name + ".accent.ogg</file>";
        xml += "</qresource></RCC>";
        QVERIFY(writeFixture(path + QStringLiteral(".qrc"), xml));
        QProcess process;
        const QString rcc = QDir(QLibraryInfo::path(QLibraryInfo::LibraryExecutablesPath)).filePath(QStringLiteral("rcc"));
        process.start(rcc, {QStringLiteral("--binary"), path + QStringLiteral(".qrc"), QStringLiteral("-o"), path});
        QVERIFY(process.waitForFinished(10000));
        QCOMPARE(process.exitCode(), 0);
    }

    static void serveFixtures(QTcpServer &server, const QMap<QString, QByteArray> &responses, QStringList &requests)
    {
        connect(&server, &QTcpServer::newConnection, &server, [&] {
            while (auto *socket = server.nextPendingConnection()) {
                connect(socket, &QTcpSocket::disconnected, socket, &QObject::deleteLater);
                connect(socket, &QTcpSocket::readyRead, socket, [&, socket] {
                    const QByteArray request = socket->property("request").toByteArray() + socket->readAll();
                    if (!request.contains("\r\n\r\n")) {
                        socket->setProperty("request", request);
                        return;
                    }
                    const QString path = QString::fromUtf8(request.split('\n').first().split(' ')[1]);
                    requests.append(path);
                    const QByteArray body = responses.value(path);
                    const QByteArray status = responses.contains(path) ? "200 OK" : "404 Not Found";
                    socket->write("HTTP/1.1 " + status + "\r\nConnection: close\r\nContent-Length: " + QByteArray::number(body.size()) + "\r\n\r\n" + body);
                    socket->disconnectFromHost();
                });
            }
        });
    }

    /**
     * @brief downloadManager The DownloadManager object, that is the test downloadManager
     */
    DownloadManager *downloadManager;
};

QTEST_MAIN(DownloadManagerTest);
#include "DownloadManagerTest.moc"
