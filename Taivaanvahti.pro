# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed

TARGET = harbour-taivaanvahti2

CONFIG += sailfishapp

SOURCES += src/Taivaanvahti.cpp

OTHER_FILES += \
    rpm/harbour-taivaanvahti.yaml \
    qml/cover/CoverPage.qml \
    qml/pages/Photos.qml \

HEADERS +=

DISTFILES += \
    UpdateLog.txt \
    harbour-taivaanvahti2.desktop \
    harbour-taivaanvahti2.png \
    qml/harbour-taivaanvahti2.qml \
    qml/pages/Comment.qml \
    qml/pages/Info.qml \
    qml/pages/Observation.qml \
    qml/pages/Observations.qml \
    qml/pages/Search.qml \
    rpm/harbour-taivaanvahti2.spec \
    translations/*.ts

CONFIG += sailfishapp_i18n

TRANSLATIONS += translations/harbour-taivaanvahti2-en.ts
