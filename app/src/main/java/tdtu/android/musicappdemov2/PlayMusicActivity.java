package tdtu.android.musicappdemov2;

import static tdtu.android.musicappdemov2.ApplicationClass.ACTION_NEXT;
import static tdtu.android.musicappdemov2.ApplicationClass.ACTION_PLAY;
import static tdtu.android.musicappdemov2.ApplicationClass.ACTION_PREVIOUS;
import static tdtu.android.musicappdemov2.ApplicationClass.CHANNEL_ID_2;
import static tdtu.android.musicappdemov2.MainActivity.randomBoolean;
import static tdtu.android.musicappdemov2.MainActivity.repeatBoolean;
import static tdtu.android.musicappdemov2.MainActivity.songsList;
import static tdtu.android.musicappdemov2.SongsAdapter.songsListAdapter;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
//import android.support.v4.media.session.MediaSessionCompat;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.animation.LinearInterpolator;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestManager;
import com.bumptech.glide.request.RequestOptions;

import java.util.ArrayList;
import java.util.Random;

public class PlayMusicActivity extends AppCompatActivity implements ActionPlay, ServiceConnection {
    private ImageButton btnPlay,btnPrevious,btnNext,btnRepeat,btnRandom, btnBackMain;
    private TextView songStartTime, songEndTime, nameSong, author;
    private SeekBar progress_music;
    private ImageView songImg;
    private RequestManager glideRequestManager;
    private int position = -1;
    public static ArrayList<Songs> songsArrayList;
    private static Uri uri;
    private Handler handler = new Handler();
    private Thread playThread, nextThread, previousThread;
    MusicService musicService;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setFullScreen();
        setContentView(R.layout.activity_play_music);

        initView();
        getIntentMethod();
        glideRequestManager = Glide.with(this);
        progress_music.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if(musicService != null && fromUser){
                    musicService.seekTo(progress * 1000);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        PlayMusicActivity.this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(musicService != null){
                    int currentPosition = musicService.getCurrentPosition() / 1000;
                    progress_music.setProgress(currentPosition);
                    songStartTime.setText(formattedTime(currentPosition));
                }
                handler.postDelayed(this,1000);
            }
        });

        btnRandom.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(randomBoolean){
                    randomBoolean = false;
                    btnRandom.setImageResource(R.drawable.ic_swap_off_40dp);
                }else {
                    randomBoolean = true;
                    btnRandom.setImageResource(R.drawable.ic_swap_on_40dp);
                }
            }
        });

        btnRepeat.setOnClickListener(view -> {
            if(repeatBoolean){
                repeatBoolean = false;
                btnRepeat.setImageResource(R.drawable.ic_repeat_40dp);
            }else{
                repeatBoolean = true;
                btnRepeat.setImageResource(R.drawable.ic_repeat_one_40dp);
            }
        });

        btnBackMain.setOnClickListener(view -> {
            finish();
        });
    }

    private void setFullScreen() {
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getSupportActionBar().hide();
    }

    @Override
    protected void onResume() {
        Intent intent = new Intent(this, MusicService.class);
        bindService(intent,this,BIND_AUTO_CREATE);

        playThreadBtn();
        previousThreadBtn();
        nextThreadBtn();
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        unbindService(this);
    }
    @Override
    protected void onDestroy() {
        super.onDestroy();
        Glide.with(this).pauseRequests();
        Glide.with(this).clear(songImg);
    }

    private void nextThreadBtn() {
        nextThread = new Thread(){
            @Override
            public void run() {
                super.run();
                btnNext.setOnClickListener(view -> {
                    btnNextClicked();
                });
            }
        };
        nextThread.start();
    }

    public void btnNextClicked() {
        musicService.stop();
        musicService.release();

        if(randomBoolean && !repeatBoolean){
            position = getRandom(songsArrayList.size()-1);
        }else if (!randomBoolean && !repeatBoolean){
            position = ((position+1) % songsArrayList.size());
        }

        uri = Uri.parse(songsArrayList.get(position).getPath());
        musicService.createMediaPlayer(position);

        metaData(uri);
        handleSeekBar();
        musicService.onCompleted();
        btnPlay.setImageResource(R.drawable.ic_pause_80dp);

        if(!musicService.isPlaying()){
            musicService.start();
            startRotateSongImg();
            showNotification(R.drawable.ic_pause_80dp);
        }
    }

    private int getRandom(int i) {
        Random random = new Random();
        return random.nextInt(i + 1);
    }

    private void previousThreadBtn() {
        previousThread = new Thread(){
            @Override
            public void run() {
                super.run();
                btnPrevious.setOnClickListener(view -> {
                    btnPreviousClicked();
                });
            }
        };
        previousThread.start();
    }

    public void btnPreviousClicked() {
        musicService.stop();
        musicService.release();

        if(randomBoolean && !repeatBoolean){
            position = getRandom(songsArrayList.size()-1);
        }else if (!randomBoolean && !repeatBoolean){
            position = ((position-1) < 0 ? (songsArrayList.size() - 1) : (position -1));
        }

        uri = Uri.parse(songsArrayList.get(position).getPath());
        musicService.createMediaPlayer(position);

        metaData(uri);
        handleSeekBar();

        musicService.onCompleted();
        btnPlay.setImageResource(R.drawable.ic_pause_80dp);

        if(!musicService.isPlaying()){
            musicService.start();
            startRotateSongImg();
            showNotification(R.drawable.ic_pause_80dp);
        }
    }

    private void playThreadBtn() {
        playThread = new Thread(){
            @Override
            public void run() {
                super.run();
                btnPlay.setOnClickListener(view -> {
                    btnPlayClicked();
                });
            }
        };
        playThread.start();
    }

    public void btnPlayClicked() {
        if(musicService.isPlaying()){
            showNotification(R.drawable.ic_play_80dp);
            btnPlay.setImageResource(R.drawable.ic_play_80dp);
            musicService.pause();
            stopRotateSongImg();
            handleSeekBar();
        }else {
            showNotification(R.drawable.ic_pause_80dp);
            btnPlay.setImageResource(R.drawable.ic_pause_80dp);
            musicService.start();
            startRotateSongImg();
            handleSeekBar();
        }
    }

    private String formattedTime(int currentPosition) {
        String total = "";
        String totalNew = "";
        String second = String.valueOf(currentPosition % 60);
        String minute = String.valueOf(currentPosition / 60);
        total = minute + ":" + second;
        totalNew = minute + ":0" + second;
        if (second.length() == 1){
            return totalNew;
        }
        return total;
    }

    private void getIntentMethod() {
        position = getIntent().getIntExtra("position",-1);
        songsArrayList = songsListAdapter;
        if(songsArrayList != null){
            btnPlay.setImageResource(R.drawable.ic_pause_80dp);
            uri = Uri.parse(songsArrayList.get(position).getPath());
        }
        showNotification(R.drawable.ic_pause_80dp);
        startRotateSongImg();
        Intent intent = new Intent(this,MusicService.class);
        intent.putExtra("positionForService", position);
        startService(intent);
    }

    private void metaData(Uri uri){
        if (!isFinishing()) {
            nameSong.setText(songsArrayList.get(position).getTitle());
            author.setText(songsArrayList.get(position).getArtist());
            MediaMetadataRetriever retriever = new MediaMetadataRetriever();
            retriever.setDataSource(uri.toString());
            int durationTotal = Integer.parseInt(songsArrayList.get(position).getDuration()) / 1000;
            songEndTime.setText(formattedTime(durationTotal));
            byte[] img = retriever.getEmbeddedPicture();
            if(img != null){
                glideRequestManager.asBitmap().load(img).apply(new RequestOptions().override(
                        450,500)).into(songImg);
            }else{
                glideRequestManager.asBitmap().load(R.drawable.music_icon).into(songImg);
            }
        }
    }
    private void initView() {
        nameSong = findViewById(R.id.nameSongPlay);
        author = findViewById(R.id.authorSongPlay);
        songEndTime = findViewById(R.id.songEndTime);
        songStartTime = findViewById(R.id.songStartTime);

        btnPlay = findViewById(R.id.btnPlayPlay);
        btnPrevious = findViewById(R.id.btnPreviousPlay);
        btnNext = findViewById(R.id.btnNextPlay);
        btnRepeat = findViewById(R.id.btnRepeatPlay);
        btnRandom = findViewById(R.id.btnRandomPlay);
        btnBackMain = findViewById(R.id.btnBackMain);

        progress_music = findViewById(R.id.progress_music);

        songImg = findViewById(R.id.imgSongPlay);
    }
    @Override
    public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
        MusicService.MusicBinder musicBinder = (MusicService.MusicBinder) iBinder;
        musicService = musicBinder.getService();
//        Toast.makeText(this,"Service connected" + musicService,Toast.LENGTH_LONG).show();
        musicService.setCallBackPlayerAction(this);
        progress_music.setMax(musicService.getDuration()/1000);
        metaData(uri);
        nameSong.setText(songsArrayList.get(position).getTitle());
        author.setText(songsArrayList.get(position).getArtist());
        musicService.onCompleted();
    }

    @Override
    public void onServiceDisconnected(ComponentName componentName) {
        musicService = null;
    }

    public void showNotification(int btnPlay){
        Intent intent = new Intent(this,PlayMusicActivity.class);
        PendingIntent contentIntent = PendingIntent.getActivity(this,0,intent,
                PendingIntent.FLAG_IMMUTABLE);

        Intent prevIntent = new Intent(this,NotificationReceiver.class).setAction(
                ACTION_PREVIOUS);
        PendingIntent prevPending = PendingIntent.getBroadcast(this,0,
                prevIntent,PendingIntent.FLAG_UPDATE_CURRENT);

        Intent playIntent = new Intent(this,NotificationReceiver.class).setAction(
                ACTION_PLAY);
        PendingIntent playPending = PendingIntent.getBroadcast(this,0,
                playIntent,PendingIntent.FLAG_UPDATE_CURRENT);

        Intent nextIntent = new Intent(this,NotificationReceiver.class).setAction(
                ACTION_NEXT);
        PendingIntent nextPending = PendingIntent.getBroadcast(this,0,
                nextIntent,PendingIntent.FLAG_UPDATE_CURRENT);

        byte[] img = null;
        img = getSongImage(songsArrayList.get(position).getPath());
        Bitmap thumb = null;
        if(img != null){
            thumb = BitmapFactory.decodeByteArray(img,0,img.length);
        }else {
            thumb = BitmapFactory.decodeResource(getResources(),R.drawable.default_image);
        }

        String status;
        if(btnPlay == R.drawable.ic_pause_80dp){
            status = "Pause";
        }else{
            status = "Play";
        }

        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID_2)
                .setSmallIcon(btnPlay)
                .setLargeIcon(thumb)
                .setContentTitle(songsArrayList.get(position).getTitle())
                .setContentText(songsArrayList.get(position).getArtist())
                .addAction(R.drawable.ic_previous_80dp,"Previous",prevPending)
                .addAction(btnPlay,status,playPending)
                .addAction(R.drawable.ic_next_80dp,"Next",nextPending)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setOnlyAlertOnce(true)
                .build();
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);
        if (notificationManager != null){
            notificationManager.notify(0,notification);
//            Log.e("notify success   ", "true");
        }else{
//            Log.e("notify fail", "true");
        }
    }
    private byte[] getSongImage(String uri){
        MediaMetadataRetriever mediaMetadataRetriever = new MediaMetadataRetriever();
        mediaMetadataRetriever.setDataSource(uri);
        byte[] image = mediaMetadataRetriever.getEmbeddedPicture();
        mediaMetadataRetriever.release();
        return image;
    }
    private void handleSeekBar(){
        progress_music.setMax(musicService.getDuration() / 1000);
        PlayMusicActivity.this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(musicService != null){
                    int currentPosition = musicService.getCurrentPosition() / 1000;
                    progress_music.setProgress(currentPosition);
                }
                handler.postDelayed(this,1000);
            }
        });
    }
    private void startRotateSongImg(){
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                songImg.animate().rotationBy(360).withEndAction(this).setDuration(10*1000)
                        .setInterpolator(new LinearInterpolator()).start();
            }
        };
        songImg.animate().rotationBy(360).withEndAction(runnable).setDuration(10*1000)
                .setInterpolator(new LinearInterpolator()).start();
    }
    private void stopRotateSongImg(){
        songImg.animate().cancel();
    }

}