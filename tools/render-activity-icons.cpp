// SPDX-License-Identifier: GPL-3.0-or-later
// Render one actual SVG or a contact sheet using the application's Qt SVG backend.
// c++ -std=c++17 -fPIC tools/render-activity-icons.cpp $(pkg-config --cflags --libs Qt6Svg Qt6Gui) -o /tmp/render-icons
// QT_QPA_PLATFORM=offscreen /tmp/render-icons --single icon.svg icon.png
// QT_QPA_PLATFORM=offscreen /tmp/render-icons icon-paths.txt contact-sheet.png
#include <QFile>
#include <QFont>
#include <QGuiApplication>
#include <QImage>
#include <QPainter>
#include <QSvgRenderer>

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    if (argc == 4 && QString::fromLocal8Bit(argv[1]) == "--single") {
        QSvgRenderer svg(QString::fromLocal8Bit(argv[2]));
        if (!svg.isValid()) return 1;
        QImage image(400, 400, QImage::Format_ARGB32_Premultiplied);
        image.fill(Qt::transparent);
        QPainter painter(&image);
        svg.render(&painter);
        painter.end();
        return image.save(QString::fromLocal8Bit(argv[3])) ? 0 : 1;
    }
    if (argc != 3) return 2;
    QFile list(QString::fromLocal8Bit(argv[1]));
    if (!list.open(QIODevice::ReadOnly)) return 1;
    const auto paths = QString::fromUtf8(list.readAll()).trimmed().split('\n');
    QImage image(1000, ((paths.size() + 9) / 10) * 120, QImage::Format_ARGB32_Premultiplied);
    image.fill(QColor("#dddddd"));
    QPainter painter(&image);
    QFont font;
    font.setPixelSize(9);
    painter.setFont(font);
    for (int i = 0; i < paths.size(); ++i) {
        QSvgRenderer svg(paths[i]);
        if (!svg.isValid()) return 1;
        const int x = (i % 10) * 100, y = (i / 10) * 120;
        svg.render(&painter, QRectF(x, y, 100, 100));
        painter.setPen(Qt::black);
        painter.drawText(QRectF(x, y + 100, 100, 20), Qt::AlignCenter,
                         paths[i].split('/').last().chopped(4));
    }
    painter.end();
    return image.save(QString::fromLocal8Bit(argv[2])) ? 0 : 1;
}
