import QtQuick 2.2
import Sailfish.Silica 1.0

import '../js/selfoss.js' as Selfoss

Page {
    id: detailsWebPage

    property var item
    property string initUrl: "http://selfoss.aditu.de/"

    property int fontSize: settings.wvFontSize || 28
    property string fontColor: settings.wvFontColor || "#000000"
    property string backgroundColor: settings.wvBgColor || "#ffffff"

    SilicaWebView {
        id: webView

        anchors.fill: parent

        experimental {
            userAgent: "Mozilla/5.0 (Maemo; Linux; U; Sailfish; Mobile; rv:38.0)  AppleWebKit/538.1 (KHTML, like Gecko)"
            transparentBackground: false
            //userStyleSheets: "../css/webview.css"
            //customLayoutWidth: 280
            preferences {
                defaultFontSize: fontSize
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Back")
                onClicked: {
                    if (webView.canGoBack) {
                        webView.goBack()
                    } else if (isBlank()) {
                        pageStack.popAttached()
                    } else if (item) {
                        webView.loadHtml(generateHtml())
                    } else {
                        webView.url = initUrl
                    }
                }
            }
            MenuItem {
                text: webView.loading ? qsTr("Stop") : qsTr("Reload")
                onClicked: {
                    if (!webView.loading && isBlank() && item) {
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
                    if (isBlank() && item) {
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
            if (settings.debug) console.log('web view ready')
        }
    }

    function generateHtml() {
        var title = item.title.replace(/ target=\"_blank\"/g, ' ')
        var content = '<p style="text-align: right; font-size: 16px; color: gray;">' + qsTr("Reload to view original web page") + '</p>'
        if (item.content) {
            content = Selfoss.decodeCharCode(item.content.replace(/ target=\"_blank\"/g, ' '))
        }
        if (item.thumbnail) {
            content = '<p style="text-align: center;"><img src="' + Selfoss.site + '/thumbnails/' + item.thumbnail + '"></p>' + content
        }

        return  '<html lang="en">' +
                '<head>' +
                '  <meta charset="UTF-8">' +
                '  <title></title>' +
                '  <style>' +
                '    body { color: ' + fontColor + '; background-color: ' + backgroundColor + '; }' +
                '    h1 { font-size: ' + fontSize * 1.2 + 'px; margin-top: 36px; }' +
                '    article { word-wrap:break-word; font-size: ' + fontSize + 'px; }' +
                '    img { max-width: 100%; }' +
                '  </style>' +
                '</head>' +
                '<body>' +
                '  <h1>　' + title + '</h1>' +
                '  <article>' + content + '</article>' +
                '</body>' +
                '</html>'
    }

    function isBlank() {
        return '' + webView.url === 'about:blank'
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (item) {
                webView.loadHtml(generateHtml())
            } else {
                webView.url = initUrl
            }
        }
    }

}
