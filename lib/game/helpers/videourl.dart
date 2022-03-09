class VideoURL {
  final String url;
  final String thumbnail;

  VideoURL({required this.url, required this.thumbnail});

  factory VideoURL.fromJson(Map<String, dynamic> json) {
    return VideoURL(
        url: json['data']['videoUrl'], thumbnail: json['data']['thumbnailUrl']);
  }
}