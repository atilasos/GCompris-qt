/* GCompris - StartupLogging.h
 *
 * SPDX-FileCopyrightText: 2026 Igor Almeida
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef STARTUPLOGGING_H
#define STARTUPLOGGING_H

#include <QElapsedTimer>
#include <QLoggingCategory>
#include <QString>

/**
 * Startup timings, disabled by default.
 * Enable with QT_LOGGING_RULES="gcompris.startup.info=true".
 */
Q_DECLARE_LOGGING_CATEGORY(lcStartup)

inline QString startupMilliseconds(qint64 nanoseconds)
{
    return QString::number(nanoseconds / 1e6, 'f', 1);
}

#endif
