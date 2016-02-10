// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/ship/license.volt (BOOST ver. 1.0).
module http;

import ship.http : Http, Request;
import watt.io : output;


int main(string[] args)
{
	auto http = new Http();
	auto req1 = new Request(http);
	auto req2 = new Request(http);

	req1.server = "www.google.com";
	req1.port = 80;
	req1.secure = false;
	req1.url = "";

	req2.server = "github.com";
	req2.port = 443;
	req2.secure = true;
	req2.url = "about";

	while (!http.isEmpty()) {
		http.perform();
	}

	auto str1 = req1.getString();
	auto str2 = req2.getString();
	output.writefln("Data:%s\n\n%s", str1.length, str1);
	output.writefln("Data:%s\n\n%s", str2.length, str2);
	output.writefln("Lengths %s %s", str1.length, str2.length);

	return 0;
}
