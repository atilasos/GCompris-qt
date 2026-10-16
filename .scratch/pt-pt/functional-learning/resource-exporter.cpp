// SPDX-License-Identifier: GPL-3.0-or-later
#include <QCoreApplication>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QResource>
#include <QCryptographicHash>
#include <iostream>
int main(int argc,char **argv) {
    QCoreApplication app(argc,argv);
    if(argc!=3)return 2;
    const QString prefix=QString::fromLocal8Bit(argv[1]);
    const QString output=QString::fromLocal8Bit(argv[2]);
    if(QFile::exists(output)||!QDir().mkpath(output))return 3;
    QDirIterator rcc(prefix+"/share/gcompris-qt/rcc",{"*.rcc"},QDir::Files,QDirIterator::Subdirectories);
    while(rcc.hasNext())if(!QResource::registerResource(rcc.next()))return 4;
    QStringList names={":/gcompris/src/activities/braille_fun/resource/hillside.svg",
                       ":/gcompris/src/core/resource/sounds/completetask.wav",
                       ":/gcompris/src/core/resource/sounds/crash.wav"};
    for(int n=0;n<10;++n){
        names<<QString(":/gcompris/src/activities/learn_digits/resource/dots-%1.svg").arg(n);
        names<<QString(":/gcompris/src/activities/learn_digits/resource/hands-%1.svg").arg(n);
        names<<QString(":/gcompris/data/voices-ogg/pt/alphabet/U003%1.ogg").arg(n);
    }
    QJsonArray records;
    for(const auto &name:names){
        QFile file(name);if(!file.open(QIODevice::ReadOnly)){std::cerr<<name.toStdString();return 5;}
        const QByteArray data=file.readAll();const auto base=QFileInfo(name).fileName();
        QFile target(output+"/"+base);if(!target.open(QIODevice::WriteOnly)||target.write(data)!=data.size())return 6;
        records.append(QJsonObject{{"resource",name},{"file",base},{"bytes",data.size()},{"sha256",QString::fromLatin1(QCryptographicHash::hash(data,QCryptographicHash::Sha256).toHex())}});
    }
    std::cout<<QJsonDocument(records).toJson().toStdString();
}
