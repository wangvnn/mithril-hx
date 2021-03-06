package  ;

#if js
#if !nodejs
import haxe.Serializer;
import haxe.Unserializer;
#end
import js.Browser;
import js.html.Event;
import js.html.InputElement;
import js.html.Storage;
import js.Lib;
#end

import haxe.ds.IntMap;
import haxe.Json;
import mithril.M;
import mithril.M.Vnodes;

class ChainModel extends IntMap<Bool>
{
	#if !nodejs
	static var storage = Browser.window.localStorage;
	#end

	public function new() {
		super();
		load();
	}

	public function isChecked(index) {
		return get(index) == true;
	}

	public function toggle(index : Int) {
		if (dateAt(index).getTime() > today().getTime()) return;
		set(index, get(index) == null ? true : !get(index));
		save();
	}	
	
	public function clear() {
		for(key in keys()) this.remove(key);
		resetDate();
		save();
	}

	public function load() : Void {
		#if !nodejs
		for (key in keys()) this.remove(key);
		
		try {
			var loaded : ChainModel = cast Unserializer.run(storage.getItem("chain-app-list"));
			for (key in loaded.keys()) this.set(key, loaded.get(key));
		} catch (e : Dynamic) {}
		#end
	}

	public function save() : Void {
		#if !nodejs
		var ser = new Serializer();
		ser.serialize(this);
		storage.setItem("chain-app-list", ser.toString());
		#end
	}

	public function today() : Date {
		var now = Date.now();
		return new Date(now.getFullYear(), now.getMonth(), now.getDay(), 0, 0, 0);
	}

	public function resetDate() : Float {
		var time = today().getTime();
		#if !nodejs
		storage.setItem("chain-app.start-date", Std.string(time));
		#end
		return time;
	}

	public function startDate() : Date {
		#if nodejs
		var date = null;
		#else
		var date = Std.parseInt(storage.getItem("chain-app.start-date"));
		#end
		return Date.fromTime(date == null ? resetDate() : date);
	}

	public function dateAt(days) : Date {
		return Date.fromTime(startDate().getTime() + days * 60 * 60 * 24);
	}
}

class ChainComponent implements Mithril
{
	var model : ChainModel;

	public function new(model : ChainModel) {
		this.model = model;
	}

	public function view() {
		m("table", seven(function(y) {
			m("tr", seven(function(x) {
				var index = indexAt(x, y);
				m("td", highlights(index), [
					m("input[type=checkbox]", checks(index))
				]);
			}));
		}));
	}

	private function seven(view) {
		var i = -1;
		return [while (i++ < 6) view(i)];
	}

	public function checks(index : Int) {
		return {
			onclick: model.toggle.bind(index),
			checked: model.isChecked(index)
		};
	}

	public function highlights(index) {
		return {
			style: {
				background: model.dateAt(index).getTime() == model.today().getTime() ? "silver" : ""
			}
		}
	}

	private function indexAt(x, y) return y * 7 + x;
}