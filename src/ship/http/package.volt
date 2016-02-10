// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/ship/license.volt (BOOST ver. 1.0).
module ship.http;

version (Windows) {
	public import ship.http.windows;
} else {
	public import ship.http.curl;
}
