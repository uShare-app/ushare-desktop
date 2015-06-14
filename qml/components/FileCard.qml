import QtQuick 2.0
import Material 0.1
import Material.Extras 0.1
import Material.ListItems 0.1
import "../components" as U
import "../components/functions.js" as F
import "../components/usquare_online.js" as UOnline

View
{
    id: root;
    property var fileInformations; // Handle a file object. See the API for more informations

    width: 310;
    height: 90;
    elevation: 1;

    /** Two dividers**/
    Rectangle
    {
        width: 1;
        height: 90;
        x: 91;
        color: Qt.rgba(0,0,0,0.1);
    }

    Rectangle
    {
        width: 1;
        height: 90;
        x: 210;
        color: Qt.rgba(0,0,0,0.1);
    }

    /** First column, miniature of the file **/
    Image
    {
        x: 0;
        y: 0;
        width: 90;
        height: 90;

        source: fileInformations.mimetype.slice(0, 6) === "image/" ? fileInformations.silentLink : '';

        fillMode: Image.PreserveAspectFit;

        MouseArea
        {
            anchors.fill: parent;
            cursorShape: Qt.PointingHandCursor;
            onClicked:
            {
                Desktop.openUrl(fileInformations.link);
            }
        }
    }

    /** Second column, informations about the file **/
    Column
    {
        y: 5;
        x: 100;
        spacing: 7;

        Label
        {
            text: qsTr('%1 views').arg(fileInformations.views);
        }

        Label
        {
            text: F.humanFileSize(fileInformations.size, true);
        }

        Label
        {
            text: fileInformations.password ? qsTr('Click to see password') : qsTr('No password');
            color: '#27ae60';

            MouseArea
            {
                anchors.fill: parent;
                cursorShape: Qt.PointingHandCursor;
                onClicked:
                {
                    parent.text = fileInformations.password ?
                                (fileInformations.password === parent.text ? qsTr('Click to see password') : fileInformations.password)
                                : qsTr('No password');
                }
            }
        }

        Label
        {
            text: fileInformations.link;
            color: '#2980b9';

            MouseArea
            {
                anchors.fill: parent;
                cursorShape: Qt.PointingHandCursor;
                onClicked:
                {
                    Desktop.openUrl(fileInformations.link);
                }
            }
        }
    }

    /** Third column, actions on the file **/
    Column
    {
        y: 2;
        x: 219;
        spacing: 1;

        Button
        {
            text: qsTr('Open');
            elevation: 1;
            backgroundColor: Theme.accentColor;

            width: 82;
            height: 28;

            onClicked:
            {
                Desktop.openUrl(fileInformations.link);
            }
        }

        Button
        {
            text: qsTr('Copy link');
            elevation: 1;
            backgroundColor: Theme.accentColor;

            width: 82;
            height: 28;

            onClicked:
            {
                Clipboard.setText(fileInformations.link);
                snackbar.open(qsTr('Link copied!'));
            }
        }

        Button
        {
            id: buttonMore;
            text: qsTr('More');
            elevation: 1;
            backgroundColor: Theme.accentColor;

            width: 82;
            height: 28;

            onClicked:
            {
                menu.open(buttonMore, -5, 1);
            }
        }

        Dropdown
        {
            id: menu;

            anchor: Item.TopLeft;

            width: Math.min(root.moreMenuWidth, root.width);
            height: Math.min(10 * Units.dp(48) + Units.dp(16), root.moreMenuModel.length * Units.dp(48) + Units.dp(16));

            ListView
            {
                id: listView;

                anchors
                {
                    left: parent.left;
                    right: parent.right;
                    top: parent.top;
                    topMargin: Units.dp(8);
                    bottom: parent.bottom;
                }

                interactive: false;
                model: root.moreMenuModel;

                delegate: Standard
                {
                    id: delegateItem;

                    text: modelData;

                    onClicked:
                    {
                        listView.currentIndex = index;
                        menu.close();

                        if(fileInformations.password && listView.currentIndex === 2 || !fileInformations.password && listView.currentIndex === 1)
                        {
                            UOnline.deleteFile(fileInformations.shortname, function(err, result)
                            {
                                if(err || !result.success)
                                {
                                    snackbar.open(result.message ? result.message : qsTr('An error occurred.'));
                                    return;
                                }

                                snackbar.open(qsTr('File deleted!'));
                            });
                        }

                        else if(listView.currentIndex === 0)
                        {
                            passwordDialog.show();
                        }

                        else if(fileInformations.password && listView.currentIndex === 1)
                        {
                            UOnline.editFilePassword('', fileInformations.shortname, function(err, result)
                            {
                                if(err || !result.success)
                                {
                                    snackbar.open(result.message ? result.message : qsTr('An error occurred.'));
                                    return;
                                }

                                snackbar.open(qsTr('Password deleted.'));
                            });
                        }
                    }
                }
            }
        }
    }

    property var moreMenuModel: fileInformations.password ? [qsTr('Edit password'), qsTr('Delete password'), qsTr('Delete')] : [qsTr('Edit password'), qsTr('Delete')];

    Label
    {
        id: hiddenLabel;
        style: "subheading";
        visible: false;
    }

    property int moreMenuWidth;

    Component.onCompleted:
    {
        var maxWidth = 0;

        for (var i = 0; i < moreMenuModel.length; ++i)
        {
            hiddenLabel.text = moreMenuModel[i];

            maxWidth = Math.max(maxWidth, hiddenLabel.implicitWidth + Units.dp(50));
        }

        moreMenuWidth = maxWidth;
    }

    U.Dialog
    {
        id: passwordDialog;

        title: qsTr("Edit password");
        hasActions: true;

        Column
        {
            spacing: Units.dp(8);

            Label
            {
                style: "subheading";
                text: qsTr("Change the password in order to protect the file.");
            }

            Label
            {
                id: statusLabel;
                visible: false;
                color: 'red';
            }

            TextField
            {
                id: newPassword;

                echoMode: TextInput.Password;
                width: parent.width;

                placeholderText: qsTr("New password");
            }

            CheckBox
            {
                text: qsTr("Show password");

                checked: false;

                onCheckedChanged:
                {
                    if(checked) newPassword.echoMode = TextInput.Normal;
                    else newPassword.echoMode = TextInput.Password;
                }
            }
        }

        onAccepted:
        {
            if(!newPassword.text)
            {
                statusLabel.text = 'You must provide a password';
                statusLabel.visible = true;
                return;
            }

            UOnline.editFilePassword(newPassword.text, fileInformations.shortname, function(err, result)
            {
                if(err || !result.success)
                {
                    snackbar.open(result.message ? result.message : qsTr('An error occurred.'));
                    return;
                }

                snackbar.open(qsTr('Password edited.'));
            });

            close();
        }

        onRejected: close();
    }

} /* View */
