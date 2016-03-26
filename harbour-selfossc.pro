# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-selfossc

CONFIG += sailfishapp

SOURCES += src/harbour-selfossc.cpp

OTHER_FILES += qml/harbour-selfossc.qml \
    qml/pages/DetailsPage.qml \
    qml/pages/FilterDialog.qml \
    qml/pages/MainPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/WebViewPage.qml \
    qml/cover/CoverPage.qml \
    qml/js/selfoss.js \
    qml/js/storage.js \
    rpm/harbour-selfossc.changes \
    rpm/harbour-selfossc.spec \
    rpm/harbour-selfossc.yaml \
    translations/*.ts \
    harbour-selfossc.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

DISTFILES += \
    qml/img/logo.png
