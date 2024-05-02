enum Control {
  gyro,
  a,
  b,
  x,
  y,
  l,
  r,
  zl,
  zr,
  tl,
  tr,
  jl,
  jr,
  select,
  start,
  dpad,
}

enum Button {
  a,
  b,
  x,
  y,
  l,
  r,
  zl,
  zr,
  tl,
  tr,
  select,
  start,
  up(true),
  down(true),
  left(true),
  right(true);

  const Button([this.motion = false]);

  final bool motion;
}

enum Hand {
  left(Control.jl, Control.tl),
  right(Control.jr, Control.tr);

  const Hand(this.joystick, this.trigger);

  final Control joystick;
  final Control trigger;
}
