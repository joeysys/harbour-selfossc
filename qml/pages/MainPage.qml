import QtQuick 2.2
import Sailfish.Silica 1.0

import '../js/selfoss.js' as Selfoss

Page {
    id: page

    property bool allLoaded: false
    property string tag
    property int sourceId

    property int currentPage: 0
    property var currentIds: JSON.parse('{ "unread": [], "newest": [], "starred": [] }')

    property bool _showThumbs: settings.showThumbs
    property string _showText: qsTr("Show thumbnails")
    property string _hideText: qsTr("Hide thumbnails")

    function toggleThumbs(thumb) {
        if (typeof(thumb) === 'boolean') {
            _showThumbs = thumb;
        } else {
            _showThumbs = !_showThumbs;
        }
        thumbMenu.text = _showThumbs ? _hideText : _showText;
    }

    function setSource() {
        tag = '';
        sourceId = 0;
        if (sourceIndex > 0) {
            sourceId = sourceModel.get(sourceIndex-1).id;
        } else if (tagIndex > 0) {
            tag = tagList[tagIndex-1].tag;
        }
    }

    function reloadItems() {
        if (!Selfoss.site) {
            console.warn('Site is empty.');
            pageStack.push("SettingsPage.qml");
            return;
        }

        if (requestLock) {
            console.log('blocked ...');
            return;
        }
        requestLock = true;
        allLoaded = false;
        currentModel.clear();
        currentPage = 0;
        currentIds[type] = [];
        setSource();
        if (settings.debug) console.log('reloading items:', type, tag, sourceId);
        Selfoss.listItems(type, currentPage, addToModel, tag, sourceId);
        updateStats();
    }

    function addToModel(items) {
        requestLock = false;
        if (!Array.isArray(items)) {
            console.warn('Response is not array:', items.msg);
            return;
        }
        if (items.length < pageItems) { allLoaded = true; }
        var checkDup = true;
        if (settings.debug) console.log('adding to model', items.length);
        for ( var i in items ) {
            var item = items[i];
            if (checkDup) {
                if (currentIds[type].indexOf(item.id) >= 0) {
                    continue;
                } else {
                    checkDup = false;
                }
            }
            // Twitter spout
            if ( item.author === '' && item.link.indexOf('twitter.com') > 0 ) {
                var de = item.title.indexOf(':<br');
                item.author = item.title.substr(0, de);
                item.title = item.title.substr(de+7);
                // Remove preview link in title
                if (item.thumbnail) {
                    item.title = Selfoss.removeTitleImage(item.title)
                }
            }

            currentModel.append(item);
            currentIds[type].push(item.id);
        }
    }

    SilicaListView {
        id: mainListView
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    pageStack.push("SettingsPage.qml");
                }
            }
            MenuItem {
                id: thumbMenu
                text: _showThumbs ? _hideText : _showText;
                onClicked: toggleThumbs()
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: reloadItems()
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Mark all as read")
                visible: allLoaded
                onClicked: {
                    if (requestLock) {
                        console.log('blocked ...');
                        return;
                    }
                    requestLock = true;
                    Selfoss.markAllRead(currentIds[type], function(resp) {
                        requestLock = false;
                        if (resp && resp.success) {
                            reloadItems();
                        } else {
                            console.warn('Mark all as read failed!');
                        }
                    })
                }
            }
            MenuItem {
                text: qsTr("Top")
                onClicked: mainListView.scrollToTop()
            }
        }

        header: PageHeader {
            title: {
                switch (type) {
                    case 'unread':
                        return qsTr("Unread") + ' | ' + subtitle;
                    case 'newest':
                        return qsTr("Newest") + ' | ' + subtitle;
                    case 'starred':
                        return qsTr("Starred") + ' | ' + subtitle;
                    default:
                        return qsTr("Unknown") + ' | ' + subtitle;
                }
            }
        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: requestLock || (!currentModel.count && !allLoaded)
        }

        model: currentModel

        delegate: ListItemComponent {
            _showThumb: _showThumbs
            item: currentModel.get(index)
        }

        onAtYEndChanged: {
            if (mainListView.atYEnd) {
                if (settings.debug) console.log('at y end');
                if ( !requestLock && status === PageStatus.Active &&
                        currentModel && currentModel.count > 0 && !allLoaded) {
                    if (settings.debug) console.log('loading more');
                    requestLock = true;
                    currentPage += 1;
                    Selfoss.listItems(type, currentPage, addToModel, tag, sourceId);
                }
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            pageStack.pushAttached('FilterDialog.qml');
            if (!Selfoss.site) {
                console.warn('Site is empty.');
                pageStack.push("SettingsPage.qml");
            } else if (forceReload) {
                page.reloadItems();
                forceReload = false;
            }
        }
    }

    Component.onCompleted: {
        Selfoss.readSettings();
        if (!currentModel) currentModel = unreadModel;
        reloadItems();

        // for cover action
        exportFn('reload', reloadItems);
        exportFn('toggleThumbs', toggleThumbs);
    }
}


