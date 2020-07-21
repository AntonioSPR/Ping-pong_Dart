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
Player player1;
Player player2;
Ball ball;
Scoreboard scoreboard;

void main() {

    canvas = querySelector('#canvas')..focus();
    ctx = canvas.getContext('2d');
    keyboard = new Keyboard();
    text = querySelector("#text");

    player1 = new Player(Player.player1InitialPosition, Player.PLAYER1);
    player2 = new Player(Player.player2InitialPosition, Player.PLAYER2);
    ball = new Ball();
    scoreboard = new Scoreboard();

    new Game();

} //---------- main() ----------------------

class Keyboard {
    HashMap<int, num> keys = new HashMap<int, num>();

    Keyboard() {
        window.onKeyDown.listen((KeyboardEvent event) {
           keys.putIfAbsent(event.keyCode, () => event.timeStamp);
           text.text = "${text.text} - ${event.keyCode}";
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

    String toString() {
        return "(${this.x}, ${this.y})";
    }

} //----------- class Point ----------------

class Scoreboard {
    static const TOP = 0;
    static const BOTTOM = 1;
    static const Map numbers = {
        0: ["zero_up",  "zero_bottom" ],
        1: ["one_up",   "one_bottom"  ],
        2: ["two_up",   "two_bottom"  ],
        3: ["three_up", "three_bottom"],
        4: ["four_up",  "four_bottom" ],
        5: ["five_up",  "five_bottom" ],
        6: ["six_up",   "six_bottom"  ],
        7: ["seven_up", "seven_bottom"],
        8: ["eight_up", "eight_bottom"],
        9: ["nine_up",  "nine_bottom" ]
    };
    List<Element> _p1 = [querySelector('#scoreboard_left_up'),  querySelector('#scoreboard_left_bottom') ];
    List<Element> _p2 = [querySelector('#scoreboard_right_up'), querySelector('#scoreboard_right_bottom')];

    Scoreboard(){
        _p1[TOP].className    = numbers[0][TOP];
        _p1[BOTTOM].className = numbers[0][BOTTOM];
        _p2[TOP].className    = numbers[0][TOP];
        _p2[BOTTOM].className = numbers[0][BOTTOM];
    }

    void p1(int n){
        _p1[TOP].className    = numbers[n][TOP];
        _p1[BOTTOM].className = numbers[n][BOTTOM];
    }

    void p2(int n){
        _p2[TOP].className    = numbers[n][TOP];
        _p2[BOTTOM].className = numbers[n][BOTTOM];
    }

  void reset() {
        p1(0);
        p2(0);
  }

} //----------- class Scoreboard -----------

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
    int score = 0;

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

    num get x => _position.x;
    num get y => _position.y;

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

    void reset () {
        score = 0;
    }

} //----------- class Player ---------------

class Ball {
    static const BALL_WIDTH = 10;
    // The point (0, 0) its the top left corner of the canvas
    static const MIN_X = 0;
    static final MAX_X = canvas.width - BALL_WIDTH;
    static const MIN_Y = 0;
    static final MAX_Y = canvas.height - BALL_WIDTH;
    static final UP_LEFT    = Point(-BALL_WIDTH, -BALL_WIDTH);
    static final DOWN_LEFT  = Point(-BALL_WIDTH,  BALL_WIDTH);
    static final DOWN_RIGHT = Point( BALL_WIDTH,  BALL_WIDTH);
    static final UP_RIGHT   = Point( BALL_WIDTH, -BALL_WIDTH);
    static final P1_SERVICE = Point( 50, 50);
    static final P2_SERVICE = Point(740, 50);
    static const P1 = 1;
    static const P2 = 2;

    Point _position = P1_SERVICE;
    Point _dir = DOWN_RIGHT;

    num get x => _position.x;
    num get y => _position.y;

    int _pointWinner;

    void draw(){
        ctx..fillStyle = F_COLOR
            ..fillRect(_position.x, _position.y, BALL_WIDTH, BALL_WIDTH);
    }

    void move(){
        if(checkPosition()) {
            _position = _position + _dir;
        }
        else {
            if (_pointWinner == P1) {
                player1.score += 1;
                scoreboard.p1(player1.score);
                _position = P1_SERVICE;
                _dir      = DOWN_RIGHT;
            } else {
                player2.score += 1;
                scoreboard.p2(player2.score);
                _position = P2_SERVICE;
                _dir      = DOWN_LEFT;
            }
        }
    }

    bool checkPosition(){
        // True if the point can continue
        // False if the ball exceeds the player
        // If the ball hit the lines or the player, the direction changes

        Point newPosition = _position + _dir ;

        if (newPosition.y >= MAX_Y || newPosition.y <= MIN_Y) {
            _dir.y = -1 * _dir.y;
        }

        if (newPosition.x <= player1.x) {
            if (newPosition.y >= player1.y && newPosition.y <= player1.y + Player.PLAYER_HEIGHT) {
                _dir.x = -1 * _dir.x;
                return true;
            }
            else {
                _pointWinner = P2;
                return false;
            }
        }

        if (newPosition.x >= player2.x) {
            if (newPosition.y >= player2.y && newPosition.y <= player2.y + Player.PLAYER_HEIGHT) {
                _dir.x = -1 * _dir.x;
                return true;
            }
            else {
                _pointWinner = P1;
                return false;
            }
        }

        return true;
    }

    reset(Point playerService){
        _position = playerService;
        playerService == P1_SERVICE ? _dir = DOWN_RIGHT : _dir = DOWN_LEFT;
    }

} //----------- class Ball -----------------

class Game  {
    static const SPACE = 32;
    static const INTRO = 13;

    // Speed control. Smaller numbers make te game run faster
    static const num GAME_SPEED = 50;
    // To calculate how much time pass between frame updates
    num _lastTimeStamp = 0;

    Game() {
        run();
    }

  void start(){
        player1.reset();
        player2.reset();
        ball.reset(Ball.P1_SERVICE);
        scoreboard.reset();
        run();
    }

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

    Future run() async {
        update(await window.animationFrame);
    }

    void update(num delta) {
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