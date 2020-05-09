import QtQuick 2.0
import QtQuick.Controls 2.12

Rectangle{
    id: r
    width: app.width-app.fs
    height:parent.height
    color: app.c1
    border.width: r.us.borderWidth
    border.color: app.c2
    visible: false
    clip: true
    property var us: app&&app.us?app.us:unikSettings
    property bool notShowAgain: false
    /*Connections {
        target: unik
        onUWarningChanged: {
            txtULogView.text+=''+unik.getUWarning()+'<br /><br />';
            if(!r.notShowAgain){
                r.visible=true
            }
        }
    }*/
    Flickable{
        id: flickUW
        width: parent.width-app.fs
        height: parent.height-app.fs
        contentWidth: width
        contentHeight: txtULogView.contentHeight
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: app.fs
        ScrollBar.vertical: ScrollBar {
            parent: flickUW.parent
            anchors.top: flickUW.top
            anchors.topMargin: app.fs*4
            anchors.left: flickUW.right
            anchors.bottom: flickUW.bottom
        }
        Text {
            id: txtULogView
            text: r.us.lang==='es'?'<b>Unik Advertencias</b><br /><br />':'<b>Unik Warnings</b><br /><br />'
            font.pixelSize: app.fs
            color: app.c2
            width: parent.width-app.fs*3
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            onTextChanged: {
                if(flickUW.contentHeight>r.height-app.fs){
                    flickUW.contentY=flickUW.contentHeight-flickUW.height
                }
            }
        }
    }
    Boton{//Close
        id: btnCloseXUWarning
        w:app.fs
        h: w
        t: "\uf00d"
        d:r.us.lang==='es'?'Cerrar':'Close'
        b:app.c1
        c: app.c2
        anchors.right: parent.right
        anchors.rightMargin: app.fs*0.5
        anchors.top: parent.top
        anchors.topMargin: app.fs*0.5
        onClicking: {
            r.visible=false
        }
    }
    Boton{//Close for ever
        id: btnCloseXUWarningNotAgain
        w:app.fs
        h: w
        t: "\uf011"
        d:r.us.lang==='es'?'Cerrar - No mostrar mas':'Close - Not Show Again'
        b:app.c1
        c: app.c2
        anchors.right: btnCloseXUWarning.right
        anchors.top: btnCloseXUWarning.bottom
        anchors.topMargin: app.fs*0.5
        onClicking: {
            r.notShowAgain=true
            r.visible=false
        }
    }
    Boton{//Clear
        id: btnCloseXUWarningClear
        w:app.fs
        h: w
        t: "\uf12d"
        d:r.us.lang==='es'?'Limpiar':'Clear'
        b:app.c1
        c: app.c2
        anchors.right: btnCloseXUWarningNotAgain.right
        anchors.top: btnCloseXUWarningNotAgain.bottom
        anchors.topMargin: app.fs*0.5
        onClicking: {
            txtULogView.text=r.us.lang==='es'?'<b>Unik Advertencias</b><br /><br />':'<b>Unik Warnings</b><br /><br />'
        }
    }
    function showLog(logData){
        txtULogView.text+=''+logData+'<br /><br />';
        if(!r.notShowAgain){
            r.visible=true
        }
    }
}
