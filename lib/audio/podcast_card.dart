import 'package:audio_service/audio_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bharat_shikho/audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PodcastCard extends StatelessWidget {
  final QueryDocumentSnapshot? snapshot;
  const PodcastCard({Key? key, this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          var mediaItem = MediaItem(
            title: snapshot!.get('title'),
            id: snapshot!.get('id'),
            album: snapshot!.get('album'),
            artUri:  Uri.parse(snapshot!.get('artUri')),
            artist: snapshot!.get('artist'),
            duration: Duration(milliseconds: int.parse(snapshot!.get('duration'))),
          );
          return MediaPlayer(item: mediaItem);
        }));
      },
      child: Container(
        height: 250,
        child: Card(
          margin: EdgeInsets.all(15),
          child: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(snapshot!.get('artUri')),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            width: MediaQuery.of(context).size.width -200,
                            child: AutoSizeText(
                              snapshot!.get('title'),
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Icon(Icons.more_vert_rounded),
                    )
                  ],
                ),
                Spacer(),
                AutoSizeText(
                  snapshot!.get('artist'),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(5),
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 3),
                          ),
                          AutoSizeText('${Duration(
                                  milliseconds:
                                      int.parse(snapshot!.get('duration')))
                              .inMinutes
                              .toString()} min'),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.playlist_add),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.download),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
