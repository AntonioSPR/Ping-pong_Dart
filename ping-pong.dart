import 'dart:html';
import 'dart:math';
import 'dart:collection';
import 'dart:async';

const B_COLOR = "black";
const F_COLOR = "#00CC00"; // Link (Zelda) green

CanvasElement canvas = querySelector('#canvas')..focus();
CanvasRenderingContext2D ctx = canvas.getContext('2d');
Keyboard keyboard = new Keyboard();

void main() {
    // I go to use the #text element to display error messages
    Element text = querySelector('#text');
    // text.text = "canvas.width = ${canvas.width} canvas.height = ${canvas.height}";

   clear();

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



}

class Keyboard {
    // TODO
}