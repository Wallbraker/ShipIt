// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/ship/license.volt (BOOST ver. 1.0).
module ship.http.curl;

version (!Windows):


class Http
{
public:
	this()
	{

	}

	bool isEmpty()
	{
		return true;
	}

	void perform()
	{
	}
}

class Request
{
public:
	string server;
	string url;
	ushort port;
	bool secure;

private:
	Http mHttp;

public:
	this(Http http)
	{
		mHttp = http;
	}

	string getString()
	{
		return null;
	}
}
