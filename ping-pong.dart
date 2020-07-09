import 'dart:html';
import 'dart:collection';
import 'dart:async';

const B_COLOR = "black";
const F_COLOR = "#00CC00"; // Link (Zelda) green

CanvasElement canvas;
CanvasRenderingContext2D ctx;
Keyboard keyboard;
// To display error messages I'm going to use the #text element <footer>...<p id="text"></p></footer>
Element text;

void main() {

    canvas = querySelector('#canvas')..focus();
    ctx = canvas.getContext('2d');
    keyboard = new Keyboard();
    text = querySelector('#text');
    // text.text = "canvas.width = ${'x': canvas.width} canvas.height = ${'x': canvas.height}";

    new Game().run();

} //---------- main() ----------------------

void clear() {
    ctx..fillStyle = B_COLOR
       ..fillRect(0, 0, canvas.width, canvas.height);

    int midCourt = canvas.width ~/ 2;
    ctx..strokeStyle = F_COLOR
       ..setLineDash([20, 20]) // [dash, gap]
       ..lineDashOffset = 10
       ..lineWidth = 10
       ..beginPath()
       ..moveTo(midCourt , 0)
       ..lineTo(midCourt , canvas.height)
       ..stroke();
} //---------- clear() ---------------------

class Keyboard {
    HashMap<int, num> keys = new HashMap<int, num>();

    Keyboard() {
        window.onKeyDown.listen((KeyboardEvent event) {
           keys.putIfAbsent(event.keyCode, () => event.timeStamp);
        });

        window.onKeyUp.listen((KeyboardEvent event) {
            keys.remove(event.keyCode);
        });
    }

    bool isPressed(int keyCode) => keys.containsKey(keyCode);

} //----------- class Keyboard -------------

// My own class Point, with blackjack and hookers
class Point {
    num x;
    num y;

    Point(x, y) {
        this.x = x;
        this.y = y;
    }

    Point operator +(Point p) {
        return new Point(x+p.x, y+p.y);
    }

    @override
  String toString() {
    return "(${this.x}, ${this.y})";
  }

} //----------- class Point ----------------

class Player {
    static const PLAYER1 = "player1";
    static const PLAYER2 = "player2";
    static const PLAYER_WIDTH  = 15;
    static const PLAYER_HEIGHT = 70;
    static const MIN_Y = 0;
    static final MAX_Y = canvas.height - PLAYER_HEIGHT;
    static final UP   = Point(0,-PLAYER_WIDTH);
    static final DOWN = Point(0, PLAYER_WIDTH);
    static final STAND_STILL = Point(0, 0);
    static final player1InitialPosition = Point( 0, (canvas.height - PLAYER_HEIGHT ) / 2 );
    static final player2InitialPosition = Point( ( canvas.width - PLAYER_WIDTH ) ,( canvas.height - PLAYER_HEIGHT ) / 2 );

    int _keyUp;
    int _keyDown;
    Point _position;
    Point _dir;
    String _name;

    Player(Point this._position, String this._name){
        if (this._name == PLAYER1){
            // player1. Control keys "q" and "a"
            _keyUp   = KeyCode.Q;
            _keyDown = KeyCode.A;
        } else if (this._name == PLAYER2){
            // player2. Control keys "p" and "l"
            _keyUp   = KeyCode.P;
            _keyDown = KeyCode.L;
        }
        _dir = STAND_STILL;
        draw();
    }

    void draw(){
        ctx..fillStyle = F_COLOR
            ..fillRect(_position.x, _position.y, PLAYER_WIDTH, PLAYER_HEIGHT);
    }

    void _checkInput() {
        if      (keyboard.isPressed(this._keyUp))   { _dir = UP;     }
        else if (keyboard.isPressed(this._keyDown)) { _dir = DOWN;   }
        else                                   { _dir = STAND_STILL; }
    }

    void move() {
        _checkInput();

        if((_dir == UP && _position.y >= MIN_Y) || (_dir == DOWN && _position.y <= MAX_Y)) {
            _position = _position + _dir;
        }
    }

} //----------- class Player ---------------


class Game  {
    // Speed control. Smaller numbers make te game run faster
    static const num GAME_SPEED = 50;

    // To calculate how much time pass between frame updates
    num _lastTimeStamp = 0;

    Player player1;
    Player player2;
    Ball ball;

    Game() {
        clear();
        player1 = new Player(Player.player1InitialPosition, Player.PLAYER1);
        player2 = new Player(Player.player2InitialPosition, Player.PLAYER2);
        ball = new Ball();
    }

  Future run() async {
      update(await window.animationFrame);
  }

  void update(num delta) {
  //    Element text = querySelector('#text');
  //    text.text = "insaid ofde apdeit <b\nr>diff = $diff ~ delta = $delta ~ _lastTimeStamp = $_lastTimeStamp <br>";
      num diff = delta - _lastTimeStamp;

      if (diff > GAME_SPEED) {
          _lastTimeStamp = delta;
          clear();
          player1.move();
          player1.draw();
          player2.move();
          player2.draw();
          ball.move();
          ball.draw();
      }
      run();
  }

} //----------- class Game -----------------

class Ball {
    static const BALL_WIDTH = 10;
// NOTE: The point (0, 0) its the top left corner of the canvas
// moves of the ball
    static final UP_LEFT    = Point(-BALL_WIDTH, -BALL_WIDTH);
    static final DOWN_LEFT  = Point(-BALL_WIDTH,  BALL_WIDTH);
    static final DOWN_RIGHT = Point( BALL_WIDTH,  BALL_WIDTH);
    static final UP_RIGHT   = Point( BALL_WIDTH, -BALL_WIDTH);

    Point _position = new Point(50, 50);
    Point dir = DOWN_RIGHT;

    void draw(){
        ctx..fillStyle = F_COLOR
            ..fillRect(_position.x, _position.y, BALL_WIDTH, BALL_WIDTH);
    }

    void move(){
        _position = _position + dir ;
    }

// TODO checkPosition

} //----------- class Ball -----------------