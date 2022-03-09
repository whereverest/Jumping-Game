class AnimationHelper {
  double calculateLimit(double current, double limit, bool isUpper) {
    if (isUpper)
      return current > limit ? limit : current;
    return current < limit ? limit : current;
  }
}