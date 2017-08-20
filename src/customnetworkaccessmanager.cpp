#include <QNetworkDiskCache>
#include <QStandardPaths>
#include <QDir>

#include "customnetworkaccessmanager.h"

/**
 * @brief CustomNetworkAccessManagerFactory::create
 * @param parent
 * @return
 */
QNetworkAccessManager *CustomNetworkAccessManagerFactory::create(QObject *parent)
{
    QNetworkAccessManager *nam = new CustomNetworkAccessManager(parent);

    QNetworkDiskCache *diskCache = new QNetworkDiskCache(parent);
    QString dataPath = QStandardPaths::standardLocations(QStandardPaths::CacheLocation).at(0);
    QDir dir(dataPath);
    if (!dir.exists()) dir.mkpath(dir.absolutePath());

    diskCache->setCacheDirectory(dataPath);
    diskCache->setMaximumCacheSize(30*1024*1024);
    nam->setCache(diskCache);

    return nam;
}


/**
 * @brief CustomNetworkAccessManager::CustomNetworkAccessManager
 * @param parent
 */
CustomNetworkAccessManager::CustomNetworkAccessManager(QObject *parent) : QNetworkAccessManager(parent)
{
}

/**
 * @brief CustomNetworkAccessManager::createRequest
 * @param op
 * @param request
 * @param outgoingData
 * @return
 */
QNetworkReply *CustomNetworkAccessManager::createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData)
{

    QNetworkRequest rqst(request);
    QString url = rqst.url().toString();

    if (url.contains("/favicons/") || url.contains("/thumbnails/"))
    {
        rqst.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
    }
    else
    {
        rqst.setAttribute(QNetworkRequest::CacheSaveControlAttribute, false);
    }

    QNetworkReply *reply = QNetworkAccessManager::createRequest(op, rqst, outgoingData);

    return reply;
}

/**
 * @brief CustomNetworkAccessManager::clearCache
 */
void CustomNetworkAccessManager::clearCache()
{
    this->cache()->clear();
}
