import QtQuick 2.2
import Sailfish.Silica 1.0
import "pages"

import 'js/selfoss.js' as Selfoss
import "js/storage.js" as Storage

ApplicationWindow
{
    property bool requestLock: false
    property bool forceReload: false
    property int pageItems: 20

    property var settings: readLocalSettings()

    property string type: 'unread'
    property int tagIndex: 0
    property int sourceIndex: 0
    property int statsUnread: 0
    property var currentModel
    property var exportFns
    property var tagList: []

    ListModel { id: unreadModel }
    ListModel { id: newestModel }
    ListModel { id: starredModel }
    ListModel { id: customModel }

    // Tags & Sources
    property string subtitle: qsTr("All")
    property var sources: []
    ListModel { id: tagsModel }
    ListModel { id: sourceModel }


    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All


    function updateStats() {
        Selfoss.listTags(function(tags) {
            if (settings.debug) console.log('add tags', tags.length);
            tagList = tags;
            var orderedTags = tags.slice().sort(function(a, b) {
                return b.unread - a.unread;
            });
            tagsModel.clear();
            for (var i in orderedTags) {
                tagsModel.append(orderedTags[i]);
            }
        });
        Selfoss.listSources(function(srcs) {
            if (settings.debug) console.log('add srcs', srcs.length);
            sources = srcs;
            sourceModel.clear();
            for (var i in srcs) {
                sourceModel.append(srcs[i]);
            }
        });
        Selfoss.getStats(function(resp) {
            if (settings.debug) console.log(JSON.stringify(resp));
            statsUnread = resp.unread - 0;
        });
    }

    function exportFn(name, fn) {
        if (!exportFns) { exportFns = {}; }
        exportFns[name] = fn;
    }

    function readLocalSettings() {
        var _settings = {};
        _settings.debug = Storage.readSetting('debug');
        _settings.showThumbs = Storage.readSetting('thumb');
        _settings.noScaling = Storage.readSetting('noScaling');
        return _settings;
    }
}
