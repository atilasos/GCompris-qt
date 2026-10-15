/* GCompris - ApplicationInfoTest.cpp
 *
 * SPDX-FileCopyrightText: 2018 Billy Laws <blaws05@gmail.com>
 * GCompris  (C) 2018 GCompris Developers  <gcompris-devel@kde.org>
 *
 * Authors:
 *   Billy Laws <blaws05@gmail.com>
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QObject>
#include <QProcess>
#include <QProcessEnvironment>
#include <QTest>

#include "src/core/ApplicationInfo.h"

class ApplicationInfoTest : public QObject
{
public:
    Q_OBJECT
private Q_SLOTS:
    void LocaleTest_data();
    void LocaleTest();
    void WindowTest_data();
    void WindowTest();

#ifdef Q_OS_UNIX
    void systemVoicesLocaleTest_data();
    void systemVoicesLocaleTest();
#endif
    void getVoicesLocaleTest_data();
    void getVoicesLocaleTest();
    void getAudioFilePathForLocaleTest_data();
    void getAudioFilePathForLocaleTest();
};

void ApplicationInfoTest::LocaleTest_data()
{
    QTest::addColumn<QString>("localeFull");
    QTest::addColumn<QString>("localeShort");
    QTest::addColumn<QString>("higherWord");
    QTest::addColumn<QString>("lowerWord");
    QTest::newRow("British English") << QStringLiteral("en_GB")
                                     << QStringLiteral("en")
                                     << QStringLiteral("apple")
                                     << QStringLiteral("banana");
}

void ApplicationInfoTest::LocaleTest()
{
    ApplicationInfo appInfo;
    ApplicationInfo::getInstance();

    QFETCH(QString, localeFull);
    QFETCH(QString, localeShort);
    QFETCH(QString, higherWord);
    QFETCH(QString, lowerWord);

    QVERIFY(appInfo.localeShort(localeFull) == localeShort);
    QVERIFY(appInfo.localeCompare(higherWord, lowerWord, localeFull) == -1);
    QVERIFY(appInfo.localeCompare(lowerWord, higherWord, localeFull) == 1);
    QVERIFY(appInfo.localeCompare(higherWord, higherWord, localeFull) == 0);

    QVariantList sortList;
	
    sortList.append(QVariant(higherWord));
    sortList.append(QVariant(lowerWord));
    sortList.append(QVariant(higherWord));
    sortList.append(QVariant(lowerWord));

    sortList = appInfo.localeSort(sortList, localeFull);

    QVERIFY(sortList[0] == higherWord);
    QVERIFY(sortList[1] == higherWord);
    QVERIFY(sortList[2] == lowerWord);
    QVERIFY(sortList[3] == lowerWord);
}

void ApplicationInfoTest::WindowTest_data()
{
    QTest::addColumn<bool>("useSoftwareRenderer");
    QTest::addColumn<int>("applicationWidth");
    QTest::addColumn<bool>("portraitMode");
    QTest::newRow("dummy1") << true
                            << 1920
                            << true;
}

void ApplicationInfoTest::WindowTest()
{
    ApplicationInfo appInfo;
    ApplicationInfo::getInstance();

    QFETCH(bool, useSoftwareRenderer);
    QFETCH(int, applicationWidth);
    QFETCH(bool, portraitMode);

    appInfo.setApplicationWidth(applicationWidth);
    appInfo.setIsPortraitMode(portraitMode);
    appInfo.setUseSoftwareRenderer(useSoftwareRenderer);

    QVERIFY(appInfo.useSoftwareRenderer() == useSoftwareRenderer);
    QVERIFY(appInfo.applicationWidth() == applicationWidth);
    QVERIFY(appInfo.isPortraitMode() == portraitMode);
}

// POSIX locale environment fixtures do not select the Windows system locale.
#ifdef Q_OS_UNIX
void ApplicationInfoTest::systemVoicesLocaleTest_data()
{
    QTest::addColumn<QString>("systemLocale");
    QTest::addColumn<QString>("localeName");
    QTest::addColumn<QString>("expected");
    QTest::newRow("C fallback") << "C" << "C" << "en_US";
    QTest::newRow("Portugal") << "pt_PT.UTF-8" << "pt_PT" << "pt";
    QTest::newRow("United States") << "en_US.UTF-8" << "en_US" << "en_US";
    QTest::newRow("United Kingdom") << "en_GB.UTF-8" << "en_GB" << "en_GB";
    QTest::newRow("Brazil") << "pt_BR.UTF-8" << "pt_BR" << "pt_BR";
    QTest::newRow("France") << "fr_FR.UTF-8" << "fr_FR" << "fr";
}

void ApplicationInfoTest::systemVoicesLocaleTest()
{
    QFETCH(QString, systemLocale);
    QFETCH(QString, localeName);
    QFETCH(QString, expected);

    // QLocale caches the system locale. Start a fresh process for each fixture
    // rather than changing the application's process-wide default locale.
    QProcess child;
    auto environment = QProcessEnvironment::systemEnvironment();
    environment.insert(QStringLiteral("LC_ALL"), systemLocale);
    environment.insert(QStringLiteral("LANG"), systemLocale);
    environment.remove(QStringLiteral("LANGUAGE"));
    environment.insert(QStringLiteral("GCOMPRIS_TEST_SYSTEM_LOCALE_NAME"), localeName);
    environment.insert(QStringLiteral("GCOMPRIS_TEST_SYSTEM_VOICES_EXPECTED"), expected);
    child.setProcessEnvironment(environment);
    child.setProcessChannelMode(QProcess::MergedChannels);
    child.start(QCoreApplication::applicationFilePath(),
                {QStringLiteral("getVoicesLocaleTest:system-default")});
    QVERIFY2(child.waitForFinished(30000), qPrintable(child.errorString()));
    const QByteArray output = child.readAll();
    QVERIFY2(child.exitStatus() == QProcess::NormalExit, output.constData());
    QVERIFY2(child.exitCode() == 0, output.constData());
}

#endif

void ApplicationInfoTest::getVoicesLocaleTest_data()
{
    QTest::addColumn<QString>("actual");
    QTest::addColumn<QString>("expected");
    // This row is executed by systemVoicesLocaleTest in a fresh process with
    // a known system locale. Expected values come from its independent table.
    if (qEnvironmentVariableIsSet("GCOMPRIS_TEST_SYSTEM_VOICES_EXPECTED")) {
        QTest::newRow("system-default") << GC_DEFAULT_LOCALE
            << qEnvironmentVariable("GCOMPRIS_TEST_SYSTEM_VOICES_EXPECTED");
    }
    QTest::newRow("en_US") << "en_US"
                           << "en_US";
    QTest::newRow("pt_BR") << "pt_BR"
                           << "pt_BR";
    QTest::newRow("pt_PT") << "pt_PT"
                           << "pt";
    QTest::newRow("fr_FR") << "fr_FR"
                           << "fr";
}

void ApplicationInfoTest::getVoicesLocaleTest()
{
    ApplicationInfo appInfo;
    ApplicationInfo::getInstance();

    QFETCH(QString, actual);
    QFETCH(QString, expected);

    if (actual == GC_DEFAULT_LOCALE) {
        QCOMPARE(QLocale::system().name(), qEnvironmentVariable("GCOMPRIS_TEST_SYSTEM_LOCALE_NAME"));
    }
    QCOMPARE(appInfo.getVoicesLocale(actual), expected);
}

void ApplicationInfoTest::getAudioFilePathForLocaleTest_data()
{
    QTest::addColumn<QString>("file");
    QTest::addColumn<QString>("locale");
    QTest::addColumn<QString>("expected");
    QTest::newRow("absolutePath_en") << "/$LOCALE/$CA"
                                        << "en"
                                        << QString("/en/%1").arg(COMPRESSED_AUDIO);
    QTest::newRow("absolutePath_pt_BR") << "qrc:/$LOCALE/test"
                                        << "pt_BR"
                                        << "qrc:/pt_BR/test";
    QTest::newRow("absolute_fr") << ":/test/test2"
                                 << "unused"
                                 << ":/test/test2";
    QTest::newRow("relative_fr") << "$LOCALE/$CA"
                                 << "fr"
                                 << QString("qrc:/gcompris/data/fr/%1").arg(COMPRESSED_AUDIO);
}

void ApplicationInfoTest::getAudioFilePathForLocaleTest()
{
    ApplicationInfo appInfo;
    ApplicationInfo::getInstance();

    QFETCH(QString, file);
    QFETCH(QString, locale);
    QFETCH(QString, expected);

    QCOMPARE(appInfo.getAudioFilePathForLocale(file, locale), expected);
}

QTEST_MAIN(ApplicationInfoTest)
#include "ApplicationInfoTest.moc"
