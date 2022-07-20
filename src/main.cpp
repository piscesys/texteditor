#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QMetaObject>
#include <QDir>

#include "documenthandler.h"
#include "highlightmodel.h"
#include "texteditor.h"

QStringList formatUriList(const QStringList &list)
{
    QStringList val;

    for (const QString &i : list) {
        QDir path(i);
        QString absPath = path.absolutePath();
        if(!val.contains(absPath, Qt::CaseSensitive))
            val.append(absPath);
    }

    return val;
}

void openFile(QObject *qmlObj, QString &fileUrl) {
    QVariant val_return;
    QVariant val_arg(fileUrl);
    QMetaObject::invokeMethod(qmlObj,
                            "addPath",
                            Q_RETURN_ARG(QVariant,val_return),
                            Q_ARG(QVariant,val_arg));
}

void newTab(QObject *qmlObj) {
    QVariant val_return;
    QVariant val_arg;
    QMetaObject::invokeMethod(qmlObj,
                            "addTab",
                            Q_RETURN_ARG(QVariant,val_return));
}

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    qmlRegisterType<DocumentHandler>("Pisces.TextEditor", 1, 0, "DocumentHandler");
    qmlRegisterType<FileHelper>("Pisces.TextEditor", 1, 0, "FileHelper");

    QCommandLineParser parser;
    parser.setApplicationDescription("A simple text editor designed for Piscesys.");
    parser.addHelpOption();
    parser.setSingleDashWordOptionMode(QCommandLineParser::ParseAsCompactedShortOptions);
    parser.addPositionalArgument("files", "Files", "[FILE1, FILE2,...]");

    parser.process(app);

    HighlightModel m;

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    QObject *root = engine.rootObjects().first();

    if (!parser.positionalArguments().isEmpty()) {
        QStringList fileList = formatUriList(parser.positionalArguments());
        for (QString &i : fileList) {
            QString fi = "file://" + i;
            openFile(root, fi);
        }
    }
    else newTab(root);

    return app.exec();
}
