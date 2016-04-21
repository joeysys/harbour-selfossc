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


    function setSource() {
        tag = '';
        sourceId = 0;
        if (sourceIndex > 0) {
            sourceId = sourceModel.get(sourceIndex-1).id;
        } else if (tagIndex > 0) {
            tag = tagsModel.get(tagIndex-1).tag;
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
        if (debug) console.log('reloading items:', type, tag, sourceId);
        Selfoss.listItems(type, currentPage, addToModel, tag, sourceId);
    }

    function addToModel(items) {
        requestLock = false;
        if (!Array.isArray(items)) {
            console.warn('Response is not array:', items.msg);
            return;
        }
        if (items.length < pageItems) { allLoaded = true; }
        var checkDup = true;
        if (debug) console.log('adding to model', items.length);
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
                    var _idx = item.title.lastIndexOf(' <a href="https://t.co');
                    item.title = item.title.substr(0, _idx); // no content => -1
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
                        if (resp.success) {
                            reloadItems();
                            updateStats();
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

        delegate: ListItem {
            width: parent.width
            contentHeight: itemContent.height + Theme.paddingMedium * 3

            menu: ContextMenu {
                MenuItem {
                    text: starred === "0" ? qsTr("Star") : qsTr("Unstar")
                    onClicked: {
                        var stat = (starred === "0") ? 'starr' : 'unstarr';
                        Selfoss.toggleStat(stat, id, function(resp) {
                            if (resp.success) {
                                currentModel.get(index).starred = (starred === "0" ? "1" : "0")
                            }
                        });
                    }
                }
                MenuItem  {
                    text: unread === "0" ? qsTr("Mark as unread") : qsTr("Mark as read")
                    onClicked: {
                        var stat = (unread === "0") ? 'unread' : 'read';
                        Selfoss.toggleStat(stat, id, function(resp) {
                            if (resp.success) {
                                if (unread === "0") {
                                    currentModel.get(index).unread = "1";
                                    statsUnread += 1;
                                } else {
                                    currentModel.get(index).unread = "0";
                                    statsUnread -= 1;
                                }
                            }
                        });
                    }
                }
                MenuItem {
                    text: qsTr("Open in Browser")
                    onClicked: {
                        Qt.openUrlExternally(link);
                    }
                }
            }

            Item {
                id: itemContent
                width: parent.width - Theme.paddingMedium * 2
                height: childrenRect.height
                anchors.top: parent.top
                anchors.topMargin: Theme.paddingMedium
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: itemIcon
                    height: Theme.iconSizeSmall
                    width: height
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: Theme.paddingSmall
                    source: Selfoss.site + '/favicons/' + icon
                }
                Image {
                    id: thumbIcon
                    anchors.top: parent.top
                    anchors.topMargin: Theme.paddingSmall
                    anchors.right: parent.right
                    height: Theme.iconSizeSmall
                    width: height
                    source: "image://theme/icon-m-image"
                    visible: thumbnail
                }
                Label {
                    id: authorLabel
                    anchors.left: itemIcon.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: parent.top
                    anchors.topMargin: Theme.paddingSmall / 2
                    width: parent.width - itemIcon.width - thumbIcon.width - Theme.paddingMedium
                    height: Theme.fontSizeSmall
                    text: author
                    color: unread === "0" ? Theme.secondaryColor : Theme.primaryColor
                    font.bold: true
                    font.pixelSize: Theme.fontSizeSmall
                    elide: TruncationMode.Elide
                }
                Label {
                    id: titleLabel
                    anchors.top: authorLabel.bottom
                    anchors.left: parent.left
                    anchors.topMargin: Theme.paddingMedium
                    width: parent.width
                    text: title
                    wrapMode: Text.WordWrap
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeSmall
                    color: unread === "0" ? Theme.secondaryColor : Theme.primaryColor
                    linkColor: Theme.secondaryColor
                    onLinkActivated: {
                        // TODO confirm dialog
                        Qt.openUrlExternally(link);
                    }
                    Component.onCompleted: {
                        if (!title) titleLabel.height = 0;
                    }
                }
                Label {
                    id: sourceLabel
                    anchors.top: titleLabel.bottom
                    anchors.left: parent.left
                    height: Theme.fontSizeSmall
                    text: qsTr("via ") + sourcetitle
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
                Label {
                    id: timeLabel
                    anchors.top: titleLabel.bottom
                    anchors.right: parent.right
                    height: Theme.fontSizeSmall
                    text: datetime
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
            }

            onClicked: {
                pageStack.push('DetailsPage.qml', {'item': currentModel.get(index)})
            }

        }

        onAtYEndChanged: {
            if (mainListView.atYEnd) {
                if (debug) console.log('at y end');
                if ( !requestLock && status === PageStatus.Active &&
                        currentModel && currentModel.count > 0 && !allLoaded) {
                    if (debug) console.log('loading more');
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
        if (Selfoss.site) {
            requestLock = true;
            currentPage = 0;
            if (debug) console.log('get items', type);
            Selfoss.listItems(type, currentPage, addToModel);
            updateStats();
        }
    }
}


