import QtQuick 2.5
import QtQuick.Controls 2.0
import unik.UnikQProcess 1.0

UApplicationWindow{
    id: app
    visible: true
    visibility: "Maximized"
    moduleName: 'unik-twitch-stream'
    fs:app.width*0.015
    property string streamKey: ''
    Item {
        id: xApp
        anchors.fill: parent
        Column{
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
            run(cmd, false)
        }
        function setCmd(){
            if(app.streamKey===''){
                app.l('No se ha ingresado la clave/llave de stream.')
                return
            }
            let vINRES="1280x720"
            let vOUTRES="1280x720"
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
            uqp.cmd='"'+unik.getPath(5)+'/ffmpeg/bin/ffmpeg.exe" -f gdigrab -framerate '+vFPS+' -i desktop  -s '+vINRES+'  '+audioCmd+' -f flv -ac 2 -ar '+vAUDIO_RATE+' '
                +'-vcodec libx264 -g '+vGOP+' -keyint_min '+vGOPMIN+' -b:v '+vCBR+' -minrate '+vCBR+' -maxrate '+vCBR+' -pix_fmt yuv420p '
                +'-s '+vOUTRES+' -preset '+vQUALITY+' -tune film -acodec aac -threads '+vTHREADS+' -strict normal '
                +'-bufsize '+vCBR+' "rtmp://'+vSERVER+'.twitch.tv/app/'+vSTREAM_KEY+'"'           
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

*/


