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
TARGET = harbour-instasaver

CONFIG += sailfishapp

SOURCES += src/harbour-instasaver.cpp

OTHER_FILES += qml/harbour-instasaver.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-instasaver.changes.in \
    rpm/harbour-instasaver.spec \
    rpm/harbour-instasaver.yaml \
    translations/*.ts \
    harbour-instasaver.desktop \
    qml/pages/Main.qml \
    qml/components/Banner.qml \
    qml/pages/Settings.qml \
    qml/pages/About.qml \
    qml/js/LocalStorage.js \
    qml/js/UrlUtils.js \
    qml/components/BusyOverlay.qml \
    qml/components/InstapaperClient.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-instasaver-de.ts

