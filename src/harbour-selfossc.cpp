#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QScopedPointer>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlEngine>
#include <QQmlContext>

#include <sailfishapp.h>

#include "customnetworkaccessmanager.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    CustomNetworkAccessManagerFactory namf;
    view->engine()->setNetworkAccessManagerFactory(&namf);
    view->rootContext()->setContextProperty("networkManager", view->engine()->networkAccessManager());

    view->setSource(SailfishApp::pathTo("qml/harbour-selfossc.qml"));
    view->show();

    return app->exec();
}
