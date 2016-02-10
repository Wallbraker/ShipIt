// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/ship/license.volt (BOOST ver. 1.0).
module ship.http.curl;

version (!Windows):

import core.stdc.stdlib : realloc, free;

import watt.io : output;

import ship.http.libcurl;


class Http
{
private:
	CURLM* mMulti;
	Request[] mNew;
	Request[] mReqs;

public:
	this()
	{
		mMulti = curl_multi_init();
	}

	~this()
	{
		foreach (req; mReqs) {
			req.cleanup();
		}

		if (mMulti !is null) {
			curl_multi_cleanup(mMulti);
			mMulti = null;
		}
	}

	bool isEmpty()
	{
		return mNew.length == 0 && mReqs.length == 0;
	}

	void perform()
	{
		if (mMulti is null) {
			return;
		}

		foreach (req; mNew) {
			req.fire();
			mReqs ~= req;
		}
		mNew = null;

		int num;
		curl_multi_perform(mMulti, &num);

		if (num == cast(int)mReqs.length) {
			return;
		}

		// We know that there is at least one message left.
		num = 1;

		// Get all messages from the multi.
		while (num > 0) {
			auto m = curl_multi_info_read(mMulti, &num);
			if (m is null ||
			    m.msg != CURLMSG.CURLMSG_DONE) {
				continue;
			}

			// Get and remove request from array.
			Request req;
			foreach (i, loopReq; mReqs) {
				if (req !is null) {
					mReqs[i-1] = loopReq;
				}
				if (loopReq.mEasy is m.easy_handle) {
					req = loopReq;
					continue;
				}
			}
			mReqs = mReqs[0 .. $-1];

			curl_multi_remove_handle(mMulti, req.mEasy);
			req.raiseDone();
		}
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
	CURL* mEasy;
	string mUrl;

	size_t mDataSize;
	void* mData;

	bool mError;
	bool mDone;

public:
	this(Http http)
	{
		mHttp = http;
		http.mNew ~= this;
	}

	~this()
	{
		cleanup();
		if (mData !is null) {
			free(mData);
			mData = null;
		}
	}

	string getString()
	{
		return new string((cast(char*)mData)[0 .. mDataSize]);
	}

private:
	void fire()
	{
		mEasy = curl_easy_init();
		if (mEasy is null) {
			return raiseError();
		}

		mUrl = secure ? "https://" : "http://";
		mUrl ~= server;
		mUrl ~= "/" ~ url;
		mUrl ~= '\0';

		curl_easy_setopt(mEasy, CURLoption.URL, mUrl.ptr);
		curl_easy_setopt(mEasy, CURLoption.PORT, cast(long)port);
		curl_easy_setopt(mEasy, CURLoption.FOLLOWLOCATION, cast(long)1);

		curl_easy_setopt(mEasy, CURLoption.READFUNCTION, myRead);
		curl_easy_setopt(mEasy, CURLoption.READDATA, this);
		curl_easy_setopt(mEasy, CURLoption.WRITEFUNCTION, myWrite);
		curl_easy_setopt(mEasy, CURLoption.WRITEDATA, this);

		curl_multi_add_handle(mHttp.mMulti, mEasy);
	}

	/**
	 * Data going from this process to the host.
	 */
	extern(C) global size_t myRead(void* buffer, size_t size,
	                               size_t nitems, void* instream)
	{
		//writefln("%s", buffer[0 .. size * nitems]);
		return size * nitems;
	}

	/**
	 * Data comming from the host to this process.
	 */
	extern(C) global size_t myWrite(void* buffer, size_t size,
	                                size_t nitems, void* outstream)
	{
		auto req = cast(Request)outstream;

		size *= nitems;
		size_t newSize = req.mDataSize + size;
		req.mData = realloc(req.mData, req.mDataSize + size);
		req.mData[req.mDataSize .. newSize] = buffer[0 .. size];

		// Update the total size.
		req.mDataSize += size;
		return size;
	}

	void raiseError()
	{
		cleanup();
		mError = true;
		mDone = true;
	}

	void raiseDone()
	{
		mDone = true;
	}

	void cleanup()
	{
		if (mEasy !is null) {
			curl_easy_cleanup(mEasy);
			mEasy = null;
		}
	}
}
