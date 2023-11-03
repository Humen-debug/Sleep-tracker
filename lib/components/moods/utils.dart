enum Mood { awful, bad, meh, good, yea }

Mood valueToMood(double value) {
  if (value <= 0.2) {
    return Mood.awful;
  } else if (value <= 0.4) {
    return Mood.bad;
  } else if (value <= 0.6) {
    return Mood.meh;
  } else if (value <= 0.8) {
    return Mood.good;
  } else {
    return Mood.yea;
  }
}
