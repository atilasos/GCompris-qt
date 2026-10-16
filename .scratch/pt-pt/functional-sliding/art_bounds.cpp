// SPDX-License-Identifier: GPL-3.0-or-later
#include <QGuiApplication>
#include <QSvgRenderer>
#include <QImage>
#include <QPainter>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTextStream>
int main(int argc,char **argv) {
    QGuiApplication app(argc,argv);
    if(argc!=3) return 2;
    QSvgRenderer renderer(QString::fromLocal8Bit(argv[1]));
    if(!renderer.isValid()) return 1;
    QImage image(renderer.defaultSize(),QImage::Format_ARGB32_Premultiplied);
    image.fill(Qt::transparent);
    QPainter painter(&image);
    renderer.render(&painter);
    painter.end();
    if(!image.save(QString::fromLocal8Bit(argv[2]))) return 1;
    QJsonArray rows;
    for(const auto &id: {QStringLiteral("text136"),QStringLiteral("text137"),QStringLiteral("text138"),QStringLiteral("text139")}) {
        const auto bounds=renderer.transformForElement(id).mapRect(renderer.boundsOnElement(id));
        rows.append(QJsonObject{{"id",id},{"x",bounds.x()},{"y",bounds.y()},{"width",bounds.width()},{"height",bounds.height()}});
    }
    QTextStream(stdout)<<QJsonDocument(rows).toJson();
}
