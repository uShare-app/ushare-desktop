#ifndef UTILS_H
#define UTILS_H

#include <QString>
#include <QTime>
#include <QDate>
#include <QStandardPaths>
#include <QUrl>

#include "core/settings.h"

class Utils
{
public:

    static QString getImageExtension()
    {
        QString extension;

        if(Settings::entry(SettingsKeys::IMAGE_FORMAT).toBool() == 0) // JPEG (1 -> PNG)
            extension = ".jpg";
        else
            extension = ".png";

        return extension;
    }

    static QString getNewFileName()
    {
        QTime time = QTime::currentTime();
        QDate date = QDate::currentDate();

        QString fileName = QString::number(date.dayOfYear())
                           + QString::number(time.hour())
                           + QString::number(time.minute())
                           + QString::number(time.second());

        return fileName + getImageExtension();
    }

    static QString getFolderPath(const QString &screenName)
    {
        QString path;

        QString tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation)
                           + "/"
                           + screenName;

        if(Settings::entry(SettingsKeys::SAVE_IMAGE_ON_COMPUTER).toBool())
        {
            path =  Settings::entry(SettingsKeys::PATH_TO_SAVE_IMAGE_ON_COMPUTER).toString()
                    + "/"
                    + screenName;
        }

        if(!QUrl::fromLocalFile(path).isValid())
            return tempPath;
        return path;
    }

};

#endif // UTILS_H

