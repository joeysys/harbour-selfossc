import QtQuick 2.2
import Sailfish.Silica 1.0

import '../js/selfoss.js' as Selfoss

Page {
    id: detailsWebPage

    property var item

    property int fontSize: 28
    property string fontColor: "#000000"
    property string backgroundColor: "#ffffff"

    allowedOrientations: Orientation.All

    SilicaWebView {
        id: webView

        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Back")
                onClicked: {
                    if (webView.canGoBack) {
                        webView.goBack()
                    } else if (isBlank()) {
                        pageStack.popAttached()
                    } else {
                        webView.loadHtml(generateHtml())
                    }
                }
            }
            MenuItem {
                text: webView.loading ? qsTr("Stop") : qsTr("Reload")
                onClicked: {
                    if (!webView.loading && isBlank()) {
                        webView.url = item.link
                    } else {
                        webView.loading ? webView.stop() : webView.reload()
                    }
                }
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Open in Browser")
                onClicked: {
                    if (isBlank()) {
                        Qt.openUrlExternally(item.link);
                    } else {
                        Qt.openUrlExternally(webView.url);
                    }
                }
            }
        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: webView.loading
        }

        Component.onCompleted: {
            loadHtml(generateHtml())
        }
    }

    function generateHtml() {
        return  '<html lang="en">' +
                '<head>' +
                '  <meta charset="UTF-8">' +
                '  <title></title>' +
                '  <style>' +
                '    body { color: ' + fontColor + '; background-color: ' + backgroundColor + '; }' +
                '    h1 { font-size: ' + fontSize * 1.2 + 'px; }' +
                '    article { word-wrap:break-word; font-size: ' + fontSize + 'px; }' +
                '    img { max-width: 100%; }' +
                '  </style>' +
                '</head>' +
                '<body>' +
                '  <h1>' + item.title + '</h1>' +
                '  <article>' + Selfoss.decodeCharCode(item.content.replace(/ target=\"_blank\" /g, ' ')) + '</article>' +
                '</body>' +
                '</html>'
    }

    function isBlank() {
        return '' + webView.url === 'about:blank'
    }
}
