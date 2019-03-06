import 'package:webfeed/webfeed.dart';

class Podcast {
  String link;
  String title;
  String url;
  int length;
  String pubDate;
  String linkComments;
  String descricao;
  String image;
  String subtitle;
  String summary;
  String duration;
  Duration position;
  bool downloaded;

  Podcast.fromRSS(RssItem item) {
    this.link = item.link;
    this.title = item.title;
    this.url = item.enclosure.url;
    this.length = item.enclosure.length;
    this.pubDate = item.pubDate;
    this.linkComments = item.comments;
    this.descricao = item.description;
    this.image = item.image;
    this.subtitle = item.subtitle;
    this.duration = item.duration;
    this.summary = item.summary;
    this.pubDate = '00/00/0000';
    this.position = Duration(seconds: 800);
    if(this.image == null)
      this.image = 'https://hipsters.tech/wp-content/uploads/2018/12/Hipsters_-_thumbnail_base_-_menor___128.png';
  }

  Podcast.fromJson(Map<String, dynamic> json) {
    this.link = json['link'];
    this.title = json['title'];
    this.url = json['url'];
    this.length = json['length'];
    this.pubDate = json['pubDate'];
    this.linkComments = json['link_comments'];
    this.descricao = json['descricao'];
    this.image = json['image'];
    this.subtitle = json['subtitle'];
    this.summary = json['summary'];
    this.duration = json['duration'].toString();
    this.position = Duration(seconds: json['position']);
    this.downloaded = json['downloaded'];
  }

  Map<String, dynamic> toJson() {
    return {
      'link': this.link,
      'title': this.title,
      'url': this.url,
      'length': this.length,
      'pubDate': this.pubDate,
      'link_comments': this.linkComments,
      'descricao': this.descricao,
      'image': this.image,
      'subtitle': this.subtitle,
      'summary': this.summary,
      'duration': this.duration,
      'position': this.position.inSeconds,
      'downloaded': this.downloaded
    };
  }

  bool operator ==(o) => o is Podcast && link == o.link && title == o.title;

}