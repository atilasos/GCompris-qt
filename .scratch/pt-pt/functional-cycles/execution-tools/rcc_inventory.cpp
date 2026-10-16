// SPDX-License-Identifier: GPL-3.0-or-later
// Inspect the bytes Qt actually exposes, independently of RCC manifests.
#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDirIterator>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QResource>
#include <QTextStream>

int main(int argc, char **argv) {
    QCoreApplication app(argc, argv);
    const auto args = app.arguments();
    if (args.size() < 2 || args.size() > 3) return 2;
    if (!QResource::registerResource(args[1])) {
        QTextStream(stderr) << "Cannot register RCC: " << args[1] << '\n';
        return 1;
    }
    QJsonArray files;
    QDirIterator it(":/", QDir::Files, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        const auto path = it.next();
        QFile file(path);
        if (!file.open(QIODevice::ReadOnly)) return 1;
        const auto data = file.readAll();
        QJsonObject row{{"path", path}, {"bytes", data.size()},
            {"sha256", QString(QCryptographicHash::hash(data, QCryptographicHash::Sha256).toHex())},
            {"ogg", data.startsWith("OggS")}};
        if (args.size() == 3) {
            const auto target = args[2] + "/" + path.mid(2);
            if (!QDir().mkpath(QFileInfo(target).absolutePath())) return 1;
            QFile out(target);
            if (!out.open(QIODevice::WriteOnly) || out.write(data) != data.size()) return 1;
        }
        files.append(row);
    }
    QTextStream(stdout) << QJsonDocument(files).toJson();
    return 0;
}
