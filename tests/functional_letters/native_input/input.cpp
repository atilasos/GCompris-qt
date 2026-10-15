// SPDX-License-Identifier: GPL-3.0-or-later
// Input adapter for QtTest's ASCII-only keyClickChar. No game methods are called.
#include <QCoreApplication>
#include <QInputMethodEvent>
#include <QQmlExtensionPlugin>
#include <QQuickItem>
#include <qqml.h>

class UnicodeInput : public QObject {
    Q_OBJECT
public:
    using QObject::QObject;
    Q_INVOKABLE bool preedit(QQuickItem *target, const QString &text) {
        if (!target) return false;
        target->forceActiveFocus();
        QInputMethodEvent event(text, {});
        return QCoreApplication::sendEvent(target, &event) && event.isAccepted();
    }
    Q_INVOKABLE bool commit(QQuickItem *target, const QString &text) {
        if (!target || text.isEmpty()) return false;
        target->forceActiveFocus();
        QInputMethodEvent event;
        event.setCommitString(text);
        return QCoreApplication::sendEvent(target, &event) && event.isAccepted();
    }
};

class InputPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override {
        qmlRegisterType<UnicodeInput>(uri, 1, 0, "UnicodeInput");
    }
};
#include "input.moc"
