/// Round [number] up to a multiple of [factor].
///
/// The [factor] must be greater than zero.
int roundUp(double number, int factor) {
  assert(factor > 0, 'factor $factor must be greater than 0.');
  number += factor - 1;
  return (number - (number % factor)).round();
}
