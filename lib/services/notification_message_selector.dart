import 'dart:math';

class NotificationMessageSelector {
  NotificationMessageSelector({Random? random}) : _random = random ?? Random();

  final Random _random;

  String message(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }

  String title(List<String> titles, String itemTitle) {
    return titles[_random.nextInt(titles.length)].replaceAll(
      '{title}',
      itemTitle,
    );
  }
}
