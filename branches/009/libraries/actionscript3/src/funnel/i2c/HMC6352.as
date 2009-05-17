﻿package funnel.i2c {	import flash.events.IEventDispatcher;	import flash.events.EventDispatcher;	import flash.events.Event;	import funnel.i2c.I2CDevice;	/**	 * This is the class to express HMC6352 devices	 *	 */	public class HMC6352 extends I2CDevice implements IEventDispatcher {		private var _heading:Number;		private var _address:uint;		private var _dispatcher:EventDispatcher;		public function HMC6352(ioModule:*, address:uint = 0x21) {			super(ioModule, address);			_address = address;			_dispatcher = new EventDispatcher(this);			_heading = 0;			_io.sendSysex(I2C_REQUEST, [WRITE, address, 'G'.charCodeAt(0), 0x74, 0x51]);			_io.sendSysex(I2C_REQUEST, [WRITE, address, 'A'.charCodeAt(0)]);			_io.sendSysex(I2C_REQUEST, [READ_CONTINUOUS, address, 0x7F, 0x02]);		}		public override function handleSysex(command:uint, data:Array):void {			if (command != I2C_REPLY) {				return;			}			_heading = (int(data[2]) * 256 + int(data[3])) / 10.0;			dispatchEvent(new Event(Event.CHANGE));		}		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{			_dispatcher.addEventListener(type, listener, useCapture, priority);		}		public function dispatchEvent(evt:Event):Boolean{			return _dispatcher.dispatchEvent(evt);		}		public function hasEventListener(type:String):Boolean{			return _dispatcher.hasEventListener(type);		}		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{			_dispatcher.removeEventListener(type, listener, useCapture);		}		public function willTrigger(type:String):Boolean {			return _dispatcher.willTrigger(type);		}		public function enterUserCalibrationMode():void {			_io.sendSysex(I2C_REQUEST, [WRITE, address, 'C'.charCodeAt(0)]);		}		public function exitUserCalibrationMode():void {			_io.sendSysex(I2C_REQUEST, [WRITE, address, 'E'.charCodeAt(0)]);		}		public function get heading():Number {			return _heading;		}	}}