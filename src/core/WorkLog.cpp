/* GCompris - WorkLog.cpp
 *
 * SPDX-FileCopyrightText: 2026 GCompris contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "WorkLog.h"

WorkLog::WorkLog(QObject *parent) : QObject(parent)
{
}

WorkLog *WorkLog::create(QQmlEngine *, QJSEngine *)
{
    return new WorkLog();
}

QVariantList WorkLog::entries() const
{
    QVariantList result;
    for (const Entry &entry : m_entries) {
        result.append(QVariantMap{{QStringLiteral("activityId"), entry.activityId},
                                  {QStringLiteral("hasRounds"), entry.rounds > 0},
                                  {QStringLiteral("rounds"), entry.rounds}});
    }
    return result;
}

void WorkLog::activityStarted(const QString &activityId)
{
    if (activityId.isEmpty() || activityId == QStringLiteral("menu/Menu.qml"))
        return;
    for (int i = 0; i < m_entries.size(); ++i) {
        if (m_entries[i].activityId == activityId) {
            m_currentEntry = i;
            return;
        }
    }
    m_currentEntry = m_entries.size();
    m_entries.append({activityId, 0});
    Q_EMIT entriesChanged();
}

void WorkLog::roundCompleted()
{
    if (m_currentEntry < 0)
        return;
    ++m_entries[m_currentEntry].rounds;
    Q_EMIT entriesChanged();
}

void WorkLog::clear()
{
    m_currentEntry = -1;
    m_entries.clear();
    Q_EMIT entriesChanged();
}
