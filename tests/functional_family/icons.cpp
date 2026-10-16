// SPDX-License-Identifier: GPL-3.0-or-later
#include <QGuiApplication>
#include <QImage>
#include <QPainter>
#include <QSvgRenderer>
#include <QDir>
int main(int argc,char **argv){QGuiApplication app(argc,argv);if(argc!=3)return 2;QStringList names={"babyBoy.svg","babyGirl.svg","boy1.svg","boy2.svg","girl1.svg","man1.svg","man2.svg","man3.svg","oldMan1.svg","oldWoman1.svg","woman1.svg","woman2.svg"};QImage image(640,480,QImage::Format_ARGB32);image.fill(Qt::white);QPainter painter(&image);for(int i=0;i<names.size();i++){QSvgRenderer svg(QString(argv[1])+"/"+names[i]);if(!svg.isValid())return 1;svg.render(&painter,QRectF((i%4)*160+20,(i/4)*160+10,120,120));painter.drawText(QRectF((i%4)*160,(i/4)*160+135,160,20),Qt::AlignCenter,names[i]);}return image.save(argv[2])?0:1;}
