
import 'package:hipsters_ponto_tech/webfeed_modified/rss_category.dart';
import 'package:hipsters_ponto_tech/webfeed_modified/rss_content.dart';
import 'package:hipsters_ponto_tech/webfeed_modified/rss_enclosure.dart';
import 'package:hipsters_ponto_tech/webfeed_modified/rss_source.dart';
import 'package:hipsters_ponto_tech/webfeed_modified/util/helpers.dart';
import 'package:xml/xml.dart';

class RssItem {
  final String title;
  final String description;
  final String link;
  final List<RssCategory> categories;
  final String guid;
  final String pubDate;
  final String author;
  final String comments;
  final String image;
  final String subtitle;
  final String duration;
  final String summary;
  final RssSource source;
  final RssContent content;
  final RssEnclosure enclosure;

  RssItem({
    this.title,
    this.description,
    this.link,
    this.categories,
    this.guid,
    this.pubDate,
    this.author,
    this.comments,
    this.image,
    this.subtitle,
    this.duration,
    this.summary,
    this.source,
    this.content,
    this.enclosure,
  });

  factory RssItem.parse(XmlElement element) {
    return RssItem(
      title: findElementOrNull(element, "title")?.text,
      description: findElementOrNull(element, "description")?.text,
      link: findElementOrNull(element, "link")?.text,
      categories: element.findElements("category").map((element) {
        return RssCategory.parse(element);
      }).toList(),
      guid: findElementOrNull(element, "guid")?.text,
      pubDate: findElementOrNull(element, "pubDate")?.text,
      author: findElementOrNull(element, "author")?.text,
      comments: findElementOrNull(element, "comments")?.text,
      image: findElementOrNull(element, "itunes:image")?.getAttribute('href'),
      subtitle: findElementOrNull(element, 'itunes:subtitle')?.text,
      duration: findElementOrNull(element, 'itunes:duration')?.text,
      summary: findElementOrNull(element, 'itunes:summary')?.text,
      source: RssSource.parse(findElementOrNull(element, "source")),
      content: RssContent.parse(findElementOrNull(element, "content:encoded")),
      enclosure: RssEnclosure.parse(findElementOrNull(element, "enclosure")),
    );
  }
}
