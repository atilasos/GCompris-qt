/* GCompris - WorkLog.h
 *
 * SPDX-FileCopyrightText: 2026 GCompris contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#ifndef WORKLOG_H
#define WORKLOG_H

#include <QObject>
#include <QVariantList>
#include <QList>
#include <QtQml/qqmlregistration.h>
#include <config.h>

class QQmlEngine;
class QJSEngine;

// Session-only notes for copying to the pupil's paper work plan.
// This class deliberately has no settings, filesystem or progress dependency.
class WorkLog : public QObject
{
    Q_OBJECT
#ifndef WITH_RCC
    QML_ELEMENT
    QML_SINGLETON
#endif
    Q_PROPERTY(QVariantList entries READ entries NOTIFY entriesChanged)

public:
    explicit WorkLog(QObject *parent = nullptr);
    static WorkLog *create(QQmlEngine *engine, QJSEngine *scriptEngine);
    QVariantList entries() const;

    Q_INVOKABLE void activityStarted(const QString &activityId);
    Q_INVOKABLE void roundCompleted();
    Q_INVOKABLE void clear();

Q_SIGNALS:
    void entriesChanged();

private:
    struct Entry {
        QString activityId;
        int rounds = 0;
    };
    QList<Entry> m_entries;
    int m_currentEntry = -1;
};

#endif // WORKLOG_H
