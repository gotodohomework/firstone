class TimeUtils {
  static String incrementTime(String timeString) {
    List<int> timeComponents = timeString.split(':').map(int.parse).toList();
    // print("在分离:${timeComponents}");
    int hours = timeComponents[0];
    int minutes = timeComponents[1];
    int seconds = timeComponents[2];

    seconds++;
    if (seconds >= 60) {
      seconds = 0;
      minutes++;
      if (minutes >= 60) {
        minutes = 0;
        hours++; // 累加小时
      }
    }
    //   print("在累判断后:${seconds}");
    // print(
    //     "在自增类:${_formatTimeComponent(hours)}:${_formatTimeComponent(minutes)}:${_formatTimeComponent(seconds)}");

    return '${_formatTimeComponent(hours)}:${_formatTimeComponent(minutes)}:${_formatTimeComponent(seconds)}';
  }

  static String _formatTimeComponent(int component) {
    return component.toString().padLeft(2, '0');
  }
}
