package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

enum GameState {
	Paused;
	Playing;
}

enum Player {
	Human;
	AI;
}

class Main extends Sprite 
{
	var inited:Bool;
	
	private var platform1:Platform;
	private var platform2:Platform;
	private var ball:Ball;

	private var currentGameState:GameState;
	private var scorePlayer:Int;
	private var scoreAI:Int;

	private var scoreField:TextField;
	private var messageField:TextField;

	private var arrowKeyUp:Bool;
	private var arrowKeyDown:Bool;
	private var platformSpeed:Int;

	private var ballMovement:Point;
	private var ballSpeed:Int;
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
		platform1 = createPlatform(5,200);
		this.addChild(platform1);
		platform2 = createPlatform(480,200);
		this.addChild(platform2);

		ball = createBall(250,250);
		this.addChild(ball);

		var scoreFormat:TextFormat = new TextFormat("Verdana" , 24, 0xbbbbbb, true);
		scoreFormat.align = TextFormatAlign.CENTER;

		scoreField = new TextField();
		addChild(scoreField);
		scoreField.width = 500;
		scoreField.y = 30;
		scoreField.defaultTextFormat = scoreFormat;
		scoreField.selectable = false;

		var messageFormat:TextFormat = new TextFormat("Verdana", 18, 0xbbbbbb, true);
		messageFormat.align = TextFormatAlign.CENTER;

		messageField = new TextField();
		addChild(messageField);
		messageField.width = 500;
		messageField.y = 450;
		messageField.defaultTextFormat = messageFormat;
		messageField.selectable = false;
		messageField.text = "Press SPACE to start\nUse ARROW KEYS to move your platform";

		scorePlayer = 0;
		scoreAI = 0;

		arrowKeyUp = false;
		arrowKeyDown = false;
		platformSpeed = 7;
		ballSpeed = 7;
		ballMovement = new Point(0,0);

		setGameState(Paused);

		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);

		this.addEventListener(Event.ENTER_FRAME, everyFrame);
	}

	private function everyFrame(event:Event):Void {
		if (currentGameState == Playing){
			if (arrowKeyUp) {
				platform1.y -= platformSpeed;
			}
			if (arrowKeyDown) {
				platform1.y += platformSpeed;
			}
			if (platform1.y < 5) platform1.y = 5;
			if (platform1.y > 395) platform1.y = 395;
			ball.x += ballMovement.x;
			ball.y += ballMovement.y;
			if (ball.y < 5 || ball.y > 495) ballMovement.y *= -1;
			if (ball.x <5) winGame(AI);
			if (ball.x > 495) winGame(Human);
			if (ballMovement.x < 0 && ball.x < 30 && ball.y >= platform1.y && ball.y <= platform1.y + 100) {
				bounceBall();
				ball.x = 30;
			}
			if (ballMovement.x > 0 && ball.x > 470 && ball.y >= platform2.y && ball.y <= platform2.y + 100) {
				bounceBall();
				ball.x = 470;
			}
			// AI platform movement
			if (ball.x > 300 && ball.y > platform2.y + 70) {
				platform2.y += platformSpeed;
			}
			if (ball.x > 300 && ball.y < platform2.y + 30) {
				platform2.y -= platformSpeed;
			}
			// AI platform limits
			if (platform2.y < 5) platform2.y = 5;
			if (platform2.y > 395) platform2.y = 395;
 		}
	}

	private function winGame(player:Player):Void {
		if (player == Human) {
			scorePlayer++;
		} else {
			scoreAI++;
		}
		setGameState(Paused);
	}

	private function keyDown(event:KeyboardEvent):Void {
		if (event.keyCode == 32 ) {
			if (currentGameState == Paused) {
				setGameState(Playing);
			} else {
				setGameState(Paused);
			}
		} else if (event.keyCode ==38) {
			arrowKeyUp = true;
		} else if (event.keyCode == 40) {
			arrowKeyDown = true;
		}
	}

	private function keyUp(event:KeyboardEvent):Void {
		if (event.keyCode == 38) { //Up
			arrowKeyUp = false;
		} else if (event.keyCode == 40) { //Down
			arrowKeyDown = false;
		}
	}

	private function updateScore():Void {
		scoreField.text = scorePlayer + ":" + scoreAI;
	}

	private function setGameState(state:GameState):Void {
		currentGameState = state;
		updateScore();
		if (state == Paused) {
			messageField.alpha = 1;
		} else {
			messageField.alpha = 0;
			platform1.y = 200;
			platform2.y = 200;

			// centre the ball
			ball.x = 250;
			ball.y = 250;

			//randomize ball vector
			var direction:Int = (Math.random() > .5)?(1):(-1);
			var randomAngle:Float = (Math.random() * 2 * Math.PI / 2) - 45;
			ballMovement.x = direction * Math.cos(randomAngle) * ballSpeed;
			ballMovement.y = Math.sin(randomAngle) * ballSpeed;
		}
	}

	private function bounceBall():Void {
		var direction:Int = (ballMovement.x > 0)?( -1):(1);
		var randomAngle:Float = (Math.random() * Math.PI / 2) - 45;
		ballMovement.x = direction * Math.cos(randomAngle) * ballSpeed;
		ballMovement.y = Math.sin(randomAngle) * ballSpeed;
	}

	private function createPlatform(x, y) {
		var platform:Platform = new Platform();
		platform.x = x;
		platform.y = y;
		return platform;
	}

	private function createBall(x, y) {
		var ball:Ball = new Ball();
		ball.x = x;
		ball.y = y;
		return ball;
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
		//
	}
}