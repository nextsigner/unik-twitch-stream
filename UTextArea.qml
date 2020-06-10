import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

TextArea{
    id: r
    style: TextAreaStyle {
        textColor: app.c2
        selectionColor: app.c2
        selectedTextColor: app.c1
        backgroundColor: app.c1
    }
}
