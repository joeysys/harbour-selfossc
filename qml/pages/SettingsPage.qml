import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/storage.js" as Storage
import "../js/selfoss.js" as Selfoss

Page {
    id: settingsPage

    property string site: ''
    property string user: ''
    property string passwd: ''
    property string timezone: ''

    property bool _showThumbs: false
    property bool _noScaling: false
    property bool _debug: false

    property string wvFontSize: '28'
    property string wvFontColor: "black"
    property string wvBgColor: "white"

    function readSettings() {
        var settings = Storage.readAllSettings();
        site = settings['site'] || site
        user = settings['user'] || user
        passwd = settings['passwd'] || passwd
        timezone = settings['timezone'] || timezone
        _showThumbs = settings['thumb'] || _showThumbs
        _noScaling = settings['noScaling'] || _noScaling
        _debug = settings['debug'] || _debug
        wvFontSize = settings['wvFontSize'] || wvFontSize
        wvFontColor = settings['wvFontColor'] || wvFontColor
        wvBgColor = settings['wvBgColor'] || wvBgColor
        console.log ("read debug:", settings['debug'])
    }

    function saveSettings() {
        if (site !== serverField.text) {
            Storage.writeSetting('site', serverField.text);
            forceReload = true;
        }
        if (user !== userField.text) {
            Storage.writeSetting('user', userField.text);
            forceReload = true;
        }
        if (passwdField.text && passwd !== passwdField.text) {
            Storage.writeSetting('passwd', passwdField.text);
            forceReload = true;
        }
        if (timezone !== timezoneField.text) {
            Storage.writeSetting('timezone', timezoneField.text);
            forceReload = true;
        }

        if (thumbSwitch.checked !== _showThumbs) {
            exportFns.toggleThumbs(thumbSwitch.checked);
            Storage.writeSetting('thumb', thumbSwitch.checked);
        }
        if (scalingSwitch.checked == _noScaling) {
            Storage.writeSetting('noScaling', !scalingSwitch.checked);
        }
        console.log (debugSwitch.checked, _debug)
        if (debugSwitch.checked !== _debug) {
            console.log ("writing debug:", debugSwitch.checked)
            Storage.writeSetting('debug', debugSwitch.checked);
        }

        if (wvFontSize !== wvFontSizeField.text) {
            Storage.writeSetting('wvFontSize', wvFontSizeField.text);
        }
        if (wvFontColor !== wvFontColorField.text) {
            Storage.writeSetting('wvFontColor', wvFontColorField.text);
        }
        if (wvBgColor !== wvBgColorField.text) {
            Storage.writeSetting('wvBgColor', wvBgColorField.text);
        }

        Selfoss.readSettings();
        settings = readLocalSettings();
    }

    SilicaFlickable {
        contentHeight: settingsColumn.height + Theme.paddingLarge
        anchors.fill: parent

        Column {
            id: settingsColumn
            width: parent.width
            height: childrenRect.height

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Server")
            }

            TextField {
                id: serverField
                width: parent.width - Theme.paddingLarge
                text: site
                label: qsTr("Server url")
                placeholderText: "https://selfoss.example.com"
            }

            TextField {
                id: userField
                width: parent.width - Theme.paddingLarge
                text: user
                label: qsTr("Username (optional)")
                placeholderText: label
                inputMethodHints: Qt.ImhNoAutoUppercase
            }

            TextField {
                id: passwdField
                width: parent.width - Theme.paddingLarge
                echoMode: TextInput.PasswordEchoOnEdit
                label: qsTr("Password (optional)")
                placeholderText: passwd ? "Password (unchanged)" : label
            }

            TextField {
                id: timezoneField
                width: parent.width - Theme.paddingLarge
                label: qsTr("Server timezone (optional)")
                text: timezone
                placeholderText: label
                inputMethodHints: Qt.ImhDigitsOnly
            }

            SectionHeader {
                text: qsTr("Behaviour")
            }

            TextSwitch {
                id: thumbSwitch
                text: qsTr("Always show thumbnails")
                checked: _showThumbs
            }

            TextSwitch {
                id: scalingSwitch
                text: qsTr("Scale images in content")
                checked: !_noScaling
            }

            TextSwitch {
                id: debugSwitch
                text: qsTr("Enable debugging")
                checked: _debug
                visible: true
            }

            SectionHeader {
                text: qsTr("WebView")
            }

            TextField {
                id: wvFontSizeField
                width: parent.width - Theme.paddingLarge
                label: qsTr("Font size")
                text: wvFontSize
                placeholderText: label
                inputMethodHints: Qt.ImhDigitsOnly
            }

            TextField {
                id: wvFontColorField
                width: parent.width - Theme.paddingLarge
                label: qsTr("Font color")
                text: wvFontColor
                placeholderText: label
            }

            TextField {
                id: wvBgColorField
                width: parent.width - Theme.paddingLarge
                label: qsTr("Background color")
                text: wvBgColor
                placeholderText: label
            }

            SectionHeader {
                text: qsTr("Version 0.4.0")
            }

        }
    }

    onStatusChanged: {
        if (status == PageStatus.Deactivating) {
            saveSettings();
        }
    }

    Component.onCompleted: {
        readSettings()
    }
}
