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
  left(Button.zl, Control.jl, Control.zl),
  right(Button.zr, Control.jr, Control.zr);

  const Hand(this.button, this.joystick, this.trigger);

  final Button button;
  final Control joystick;
  final Control trigger;
}
