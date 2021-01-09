#include "config.h"
#include <QDebug>

Config::Config(QObject *parent) : QObject(parent)
{
}

void Config::writeStatus()
{
        const QString &datadir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
        const QDir dir(datadir);
        dir.mkpath("harbour-taivaanvahti");
        const QString &path = datadir + "/" + "harbour-taivaanvahti" + "/" + "config.txt";

        QFile file(path);

        if (file.exists()) {
            file.remove();
        }

        file.open(QIODevice::WriteOnly | QIODevice::Text);

        if (!file.isOpen()) {
            // File opening failed
            return;
        }

        QTextStream outStream(&file);

        if (configurable_) {
            QMap<QString, bool>::iterator object;

            for (object = stateBank_.begin(); object != stateBank_.end(); object++) {
                QString state = "";

                if (object.value()) {
                    state = "true";
                } else {
                    state = "false";
                }
                outStream << object.key() << "=" << state << "\n";
            }

            if (!searchUser_.isEmpty()) {
                outStream << "user=" << searchUser_ << "\n";
            }

            if (!searchTitle_.isEmpty()) {
                outStream << "title=" << searchTitle_ << "\n";
            }

            if (!searchCity_.isEmpty()) {
                outStream << "city=" << searchCity_ << "\n";
            }

            if (!start.isEmpty() ) {
                outStream << "start=" << start << "\n";
            }

            if (!end.isEmpty() ) {
                outStream << "end=" << end << "\n";
            }

            outStream << "config=true" << "\n";
        } else {
            outStream << "config=false" << "\n";

            if (!fetchDate() ) {
                outStream << "start=" << start << "\n";
                outStream << "end=" << end << "\n";
            }
        }

        if (!landScape_) {
            outStream << "landscape=" << "false" << "\n";
        }

    file.close();
}

bool Config::readStatus()
{
    const QString &datadir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
    const QDir &dir(datadir);
    dir.mkpath("harbour-taivaanvahti");
    const QString &path = datadir + "/" + "harbour-taivaanvahti" + "/" + "config.txt";

    QFile file(path);

    if (!file.exists()) {
        return false;
    }

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return false;
    }

    while (!file.atEnd()) {
        QString line = file.readLine();
        line.remove(QRegExp("[\n]"));
        const QStringList &lineList = line.split("=");
        const QString &first = lineList.at(0);
        const QString &secondPart = lineList.at(1);
        bool second = false;

        if (first == "config" && secondPart == "true") {
            configurable_ = true;
        }

        if (first == "landscape") {
            if (secondPart == "false") {
                landScape_ = false;
            } else {
                landScape_ = true;
            }
        }

        if (first == "user" or first == "title" or first == "city" or
                first == "start" or first == "end") {

            if (first == "user") {
                searchUser_ = secondPart;
            }

            if (first == "title") {
                searchTitle_ = secondPart;
            }

            if (first == "city") {
                searchCity_ = secondPart;
            }

            if (first == "start") {
                start = secondPart;
            }

            if (first == "end") {
                end = secondPart;
            }
        }
        else {
            if (lineList.at(1) == "true") {
                second = true;
            }
            stateBank_.insert(first,second);
        }
    }

    file.close();

   return true;
}

void Config::setStatus(const QString &object, const bool &status)
{
    stateBank_[object] = status;
}

bool Config::fetchStatus(const QString &object)
{
    return stateBank_[object];
}

QString Config::fetchSearchUser()
{
    return searchUser_;
}

QString Config::fetchSearchTitle()
{
    return searchTitle_;
}

QString Config::fetchSearchCity()
{
    return searchCity_;
}

void Config::setSearchParameters(const QString &user,
                                 const QString &title,
                                 const QString &city)
{
    if (user != "") {
        searchUser_ = user;
    }

    if (title != "") {
        searchTitle_ = title;
    }

    if (city != "") {
        searchCity_ = city;
    }

    if (user == "" && title == "" && city == "") {
        searchUser_ = "";
        searchTitle_ = "";
        searchCity_ = "";
    }
}

QDate Config::fetchRealDate(const QString &date)
{
    QDate returnDate;

    if (date == "start") {
        const QString starting = start;
        returnDate = QDate::fromString(starting,"yyyy-MM-dd");
    } else {
        const QString ending = end;
        returnDate = QDate::fromString(ending,"yyyy-MM-dd");
    }

    return returnDate;
}

bool Config::fetchDate()
{
    if (start.isEmpty() && end.isEmpty() ) {
        return true;
    }

    return false;
}

void Config::setDate(const QDate &date, const QString &dateType)
{
    if (dateType == "start") {
        start = date.toString("yyyy-MM-dd");
    } else {
        end = date.toString("yyyy-MM-dd");
    }
}

void Config::resetDate()
{
    start = "";
    end = "";
}

bool Config::isConfigurable()
{
    return configurable_;
}

void Config::setConfigurable(const bool &status)
{
    configurable_ = status;
}

void Config::notLandScape(const bool &status)
{
    landScape_ = status;
}

bool Config::isLandScape()
{
    return landScape_;
}
