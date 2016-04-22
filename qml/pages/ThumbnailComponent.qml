import QtQuick 2.2
import Sailfish.Silica 1.0


Item {
    property string thumbnail
    property string site

    id: thumbWrapper
    width: parent ? parent.width : 0
    height: childrenRect.height

    Image {
        id: thumbImage
        width: sourceSize.width < parent.width ? sourceSize.width : parent.width
        height: width * sourceSize.height / sourceSize.width
        source: thumbnail ? site + '/thumbnails/' + thumbnail : ''
        fillMode: Image.Pad
    }

    BusyIndicator {
        id: busyIndicator
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        running: thumbnail !== '' && thumbImage.status === Image.Loading
    }
    Component.onCompleted: {
        if (!thumbnail) {
            thumbImage.height = 0;
            busyIndicator.height = 0;
        }
    }
}
