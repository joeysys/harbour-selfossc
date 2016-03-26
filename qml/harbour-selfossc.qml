import QtQuick 2.2
import Sailfish.Silica 1.0
import "pages"

import 'js/selfoss.js' as Selfoss

ApplicationWindow
{
    property bool requestLock: false
    property bool forceReload: false
    property int pageItems: 20
    property bool debug: false

    property string type: 'unread'
    property int tagIndex: 0
    property int sourceIndex: 0
    property int statsUnread: 0
    property var currentModel

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
            if (debug) console.log('add tags', tags.length);
            tagsModel.clear();
            for (var i in tags) {
                tagsModel.append(tags[i]);
            }
        });
        Selfoss.listSources(function(srcs) {
            if (debug) console.log('add srcs', srcs.length);
            sources = srcs;
            sourceModel.clear();
            for (var i in srcs) {
                sourceModel.append(srcs[i]);
            }
        });
        Selfoss.getStats(function(resp) {
            if (debug) console.log(JSON.stringify(resp));
            statsUnread = resp.unread - 0;
        });
    }

}