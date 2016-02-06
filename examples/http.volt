// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/ship/license.volt (BOOST ver. 1.0).
module http;

import ship.http : Http, Request;
import watt.io : output;


int main(string[] args)
{
	auto http = new Http();
	auto req = new Request(http);
	req.server = "www.google.com";
	req.port = 80;
	req.secure = false;
	req.url = "";

	while (!http.isEmpty()) {
		http.perform();
	}

	auto str = req.getString();
	output.writefln("Data:%s\n\n%s", str.length, str);

	return 0;
}
