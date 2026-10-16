// SPDX-License-Identifier: GPL-3.0-or-later
#include <QGuiApplication>
#include <QImage>
#include <QPainter>
#include <QSvgRenderer>
#include <QDir>
int main(int argc,char **argv){QGuiApplication app(argc,argv);if(argc!=3)return 2;QStringList names={"1.svg","2.svg","3.svg","4.svg","5.svg","6.svg","7.svg","8.svg","9.svg","circle.svg","rectangle.svg","rhombus.svg","star.svg","triangle.svg"};QImage image(640,640,QImage::Format_ARGB32);image.fill(Qt::white);QPainter painter(&image);for(int i=0;i<names.size();i++){QSvgRenderer svg(QString(argv[1])+"/"+names[i]);if(!svg.isValid())return 1;svg.render(&painter,QRectF((i%4)*160+20,(i/4)*160+10,120,120));painter.drawText(QRectF((i%4)*160,(i/4)*160+135,160,20),Qt::AlignCenter,names[i]);}return image.save(argv[2])?0:1;}
