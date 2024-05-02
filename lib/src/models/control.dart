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

final key = {
  'a'.codeUnits.first: Button.a,
  'b'.codeUnits.first: Button.b,
  'x'.codeUnits.first: Button.x,
  'y'.codeUnits.first: Button.y,
  'l'.codeUnits.first: Button.l,
  'r'.codeUnits.first: Button.r,
  'u'.codeUnits.first: Button.zl,
  'v'.codeUnits.first: Button.zr,
  't'.codeUnits.first: Button.tl,
  'z'.codeUnits.first: Button.tr,
  'c'.codeUnits.first: Button.select,
  's'.codeUnits.first: Button.start,
  Button.up.index: Button.up,
  Button.down.index: Button.down,
  Button.left.index: Button.left,
  Button.right.index: Button.right,
};
