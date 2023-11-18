package tdtu.android.musicappdemov2;

import static tdtu.android.musicappdemov2.PlayMusicActivity.songsArrayList;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SearchView;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;

import java.util.ArrayList;
import java.util.Locale;

public class MainActivity extends AppCompatActivity implements SearchView.OnQueryTextListener {

    private static final int REQUEST_CODE = 1;
    static ArrayList<Songs> songsList;
    static boolean randomBoolean = false, repeatBoolean = false;
    static SongsAdapter songsAdapter;

    private RecyclerView songListRecycler;
    private ImageButton btnPlay;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ColorDrawable colorDrawable
                = new ColorDrawable(Color.parseColor("#170f23"));
        getSupportActionBar().setBackgroundDrawable(colorDrawable);

        permission();
        mapping_ui();

        initRecycler();

    }
    private void initRecycler() {
        songsAdapter = new SongsAdapter(this,songsList);
        songListRecycler.setLayoutManager(new LinearLayoutManager(this));
        songListRecycler.setAdapter(songsAdapter);
    }

    private void mapping_ui() {
        songListRecycler = findViewById(R.id.songsList);
    }
    private void permission() {
        if(ContextCompat.checkSelfPermission(getApplicationContext(),
                Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED){
            ActivityCompat.requestPermissions(MainActivity.this,new String[]{
                    Manifest.permission.WRITE_EXTERNAL_STORAGE},REQUEST_CODE);
        }else{
           Toast.makeText(MainActivity.this,"Permission granted!",
                   Toast.LENGTH_LONG).show();
            songsList = getAllSong(MainActivity.this);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if(requestCode == REQUEST_CODE){
            if(grantResults[0] == PackageManager.PERMISSION_GRANTED){
//                Toast.makeText(MainActivity.this,"Permission granted!",Toast.LENGTH_LONG).show();
                songsList = getAllSong(MainActivity.this);
            }else{
                ActivityCompat.requestPermissions(MainActivity.this,new String[]{
                        Manifest.permission.WRITE_EXTERNAL_STORAGE},REQUEST_CODE);

            }
        }
    }
    public static ArrayList<Songs> getAllSong(Context context){
        ArrayList<Songs> songsArrayList = new ArrayList<>();
        Uri uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
        String[] projection = {
                MediaStore.Audio.Media.ALBUM,
                MediaStore.Audio.Media.ARTIST,
                MediaStore.Audio.Media.TITLE,
                MediaStore.Audio.Media.DATA, //for path
                MediaStore.Audio.Media.DURATION,
                MediaStore.Audio.Media._ID,
        };
        Cursor cursor = context.getContentResolver().query(
                uri,projection,null,null,null);
        if(cursor != null){
            while (cursor.moveToNext()){
                String album = cursor.getString(0);
                String artist = cursor.getString(1);
                String title = cursor.getString(2);
                String path = cursor.getString(3);
                String duration = cursor.getString(4);
                String id = cursor.getString(5);

                Songs song = new Songs(path, title, artist, album, duration,id);
//                Log.e("Path", path);
//                Log.e("Title", song.getTitle());
                songsArrayList.add(song);
            }
            cursor.close();
        }
        return songsArrayList;
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.search_menu,menu);
        MenuItem menuItem = menu.findItem(R.id.search_option);
        SearchView searchView = (SearchView) menuItem.getActionView();
        searchView.setOnQueryTextListener(this);
        return super.onCreateOptionsMenu(menu);
    }
    @Override
    public boolean onQueryTextSubmit(String query) {
        return false;
    }
    @Override
    public boolean onQueryTextChange(String newText) {
        String userInput = newText.toLowerCase();
        ArrayList<Songs> temp = new ArrayList<>();
        for (Songs song: songsList){
            if (song.getTitle().toLowerCase().contains(userInput)){
                temp.add(song);
            }
        }
        songsAdapter.updateList(temp);
        return true;
    }
}