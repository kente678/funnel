/*
    The model for asynchronous computation used in this class is heavily inspired 
    by Mochikit(http://mochikit.com/) and Twisted(http://twistedmatrix.com/trac/).
*/

package funnel.async
{
	import flash.events.Event;
	
	public class Task {
		
		private var chain:Array;
		private var finished:Boolean;
		private var res:*;
		private var onFired:Function;
		protected var status:int;
		
		public function Task(funcs:Array = null) {
			chain = [];
	    	finished = false;
	    	status = -1;
	    	
	    	if (funcs != null) {
		    	for each (var f:Function in funcs) {
		    		chain.push([f, null]);
		    	}
	    	}
		}
		
		public function set completed(f:Function):void {
			chain.push([f, null]);
			notify();
	    }
	    
	    public function set failed(f:Function):void {
	        chain.push([null, f]);
	        notify();
	    }
	    
	    public function set anyway(f:Function):void {
	        chain.push([f, f]);
	        notify();
	    }
	    
	    private function notify():void {
	    	if (finished) {
				finished = false;
				fire();
			}
	    }
		
		public function complete(res:* = null):Task {
			if (status != -1) throw Error('complete() can be called only once');
			status = 0;
			this.res = res;
			fire();
			return this;
		}
		
		public function fail(res:* = null):Task {
			if (status != -1) throw Error('fail() can be called only once');
			status = 1;
			this.res = res;
			fire();
			return this;
		}
		
		public function cancel():void {
        	if (status == -1) {
        		onCanceled();
	            if (status == -1) fail(new Error('task was canceled'));
	        } else if (res is Task) {
	            res.cancel();
	        }
		}
		
		protected function onCanceled():void {}
		
		private function fire():void {
			if (chain.length > 0) {
				var callback:Array = chain.shift();
				var f:Function = callback[status];
				if (f == null) {
					fire();
					return;
				}
				
				if (res) {
					try {res = f(res);}
					catch (argerr:ArgumentError) {res = f();}
				} else {
					res = f();
				}
                
                if (res is Task) {
	                res.onFired = resume;
	                res.notify();
                } else {
                	fire();
                }
            } else {
            	finished = true;
            	if (onFired != null) onFired();
            }
		}
		
		private function resume():void {
			var task:Task = res as Task;
			task.onFired = null;
			status = task.status;
			res = task.res;
			fire();
		}
	}
}