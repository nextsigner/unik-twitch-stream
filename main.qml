import QtQuick 2.5
import QtQuick.Controls 2.0
import unik.UnikQProcess 1.0
import QtQuick.Window 2.0

UApplicationWindow{
    id: app
    visible: true
    visibility: "Maximized"
    moduleName: 'unik-twitch-stream'
    fs:app.width*0.015
    property string streamKey: ''

    property string currentCMD: ''
    Item {
        id: xApp
        anchors.fill: parent
        Column{
            spacing: app.fs*0.5
            anchors.centerIn: parent
            UText{text:app.moduleName;font.pixelSize: app.fs*2}
            Row {
                spacing: app.fs
                width: app.fs*30
                height: app.fs*6
                UText{
                    id:labelDevices
                    text: 'Dispositivos de Audio:'
                    anchors.verticalCenter: parent.verticalCenter
                }
                UComboBox{
                    id: uCBAudioDevices
                    width: parent.width-labelDevices.contentWidth+app.fs*2
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Rectangle{
                id: xTaCurretCmd
                width: xApp.width*0.8
                height: app.fs*10
                color: app.c1
                border.width: 1
                border.color: app.c2
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false
                UTextArea{
                    id: taCurrentCmd
                    width: parent.width
                    height: parent.height
                    wrapMode: Text.WordWrap
                    anchors.centerIn: parent
                }
            }
            Row{
                spacing: app.fs
                BotonUX{
                    text: xTaCurretCmd.visible?'Ocultar Linea de Comando':'Ver Linea de Comando'
                    onClicked: {
                        if(!xTaCurretCmd.visible){
                            uqp.setCmd()
                            taCurrentCmd.text=uqp.cmd
                            xTaCurretCmd.visible=true
                        }else{
                            xTaCurretCmd.visible=false
                        }
                    }
                }
                BotonUX{
                    text: 'Copiar'
                    onClicked: {
                        clipboard.setText(taCurrentCmd.text)
                    }
                }
            }
            BotonUX{
                text: 'Iniciar Transmisión'
                onClicked: {
                    if(uqp.upIsOpen()){
                        uqp.upkill()
                    }else{
                        uqp.init()
                    }
                }
                Timer{
                    running: true
                    repeat: true
                    interval: 250
                    onTriggered: {
                        if(uqp.upIsOpen()){
                            parent.text='Detener Transmisión'
                        }else{
                            parent.text='Iniciar Transmisión'
                        }
                    }
                }
            }
        }
        ULogView{
            id: uLogView
            width: parent.width*0.5
            anchors.right: parent.right
        }
        UWarnings{id: uWarnings}
    }
    UnikQProcess{
        id: uqp1
        onLogDataChanged:  {
            let audioDevicesModel=[]
            if(Qt.platform.os==='windows'){
                let m0=logData.split('DirectShow audio devices')
                if(m0.length>1){
                    let m1=m0[1].split('[dshow')
                    if(m1.length>1){
                        for(var i=0;i<m1.length;i++){
                            let m2=m1[i].split('"')
                            if(m2.length>1){
                                //app.l(m2[1])
                                audioDevicesModel.push(m2[1])
                            }
                        }
                    }
                }
                uCBAudioDevices.model=audioDevicesModel
            }
        }
        Component.onCompleted: {
            unik.debugLog=true
            let cmd='"'+unik.getPath(5)+'/ffmpeg/bin/ffmpeg.exe" -list_devices true -f dshow -i dummy'
            run(cmd)
        }
    }
    UnikQProcess{
        id: uqp
        property string cmd
        onLogDataChanged: {
            app.l(logData)
        }
        function init(){
            setCmd()
            if(!xTaCurretCmd.visible){
                run(cmd, false)
            }else{
                run(taCurrentCmd.text, false)
            }

        }
        function setCmd(){
            if(app.streamKey===''){
                app.l('No se ha ingresado la clave/llave de stream.')
                return
            }
            let vINRES=""+Screen.width+"x"+Screen.height+""
            if(Qt.application.arguments.toString().indexOf('-inRes=')>=0){
                let m0=Qt.application.arguments.toString().split('-inRes=')
                let m1=m0[1].split(' ')
                vINRES=m1[0]
            }
            let vOUTRES=vINRES //Mediante el parametro -outRes=1280x720 se puede definir como otra resolucion de salida.
            if(Qt.application.arguments.toString().indexOf('-outRes=')>=0){
                let m0=Qt.application.arguments.toString().split('-outRes=')
                let m1=m0[1].split(' ')
                vOUTRES=m1[0]
            }

            let vFPS="10"
            let vGOP="60"
            let vGOPMIN="30"
            let vTHREADS="2"
            let vCBR="1000k"
            let vQUALITY="ultrafast"
            let vAUDIO_RATE="44100"
            let vSTREAM_KEY=app.streamKey
            let vSERVER="live-fra"
            let audioCmd=' -f dshow -i audio="'+uCBAudioDevices.model[uCBAudioDevices.currentIndex]+'"'
            if(Qt.platform.os==='windows'){
                uqp.cmd='"'+unik.getPath(5)+'/ffmpeg/bin/ffmpeg.exe" -f gdigrab -framerate '+vFPS+' -i desktop  -s '+vINRES+'  '+audioCmd+' -f flv -ac 2 -ar '+vAUDIO_RATE+' '
                        +'-vcodec libx264 -g '+vGOP+' -keyint_min '+vGOPMIN+' -b:v '+vCBR+' -minrate '+vCBR+' -maxrate '+vCBR+' -pix_fmt yuv420p '
                        +'-s '+vOUTRES+' -preset '+vQUALITY+' -tune film -acodec aac -threads '+vTHREADS+' -strict normal '
                        +'-bufsize '+vCBR+' "rtmp://'+vSERVER+'.twitch.tv/app/'+vSTREAM_KEY+'"'
            }
            if(Qt.platform.os==='linux'){
                uqp.cmd='ffmpeg -f x11grab -s '+vINRES+'  -r '+vFPS+' -r 25 -i :0.0+0,0 -f pulse -i default  -f flv -ac 2 -ar '+vAUDIO_RATE+' '
                        +'-vcodec libx264 -g '+vGOP+' -keyint_min '+vGOPMIN+' -b:v '+vCBR+' -minrate '+vCBR+' -maxrate '+vCBR+' -pix_fmt yuv420p '
                        +'-s '+vOUTRES+' -preset '+vQUALITY+' -tune film -acodec aac -threads '+vTHREADS+' -strict -2 '
                        +'-bufsize '+vCBR+' "rtmp://'+vSERVER+'.twitch.tv/app/'+vSTREAM_KEY+'"'
                console.log(uqp.cmd)
            }

        }
    }
    Shortcut{
        sequence: 'Esc'
        onActivated: Qt.quit()
    }
    Component.onCompleted:  {
        for(var i=0;i<Qt.application.arguments.length;i++){
            if(Qt.application.arguments[i].indexOf('-twitchStreamKey=')>=0){
                let m0=Qt.application.arguments[i].split('-twitchStreamKey=')
                if(m0.length>1){
                    app.streamKey=m0[1]
                }
            }
        }
    }
}

/*
  GNU/Linux
  pactl load-module module-null-sink sink_name=mimodulo&&pactl load-module module-loopback source=0 sink=mimodulo&&pactl load-module module-loopback source=1 sink=mimodulo&&ffmpeg -f x11grab -s 1280x720 -r 25 -i :0.0+0,0 -f pulse -i mimodulo.monitor -f flv -ac 2 -ar 44100 -vcodec libx264 -g 60 -keyint_min 30 -b:v 1000k -minrate 1000k -maxrate 1000k -pix_fmt yuv420p -s 1280x720 -preset ultrafast -tune film -acodec aac -threads 2 -strict -2

streaming() {
     INRES="1920x1080" # input resolution
     OUTRES="1920x1080" # output resolution
     FPS="30" # target FPS
     GOP="60" # i-frame interval, should be double of FPS,
     GOPMIN="30" # min i-frame interval, should be equal to fps,
     THREADS="2" # max 6
     CBR="1000k" # constant bitrate (should be between 1000k - 3000k)
     QUALITY="ultrafast"  # one of the many FFMPEG preset
     AUDIO_RATE="44100"
     STREAM_KEY="$1" # use the terminal command Streaming streamkeyhere to stream your video to twitch or justin
     SERVER="live-fra" # twitch server in frankfurt, see https://stream.twitch.tv/ingests/ for list

     ffmpeg -f x11grab -s "$INRES" -r "$FPS" -i :0.0 -f pulse -i 0 -f flv -ac 2 -ar $AUDIO_RATE \
       -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b:v $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p\
       -s $OUTRES -preset $QUALITY -tune film -acodec aac -threads $THREADS -strict normal \
       -bufsize $CBR "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
 }


 ffmpeg -f x11grab -s 1280x720 -r 25 -i :0.0+0,0 -f pulse -i 0 -f flv -ac 2 -ar 44100 -vcodec libx264 -g 60 -keyint_min 30 -b:v 1000k -minrate 1000k -maxrate 1000k -pix_fmt yuv420p -s 1280x720 -preset ultrafast -tune film -acodec aac -threads 2 -strict -2 -bufsize 1000k rtmp://live-fra.twitch.tv/app/live_497299721_1IrKTb3OdDULZtfNdsRfWLWF4bkVW2
*/


