package tdtu.android.musicappdemov2;

import android.content.Context;
import android.content.Intent;
import android.media.MediaMetadataRetriever;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;

import java.util.ArrayList;

public class SongsAdapter extends RecyclerView.Adapter<SongsAdapter.SongsViewHolder> {
    private Context context;
    static ArrayList<Songs> songsListAdapter;

    public SongsAdapter(Context context, ArrayList<Songs> songsList) {
        this.context = context;
        this.songsListAdapter = songsList;
    }

    @NonNull
    @Override
    public SongsViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(
                R.layout.item_song_list, parent, false);
        return new SongsViewHolder(view);
    }


    @Override
    public void onBindViewHolder(@NonNull SongsViewHolder holder, int position) {
        Songs song = songsListAdapter.get(position);
        holder.songName.setText(song.getTitle());
        holder.songAuthor.setText(song.getArtist());

        holder.itemLayout.setOnClickListener(view -> {
            Intent intent = new Intent(holder.itemView.getContext(), PlayMusicActivity.class);
            intent.putExtra("position", position);
            holder.itemView.getContext().startActivity(intent);
        });

        byte[] image = getSongImage(song.getPath());
        if (image != null) {
            Glide.with(context)
                    .asBitmap()
                    .load(image)
                    .apply(new RequestOptions().override(60, 60))
                    .error(R.drawable.music_icon)  // Set an error placeholder
                    .into(holder.songImg);
        } else {
            Glide.with(context).asBitmap().load(R.drawable.music_icon).into(holder.songImg);
        }
    }

    @Override
    public int getItemCount() {
        return songsListAdapter.size();
    }
    public class SongsViewHolder extends RecyclerView.ViewHolder {
        private TextView songName, songAuthor;
        private ImageView songImg;
        private CardView itemLayout;

        public SongsViewHolder(@NonNull View itemView) {
            super(itemView);
            songName = itemView.findViewById(R.id.nameSongPlay);
            songAuthor = itemView.findViewById(R.id.authorSongPlay);
            songImg = itemView.findViewById(R.id.imageSong);
            itemLayout = itemView.findViewById(R.id.itemLayout);
        }
    }

    private byte[] getSongImage(String uri) {
        MediaMetadataRetriever mediaMetadataRetriever = new MediaMetadataRetriever();
        try {
            mediaMetadataRetriever.setDataSource(uri);
            return mediaMetadataRetriever.getEmbeddedPicture();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mediaMetadataRetriever.release();
        }
        return null;
    }

    public void updateList(ArrayList<Songs> temp){
        songsListAdapter = new ArrayList<>();
        songsListAdapter.addAll(temp);
        notifyDataSetChanged();
    }

}
