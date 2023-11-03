String formatDuration(Duration? duration) {
  if (duration == null) return "--:--:--";
  return "${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
}
