// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/ship/license.volt (BOOST ver. 1.0).
module ship.http.windows;

version(Windows):

import core.windows.windows;
import ship.http.winhttp;


class Http
{
private:
	HINTERNET hSession;
	Request[] mNew;
	Request[] mReqs;

public:
	this()
	{
		immutable(wchar)[] name = convert8To16("ShipHttp");

		hSession = WinHttpOpen(name.ptr,
			WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
			WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS,
			WINHTTP_FLAG_ASYNC);
	}

	bool isEmpty()
	{
		return mNew.length == 0 && mReqs.length == 0;
	}

	void perform()
	{
		foreach(req; mNew) {
			req.fire();
			mReqs ~= req;
		}
		mNew = null;

		size_t count;
		foreach(i, req; mReqs) {
			if (!req.mDone) {
				mReqs[count++] = req;
			}
		}

		mReqs = mReqs[0 .. count];
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
	HINTERNET mCon, mReq;

	bool mError;
	bool mDone;

	char* mHeader;
	size_t mHeaderSize;

	void* mData;
	size_t mDataSize;

	char* mDebug;
	size_t mDebugSize;

public:
	this(Http http)
	{
		assert(http !is null);
		this.mHttp = http;
		http.mNew ~= this;
	}

	~this()
	{
		cleanup();
		if (mHeader !is null) {
			free(cast(void*)mHeader);
		}
		if (mData !is null) {
			free(mData);
		}
		if (mDebug !is null) {
			free(cast(void*)mDebug);
		}
	}

	string getString()
	{
		return new string((cast(char*)mData)[0 .. mDataSize]);
	}

private:
	void fire()
	{
		immutable(wchar)* actionPtr = null; // Get can be null
		immutable(wchar)* serverPtr = convert8To16(this.server).ptr;
		immutable(wchar)* urlPtr = convert8To16(this.url).ptr;
		BOOL bResults;

		mCon = WinHttpConnect(
			mHttp.hSession, serverPtr, port, 0);
		if (mCon is null) {
			return raiseError();
		}

		mReq = WinHttpOpenRequest(
			mCon, actionPtr, urlPtr, null,
			WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES,
			secure ? WINHTTP_FLAG_SECURE : 0);
		if (mReq is null) {
			return raiseError();
		}

		WinHttpSetStatusCallback(mReq, callbackFunction,
			WINHTTP_CALLBACK_FLAG_ALL_NOTIFICATIONS, 0);

		bResults = WinHttpSendRequest(
			mReq, WINHTTP_NO_ADDITIONAL_HEADERS, 0,
			WINHTTP_NO_REQUEST_DATA, 0, 0, cast(DWORD_PTR)this);
		if (!bResults) {
			return raiseError();
		}
	}

	void receive()
	{
		// Tell WinHttp to start reading headers and data.
		if (!WinHttpReceiveResponse(mReq, null)) {
			raiseError();
		}
	}

	void queryData()
	{
		if (!WinHttpQueryDataAvailable(mReq, null)) {
			raiseError();
		}
	}

	void redirected()
	{

	}

	void readHeaders()
	{
		DWORD size;
		if (!WinHttpQueryHeaders(
			mReq, WINHTTP_QUERY_RAW_HEADERS_CRLF,
			WINHTTP_HEADER_NAME_BY_INDEX, null, &size,
			WINHTTP_NO_HEADER_INDEX)) {

			DWORD err = GetLastError();
			if (err != 122/*ERROR_INSUFFICIENT_BUFFER*/) {
				return raiseError();
			}
		}

		if (size == 0) {
			return;
		}

		mHeader = cast(char*)realloc(cast(void*)mHeader, size);
		if (!WinHttpQueryHeaders(
			mReq, WINHTTP_QUERY_RAW_HEADERS_CRLF,
			WINHTTP_HEADER_NAME_BY_INDEX, cast(void*)mHeader,
			&size, WINHTTP_NO_HEADER_INDEX)) {
			free(cast(void*)mHeader);
			return raiseError();
		}

		// Move onto reading data.
		queryData();
	}

	void readData(size_t size)
	{
		if (size == 0) {
			raiseCompleted();
			return;
		}

		mData = realloc(mData, mDataSize + size);
		if (!WinHttpReadData(mReq, mData + mDataSize,
		    cast(DWORD)size, null)) {
			raiseError();
		}

		// Update the total size.
		mDataSize += size;
	}

	void cleanup()
	{
		if (mReq !is null) {
			WinHttpSetStatusCallback(mReq,
				cast(WINHTTP_STATUS_CALLBACK)null, 0, 0);
			WinHttpCloseHandle(mReq);
			mReq = null;
		}

		if (mCon !is null) {
			WinHttpCloseHandle(mCon);
			mCon = null;
		}
	}

	void raiseCompleted()
	{
		cleanup();
		mDone = true;
	}

	void raiseError()
	{
		cleanup();
		mError = true;
		mDone = true;
	}

	void debugStr(string str)
	{
		auto newSize = str.length + mDebugSize + 1;

		mDebug = cast(char*)realloc(cast(void*)mDebug, newSize);
		mDebug[mDebugSize .. mDebugSize + str.length] = str;
		mDebug[newSize-1] = '\n';
		mDebugSize = newSize;
	}
}

private:

import core.stdc.stdlib : realloc, free;

extern(Windows) void callbackFunction(
	HINTERNET hInternet,
	DWORD_PTR dwContext,
	DWORD     dwInternetStatus,
	LPVOID    lpvStatusInformation,
	DWORD     dwStatusInformationLength
)
{
	if (dwContext == 0) {
		return;
	}

	Request req = cast(Request)dwContext;
	switch (dwInternetStatus) {
	case WINHTTP_CALLBACK_STATUS_SENDREQUEST_COMPLETE:
		req.receive();
		break;
	case WINHTTP_CALLBACK_STATUS_HEADERS_AVAILABLE:
		req.readHeaders();
		break;
	case WINHTTP_CALLBACK_STATUS_DATA_AVAILABLE:
		req.readData(*cast(LPDWORD)lpvStatusInformation);
		break;
	case WINHTTP_CALLBACK_STATUS_READ_COMPLETE:
		if (dwStatusInformationLength == 0) {
			req.raiseError();
		} else {
			req.queryData();
		}
		break;
	case WINHTTP_CALLBACK_STATUS_REDIRECT:
		req.redirected();
		break;
	case WINHTTP_CALLBACK_STATUS_REQUEST_ERROR:
		req.raiseError();
		break;
	default:
	}
}

enum uint CP_UTF8 = 65001;
extern(Windows) int MultiByteToWideChar(
	uint CodePage, DWORD  dwFlags, LPCSTR lpMultiByteStr, int cbMultiByte,
	LPWSTR lpWideCharStr, int cchWideChar);

immutable(wchar)[] convert8To16(const(char)[] str)
{
	int numChars = MultiByteToWideChar(CP_UTF8, 0, str.ptr, -1, null, 0);
	auto w = new wchar[](numChars+1);

	numChars = MultiByteToWideChar(CP_UTF8, 0, str.ptr, -1, w.ptr, numChars);
	w[numChars] = 0;
	w = w[0 .. numChars];
	return cast(immutable(wchar)[])w;
}
