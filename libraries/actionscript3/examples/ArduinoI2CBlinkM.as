package {
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import funnel.Arduino;
	import funnel.i2c.BlinkM;

	/**
	 * Arduino I2C BlinkM example
	 *
	 * Control a BlinkM from AS3 via Funnel
	 *
	 * Preparation:
	 * * upload SimpleI2CFirmata to an Arduino board
	 * 
 	 * The circuit:
	 * * outputs
	 *   - A4: the I2C data pin
	 *   - A5: the I2C clock pin
	 *
	 * Created 1 June 2009
	 * By Shigeru Kobayashi
	 *
	 * http://thingm.com/products/blinkm
	 * http://funnel.cc/
	 * http://arduino.cc/
	 * http://firmata.org/
	 */
	public class ArduinoI2CBlinkM extends Sprite {
		private var pulseGenerator:Timer;
		private var aio:Arduino;
		private var blinkM:BlinkM;

		public function ArduinoI2CBlinkM() {
			aio = new Arduino(Arduino.FIRMATA);
			blinkM = new BlinkM(aio);

			pulseGenerator = new Timer(1000);
			pulseGenerator.addEventListener(TimerEvent.TIMER, onPulse);
			pulseGenerator.start();

			blinkM.stopScript();
			blinkM.goToRGBColorNow([0, 0, 0]);
		}

		private function onPulse(e:TimerEvent):void {
			blinkM.fadeToRandomRGBColor([255, 255, 255], 50);
		}
	}
}