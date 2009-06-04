package funnel
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	/**
	 * @copy PinEvent#CHANGE
	 */
	[Event(name="change",type="PinEvent")]
	
	/**
	 * @copy PinEvent#RISING_EDGE
	 */
	[Event(name="risingEdge",type="PinEvent")]
	
	/**
	 * @copy PinEvent#FALLING_EDGE
	 */
	[Event(name="fallingEdge",type="PinEvent")]
	
	/**
	 * I/Oモジュールの入出力ポートを表すクラスです。
	 */ 
	public class Pin extends EventDispatcher
	{
		/**
		 * アナログ入力
		 */
		public static const AIN:uint = 0;

		/**
		 * デジタル入力
		 */
		public static const DIN:uint = 1;

		/**
		 * アナログ出力
		 */
		public static const AOUT:uint = 2;
		public static const PWM:uint = AOUT;

		/**
		 * デジタル出力
		 */
		public static const DOUT:uint = 3;
		
		private var _value:Number;
		private var _lastValue:Number;
		private var _number:uint;
		private var _type:uint; 
		private var _filters:Array;
		private var _generator:IGenerator;
		private var _sum:Number;
		private var _average:Number;
		private var _minimum:Number;
		private var _maximum:Number;
		private var _numSamples:Number;
		private static const MAX_SAMPLES:Number = Number.MAX_VALUE;
		private var _debounceInterval:int;
		private var _lastRisingEdge:int;
		private var _lastFallingEdge:int;
		
		/**
		 * 
		 * @param number ポート番号
		 * @param type ポートのタイプ(AIN、DIN、AOUT、DOUT)
		 * 
		 */		
		public function Pin(number:uint, type:uint) {
			_number = number;
			_type = type;
			_value = 0;
			_lastValue = 0;
			_minimum = 1;
			_maximum = 0;
			_average = 0;
			_sum = 0;
			_numSamples = 0;
			_debounceInterval = 0;
			_lastRisingEdge = 0;
			_lastFallingEdge = 0;
		}
		
		/**
		 * ポート番号
		 * 
		 */		
		public function get number():uint {
			return _number;
		}
		
		/**
		 * ポートのタイプ(AIN、DIN、AOUT、DOUT)
		 * 
		 */		
		public function get type():uint {
			return _type;
		}
		
		/**
		 * センサからの入力値、またはアクチュエータへの出力値
		 * 
		 */		
		public function get value():Number {
			return _value;
		}
		
		public function set value(val:Number):void {
			calculateMinimumMaximumAndMean(val);
			_lastValue = _value;
			_value = applyFilters(val);
			detectEdge(_lastValue, _value);
		}
		
		/**
		 * ポートの変化する前の値
		 * 
		 */		
		public function get lastValue():Number {
			return _lastValue;
		}
		
		/**
		 * 
		 * 平均値
		 * 
		 */		
		public function get average():Number {
			return _average;
		}
		
		/**
		 * 
		 * 最小値
		 * 
		 */		
		public function get minimum():Number {
			return _minimum;
		}
		
		/**
		 * 
		 * 最大値
		 * 
		 */		
		public function get maximum():Number {
			return _maximum;
		}
		
		/**
		 * ポートに適応するフィルタ配列
		 * 
		 */		
		public function get filters():Array {
			return _filters;
		}
		

		/**
		 * 
		 * @param interval set interval for debouncing
		 * 
		 */
		public function set debounceInterval(interval:int):void {
			_debounceInterval = interval;
		}

		/**
		 * 
		 * @param interval get interval for debouncing
		 * 
		 */
		public function get debounceInterval():int {
			return _debounceInterval;
		}

		public function set filters(array:Array):void {
			if (_generator != null) {
				_generator.removeEventListener(GeneratorEvent.UPDATE, autoSetValue);
			}
			
			if (array == null || array.length == 0) {
				_filters = array;
				return;
			}
			
			var lastIndexOfGenerator:uint = 0;
			for (var i:int = array.length - 1; i >= 0; --i) {
				if (array[i] is IFilter) {
					;
				} else if (array[i] is IGenerator) {
					lastIndexOfGenerator = i;
					_generator = array[i] as IGenerator;
					_generator.addEventListener(GeneratorEvent.UPDATE, autoSetValue);
					break;
				} else {
					return;
				}
			}
			_filters = array.slice(lastIndexOfGenerator);
		}
		
		public function addFilter(newFilter:*):void {
			if (newFilter == null) {
				return;
			}

			if (_filters == null) {
				_filters = new Array();
			}

			if (newFilter is IFilter) {
				;
			} else if (newFilter is IGenerator) {
				if (_generator != null) {
					_generator.removeEventListener(GeneratorEvent.UPDATE, autoSetValue);
				}
				_generator = newFilter;
				_generator.addEventListener(GeneratorEvent.UPDATE, autoSetValue);
			} else {
				return;
			}

			_filters.push(newFilter);
		}

		public function setFilters(newFilters:Array):void {
			filters = newFilters;
		}

		public function removeAllFilters():void {
			filters = null;
		}

		private function autoSetValue(event:Event):void {
			value = _generator.value;
		}
		
		/**
		 * ヒストリをリセットします。
		 * 
		 */		
		public function clear():void {
			_minimum = _maximum = _average = _lastValue = _value;
			clearWeight();
		}
		
		private function clearWeight():void {
			_sum = _average;
			_numSamples = 1;
		}
		
		private function calculateMinimumMaximumAndMean(val:Number):void {
			_minimum = Math.min(val, _minimum);
			_maximum = Math.max(val, _maximum);
			
			_sum += val;
			_average = _sum / (++_numSamples);
			if (_numSamples >= MAX_SAMPLES) {
				clearWeight();
			}
		}
		
		private function detectEdge(oldValue:Number, newValue:Number):void {
			if (oldValue == newValue) return;

			var now:int = getTimer();

			dispatchEvent(new PinEvent(PinEvent.CHANGE));
			
			if ((oldValue == 0 && newValue != 0) && ((now - _lastRisingEdge) >= _debounceInterval)) {
				dispatchEvent(new PinEvent(PinEvent.RISING_EDGE));
				_lastRisingEdge = now;
			} else if ((oldValue != 0 && newValue == 0) && ((now - _lastFallingEdge) >= _debounceInterval)) {
				dispatchEvent(new PinEvent(PinEvent.FALLING_EDGE));
				_lastFallingEdge = now;
			}
		}
		
		private function applyFilters(val:Number):Number {
			if (_filters == null) return val;
			
			var result:Number = val;
			for (var i:uint = 0; i < _filters.length; ++i) {
				if (_filters[i] is IFilter) {
					result = _filters[i].processSample(result);
				}
			}
			return result;
		}
		
	}
}