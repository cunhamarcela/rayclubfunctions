// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/core/utils/youtube_utils.dart';

void main() {
  group('YouTubeUtils Tests', () {
    group('extractVideoId', () {
      test('should extract video ID from youtube.com URL', () {
        const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
        final result = YouTubeUtils.extractVideoId(url);
        expect(result, equals('dQw4w9WgXcQ'));
      });

      test('should extract video ID from youtu.be URL', () {
        const url = 'https://youtu.be/dQw4w9WgXcQ';
        final result = YouTubeUtils.extractVideoId(url);
        expect(result, equals('dQw4w9WgXcQ'));
      });

      test('should extract video ID from mobile youtube URL', () {
        const url = 'https://m.youtube.com/watch?v=dQw4w9WgXcQ';
        final result = YouTubeUtils.extractVideoId(url);
        expect(result, equals('dQw4w9WgXcQ'));
      });

      test('should return null for invalid URL', () {
        const url = 'https://example.com/video';
        final result = YouTubeUtils.extractVideoId(url);
        expect(result, isNull);
      });

      test('should return null for null URL', () {
        final result = YouTubeUtils.extractVideoId(null);
        expect(result, isNull);
      });

      test('should return null for empty URL', () {
        final result = YouTubeUtils.extractVideoId('');
        expect(result, isNull);
      });
    });

    group('getThumbnailUrl', () {
      test('should generate correct thumbnail URL for maxres quality', () {
        const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
        final result = YouTubeUtils.getThumbnailUrl(
          url, 
          quality: YouTubeThumbnailQuality.maxres,
        );
        expect(result, equals('https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg'));
      });

      test('should generate correct thumbnail URL for high quality', () {
        const url = 'https://youtu.be/dQw4w9WgXcQ';
        final result = YouTubeUtils.getThumbnailUrl(
          url, 
          quality: YouTubeThumbnailQuality.high,
        );
        expect(result, equals('https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg'));
      });

      test('should return null for invalid URL', () {
        const url = 'https://example.com/video';
        final result = YouTubeUtils.getThumbnailUrl(url);
        expect(result, isNull);
      });
    });

    group('isValidYouTubeUrl', () {
      test('should return true for valid YouTube URLs', () {
        const urls = [
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          'https://youtu.be/dQw4w9WgXcQ',
          'https://m.youtube.com/watch?v=dQw4w9WgXcQ',
        ];

        for (final url in urls) {
          expect(YouTubeUtils.isValidYouTubeUrl(url), isTrue, reason: 'Failed for URL: $url');
        }
      });

      test('should return false for invalid URLs', () {
        const urls = [
          'https://example.com/video',
          'not a url',
          '',
          null,
        ];

        for (final url in urls) {
          expect(YouTubeUtils.isValidYouTubeUrl(url), isFalse, reason: 'Failed for URL: $url');
        }
      });
    });

    group('getThumbnailUrlsWithFallback', () {
      test('should return list of fallback URLs', () {
        const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
        final result = YouTubeUtils.getThumbnailUrlsWithFallback(url);
        
        expect(result, hasLength(4));
        expect(result[0], equals('https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg'));
        expect(result[1], equals('https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg'));
        expect(result[2], equals('https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg'));
        expect(result[3], equals('https://img.youtube.com/vi/dQw4w9WgXcQ/default.jpg'));
      });

      test('should return empty list for invalid URL', () {
        const url = 'https://example.com/video';
        final result = YouTubeUtils.getThumbnailUrlsWithFallback(url);
        expect(result, isEmpty);
      });
    });
  });
} 