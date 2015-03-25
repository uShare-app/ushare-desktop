import QtQuick 2.2
import QtQuick.Layouts 1.1
import Material 0.1
import Material.ListItems 0.1 as ListItem
import Material.Extras 0.1
import "." as U
import "./usquare_online.js" as UOnline

U.Dialog {
    id: dialog
    title: "Register"
    height: units.dp(445)

    property bool hasError: false

    signal successRegister()

    /* Register form */
    Column {
        id: register
        spacing: units.dp(10)

        Label {
            style: 'subheading'
            text: 'Fill fields below to get registered';
        }

        View {
            elevation: 2
            width: units.dp(400)
            height: units.dp(350)

         Column {
                id: fieldColumn

                anchors {
                    fill: parent
                    topMargin: units.dp(16)
                    bottomMargin: units.dp(16)
                }

                Label {
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.dp(16)
                    }

                    style: "title"
                    text: "Please fill fields"
                }

                Item {
                    Layout.fillWidth: false
                    Layout.preferredHeight: units.dp(0)
                }

                ListItem.Standard {
                    action: Icon {
                        anchors.centerIn: parent
                        name: "action/account_child"
                    }

                    content: TextField {
                        id: usernameField
                        placeholderText: "Username"

                        width: parent.width
                        anchors.centerIn: parent
                    }
                }

                ListItem.Standard {
                    action: Icon {
                        anchors.centerIn: parent
                        name: "action/https"
                    }

                    content: RowLayout {
                        anchors.centerIn: parent
                        width: parent.width

                            TextField {
                             id: passwordField
                             placeholderText: "Password"

                             input.echoMode: TextInput.Password

                             Layout.alignment: Qt.AlignVCenter
                             Layout.preferredWidth: 0.45 * parent.width
                            }

                            TextField {
                             id: passwordField2
                             placeholderText: "Repeat password"

                             input.echoMode: TextInput.Password

                             hasError: {
                                 if(passwordField.text !== passwordField2.text)
                                 {
                                     dialog.hasError = true;
                                     return true;
                                 }
                                 else
                                 {
                                     dialog.hasError = false;
                                     return false;
                                 }
                             }

                             Layout.alignment: Qt.AlignVCenter
                             Layout.preferredWidth: 0.45 * parent.width
                            }
                    }
                }

                ListItem.Standard {
                    action: Icon {
                        anchors.centerIn: parent
                        name: "communication/email"
                    }

                    content: TextField {
                        id: emailField
                        anchors.centerIn: parent
                        width: parent.width

                        placeholderText: "Email"

                        hasError: {
                            if(text !== "")
                            {
                                dialog.hasError = true;
                                return !validateEmail(text);
                            }

                            dialog.hasError = false;
                            return false;
                        }
                    }
                }

                ListItem.Standard {
                    content: Checkbox {
                        id: rememberCheckbox
                        text: 'Remember for further login attempt'
                        checked: true
                    }
                }

                ListItem.Standard {
                    content: Checkbox {
                        id: acceptConditionsCheckbox
                        text: 'I accept conditions'
                        checked: false
                    }
                }

                Label {
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.dp(5)
                    }

                    id: errorLabel
                    color: '#c0392b'
                    visible: false
                }
            }
        }
    }

    onAccepted: {
        if(usernameField.text === '' || passwordField.text === ''
                || passwordField2.text === '' || emailField.text === '')
        {
            errorLabel.text = 'You must fill all fields.';
            errorLabel.visible = true;
            return;
        }

        if(!acceptConditionsCheckbox.checked)
        {
            errorLabel.text = 'You must agree the conditions.';
            errorLabel.visible = true;
            return;
        }

        if(!validateEmail(emailField.text))
        {
            errorLabel.text = 'Your email must be valid.';
            errorLabel.visible = true;
            return;
        }

        if(passwordField.text !== passwordField2.text)
        {
            errorLabel.text = 'Your password must be the same in two rows.';
            errorLabel.visible = true;
            return;
        }

        errorLabel.visible = false;
        tryToRegister();
    }

    onRejected: {
        resetFields();
        close();
    }

    function resetFields()
    {
        usernameField.text = '';
        passwordField.text = '';
        passwordField2.text = '';
        emailField.text = '';
        acceptConditionsCheckbox.checked = false;
        errorLabel.visible = false;
    }

    function tryToRegister()
    {
        var username = usernameField.text;
        var password = passwordField.text;
        var email = emailField.text;

        var callback = function(err, result)
        {
            if(err !== null)
            {
                errorLabel.text = 'Can\'t register your account (' + result.errorMessage + ')';
                errorLabel.visible = true
                return;
            }

            else
            {
                if(rememberCheckbox.checked)
                {
                    Settings.setValue('username', username);
                    Settings.setValue('password', password);
                }

                successRegister();
                resetFields();
                close();
            }
        }

        UOnline.register(username, password, email, dialog, callback);
    }

    function validateEmail(email) {
        var re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(email);
    }
}