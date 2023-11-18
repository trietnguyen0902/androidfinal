package tdtu.android.musicappdemov2;


import static tdtu.android.musicappdemov2.PlayMusicActivity.songsArrayList;


import android.app.Service;
import android.content.Intent;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.Nullable;

import java.util.ArrayList;

public class MusicService extends Service implements MediaPlayer.OnCompletionListener {
    IBinder musicBinder = new MusicBinder();
    MediaPlayer mediaPlayer;
    ArrayList<Songs> songsListService = new ArrayList<>();
    Uri uri;
    ActionPlay actionPlay;
    int position = -1;

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
//        Log.e("Bind","Method");
        return musicBinder;
    }

    public class MusicBinder extends Binder{
        MusicService getService(){
            return MusicService.this;
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        int positionForService = intent.getIntExtra("positionForService",-1);
        if(positionForService != -1){
            playMedia(positionForService);
        }

        String actionName = intent.getStringExtra("actionName");

        if(actionName != null){
            switch (actionName){
                case "playPause":
//                    Toast.makeText(this,"Play/Pause",Toast.LENGTH_LONG).show();
                    if(actionPlay != null){
                        actionPlay.btnPlayClicked();
                    }
                    break;
                case "next":
//                    Toast.makeText(this,"Next",Toast.LENGTH_LONG).show();
                    if(actionPlay != null){
                        actionPlay.btnNextClicked();
                    }
                    break;
                case "previous":
//                    Toast.makeText(this,"Previous",Toast.LENGTH_LONG).show();
                    if (actionPlay != null){
                        actionPlay.btnPreviousClicked();
                    }
                    break;

            }
        }
        return START_STICKY;

    }

    private void playMedia(int StartPosition) {
        songsListService = songsArrayList;
        position = StartPosition;
        if (mediaPlayer != null){
            mediaPlayer.stop();
            mediaPlayer.release();
            if (songsListService != null){
                createMediaPlayer(position);
                mediaPlayer.start();
            }
        }else{
            createMediaPlayer(position);
            mediaPlayer.start();

        }

    }

    void start(){
        mediaPlayer.start();
    }
    boolean isPlaying(){
        return mediaPlayer.isPlaying();
    }
    void stop(){
        mediaPlayer.stop();
    }
    void release(){
        mediaPlayer.release();
    }
    void pause(){
        mediaPlayer.pause();
    }
    int getDuration(){
        return mediaPlayer.getDuration();
    }
    void seekTo(int position){
        mediaPlayer.seekTo(position);
    }
    void createMediaPlayer(int position){
        uri = Uri.parse(songsListService.get(position).getPath());
        mediaPlayer = MediaPlayer.create(getBaseContext(),uri);
    }
    int getCurrentPosition(){
        return mediaPlayer.getCurrentPosition();
    }
    void onCompleted(){
        mediaPlayer.setOnCompletionListener(this);
    }

    @Override
    public void onCompletion(MediaPlayer mediaPlayer) {
        if (actionPlay != null){
//            Log.e("Completion","true");
            actionPlay.btnNextClicked();
        }else{
//            Log.e("Completion","false");
        }
    }

    void setCallBackPlayerAction(ActionPlay actionPlay){
        this.actionPlay = actionPlay;
    }
}
