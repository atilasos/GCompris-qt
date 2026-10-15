// SPDX-License-Identifier: GPL-3.0-or-later
#include <QCoreApplication>
#include <QFile>
#include <QJSEngine>
#include <QTextStream>
#include <QTranslator>
int main(int argc,char **argv) {
    QCoreApplication app(argc,argv);
    if(argc!=3)return 2;
    QFile source(argv[1]);if(!source.open(QIODevice::ReadOnly))return 3;
    QTranslator translator;
    if(QString(argv[2])!="-") {
        if(!translator.load(argv[2]))return 4;
        app.installTranslator(&translator);
    }
    QString code;
    for(const QString &line:QString::fromUtf8(source.readAll()).split('\n'))
        if(!line.startsWith(".pragma"))code+=line+'\n';
    QJSEngine engine;
    engine.installExtensions(QJSEngine::TranslationExtension);
    QJSValue result=engine.evaluate(code,argv[1]);
    if(result.isError()){QTextStream(stderr)<<result.toString();return 5;}
    result=engine.evaluate("JSON.stringify({labels:labels(),memory:format('math numeration'),maze:format('puzzle maze'),unknown:format('future-tag'),empty:format('')})");
    if(result.isError()){QTextStream(stderr)<<result.toString();return 6;}
    QTextStream(stdout)<<result.toString()<<'\n';
}
