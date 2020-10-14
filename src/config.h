#ifndef CONFIG_H
#define CONFIG_H

#include <QMap>
#include <QObject>
#include <QtQuick>
#include <QString>
#include <QFile>
#include <QDate>

/**
 * @brief The Config class provides api for reading and writing application
 * data. The data right now is only search related so search parameters are
 * respected / remembered in future use of application
 */
class Config : public QObject
{
    Q_OBJECT
public:
    explicit Config(QObject *parent = nullptr);

    /**
      * @brief Writes the status for application
      */
    Q_INVOKABLE void writeStatus();

    /**
     * @brief Reads the status from file
     */
    Q_INVOKABLE bool readStatus();

    /**
     * @brief Sets status for current stateBank
     * @pre Object must be in stateBank already
     */
    Q_INVOKABLE void setStatus(QString object, bool status);

    /**
      * @brief Fetches a single object's status from stateBank
      */
    Q_INVOKABLE bool fetchStatus(QString object);

    /**
      * @brief Fetch the user parameter if set
      */
    Q_INVOKABLE QString fetchSearchUser();

    /**
      * @brief Fetch the title if set
      */
    Q_INVOKABLE QString fetchSearchTitle();

    /**
      * @brief Fetches the city
      */
    Q_INVOKABLE QString fetchSearchCity();

    /**
      * @brief Sets the search parameters
      */
    Q_INVOKABLE void setSearchParameters(QString user = "",
                                         QString title = "",
                                         QString city = "");

    /**
      * @brief Fetches if the start and end dates are defined
      * @return true if are defined, false if not
      */

    Q_INVOKABLE bool fetchDate();

    /**
      * @brief Fetches the real given date in config
      * @pre The date must be in config in order to work properly
      * @return QDate based on config QString dates in format
      * yyyy-MM-dd
      */
    Q_INVOKABLE QDate fetchRealDate(QString date);

    /**
      * @brief Sets start or end string based on given QDate
      * in format yyyy-MM-dd
      */
    Q_INVOKABLE void setDate(QDate date, QString dateType);

    /**
      * @brief Resets both start and end QStrings
      */
    Q_INVOKABLE void resetDate();

    /**
      * @brief Checks if configuration is used
      * @return status of configurable true / false
      */
    Q_INVOKABLE bool isConfigurable();

    /**
      * @brief Sets state based on given parameter status
      */
    Q_INVOKABLE void setConfigurable(bool status);

    /**
      * @brief Sets the landscape into state true or false
      */
    Q_INVOKABLE void notLandScape(bool status);

    /**
      * @brief Checks if landscape should be used
      * @return True if it's false if not
      */
    Q_INVOKABLE bool isLandScape();

signals:

public slots:

private:
    QMap<QString, bool> stateBank_;
    bool configurable_ = false;
    bool landScape_ = true;
    QString searchUser_ = "";
    QString searchTitle_ = "";
    QString searchCity_ = "";
    QString start = "";
    QString end = "";
};

#endif // CONFIG_H
