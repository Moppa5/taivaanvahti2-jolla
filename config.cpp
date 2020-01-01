#include "config.h"
#include <QDebug>

Config::Config(QObject *parent) : QObject(parent)
{
}

void Config::writeStatus()
{
    QFile file(dataFile_);

    if (file.exists()) {
        // File is there already => clear the file
        file.remove();
    }

    file.open(QIODevice::WriteOnly | QIODevice::Text);

    if (!file.isOpen()) {
        // File opening failed
        return;
    }

    QTextStream outStream(&file);

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

    file.close();
}

bool Config::readStatus()
{
    QFile file(dataFile_);

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            return false;
    }

    while (!file.atEnd()) {
        QString line = file.readLine();
        line.remove(QRegExp("[\n]"));
        QStringList lineList = line.split("=");
        QString first = lineList.at(0);
        bool second = false;

        if (lineList.at(1) == "true") {
            second = true;
        }
        stateBank_.insert(first,second);
    }

    file.close();

    if (stateBank_.count() == 0) {
        /* Something other went wrong in the reading process
         * stateBank can't be empty if reading successfull!
         */
        return false;
    }

   return true;
}

void Config::setStatus(QString object, bool status)
{
    stateBank_[object] = status;
}

bool Config::fetchStatus(QString object)
{
    return stateBank_[object];
}