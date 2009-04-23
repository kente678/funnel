package {	import flash.display.Shape;	import flash.display.Sprite;	import flash.events.Event;	import flash.events.MouseEvent;	import funnel.*;	/**	 * AD0/DIO0の状態をシンプルなグラフとして表示し、	 * AD5/DIO5の状態をマウスでコントロールする。	 * Display status of AD0/DIO0 as a simple graph and	 * Control status of AD5/DIO5 by the mouse.	 *	 * <p>準備<ol>	 * <li>AD0/DIO0にセンサを接続する（例：ボリューム）</li>	 * <li>AD5/DIO5にLEDを接続する（電流制限のための抵抗器が必要）</li>	 * </ol></p>	 *	 * <p>Preparation<ol>	 * <li>Connect a sensor to AD0/DIO0 (e.g. a potentiometer)</li>	 * <li>Connect a LED to AD5/DIO5 (current-limiting resistor is needed)</li>	 * </ol></p>	 */	public class XBeeTest extends Sprite {		// To change number of analog channels, modify this constant		// 表示するアナログチャンネル数を変更するにはこの定数を変更する		private const NUM_CHANNELS:int = 1;		private var xio:XBee;		private var scope:SimpleScope;		private var scopes:Array;		private var led:Pin;		public function XBeeTest() {			var config:Configuration = XBee.MULTIPOINT;			config.setDigitalPinMode(0, AIN);			config.setDigitalPinMode(5, OUT);			xio = new XBee([1], config);			led = xio.ioModule(1).pin(5);			xio.addEventListener(FunnelEvent.READY, trace);			xio.addEventListener(FunnelErrorEvent.REBOOT_ERROR, trace);			xio.addEventListener(FunnelErrorEvent.CONFIGURATION_ERROR, trace);			xio.addEventListener(FunnelErrorEvent.ERROR, trace);			scopes = new Array(NUM_CHANNELS);			for (var i:int = 0; i < NUM_CHANNELS; i++) {				scopes[i] = new SimpleScope(10, 10 + (60 * i), 200);				addChild(scopes[i]);			}			var sprite:Sprite = new Sprite();			addChild(sprite);			sprite.graphics.beginFill(0x000000);			sprite.graphics.drawCircle(375, 60, 20);			sprite.addEventListener(MouseEvent.MOUSE_DOWN, mousePressed);			sprite.addEventListener(MouseEvent.MOUSE_UP, mouseReleased);			sprite.buttonMode = true;			addEventListener(Event.ENTER_FRAME, loop);		}		private function loop(event:Event):void {			for (var i:int = 0; i < NUM_CHANNELS; i++) {				scopes[i].update(xio.ioModule(1).pin(i));			}		}		private function mousePressed(e:Event):void {			led.value = 1;		}		private function mouseReleased(e:Event):void {			led.value = 0;		}	}}