// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/ship/license.volt (BOOST ver. 1.0).
module ship.http.libcurl;

version (!Windows):

extern(C):


struct CURL {}
struct CURLM {}

enum CURLcode {
	CURLE_OK = 0,
	CURLE_UNSUPPORTED_PROTOCOL,
	CURLE_FAILED_INIT,
	CURLE_URL_MALFORMAT,
	CURLE_NOT_BUILT_IN,
	CURLE_COULDNT_RESOLVE_PROXY,
	CURLE_COULDNT_RESOLVE_HOST,
	CURLE_COULDNT_CONNECT,
	CURLE_FTP_WEIRD_SERVER_REPLY,
	CURLE_REMOTE_ACCESS_DENIED,
	CURLE_FTP_ACCEPT_FAILED,
	CURLE_FTP_WEIRD_PASS_REPLY,
	CURLE_FTP_ACCEPT_TIMEOUT,
	CURLE_FTP_WEIRD_PASV_REPLY,
	CURLE_FTP_WEIRD_227_FORMAT,
	CURLE_FTP_CANT_GET_HOST,
	CURLE_HTTP2,
	CURLE_FTP_COULDNT_SET_TYPE,
	CURLE_PARTIAL_FILE,
	CURLE_FTP_COULDNT_RETR_FILE,
	CURLE_OBSOLETE20,
	CURLE_QUOTE_ERROR,
	CURLE_HTTP_RETURNED_ERROR,
	CURLE_WRITE_ERROR,
	CURLE_OBSOLETE24,
	CURLE_UPLOAD_FAILED,
	CURLE_READ_ERROR,
	CURLE_OUT_OF_MEMORY,
	CURLE_OPERATION_TIMEDOUT,
	CURLE_OBSOLETE29,
	CURLE_FTP_PORT_FAILED,
	CURLE_FTP_COULDNT_USE_REST,
	CURLE_OBSOLETE32,
	CURLE_RANGE_ERROR,
	CURLE_HTTP_POST_ERROR,
	CURLE_SSL_CONNECT_ERROR,
	CURLE_BAD_DOWNLOAD_RESUME,
	CURLE_FILE_COULDNT_READ_FILE,
	CURLE_LDAP_CANNOT_BIND,
	CURLE_LDAP_SEARCH_FAILED,
	CURLE_OBSOLETE40,
	CURLE_FUNCTION_NOT_FOUND,
	CURLE_ABORTED_BY_CALLBACK,
	CURLE_BAD_FUNCTION_ARGUMENT,
	CURLE_OBSOLETE44,
	CURLE_INTERFACE_FAILED,
	CURLE_OBSOLETE46,
	CURLE_TOO_MANY_REDIRECTS ,
	CURLE_UNKNOWN_OPTION,
	CURLE_TELNET_OPTION_SYNTAX ,
	CURLE_OBSOLETE50,
	CURLE_PEER_FAILED_VERIFICATION,
	CURLE_GOT_NOTHING,
	CURLE_SSL_ENGINE_NOTFOUND,
	CURLE_SSL_ENGINE_SETFAILED,
	CURLE_SEND_ERROR,
	CURLE_RECV_ERROR,
	CURLE_OBSOLETE57,
	CURLE_SSL_CERTPROBLEM,
	CURLE_SSL_CIPHER,
	CURLE_SSL_CACERT,
	CURLE_BAD_CONTENT_ENCODING,
	CURLE_LDAP_INVALID_URL,
	CURLE_FILESIZE_EXCEEDED,
	CURLE_USE_SSL_FAILED,
	CURLE_SEND_FAIL_REWIND,
	CURLE_SSL_ENGINE_INITFAILED,
	CURLE_LOGIN_DENIED,
	CURLE_TFTP_NOTFOUND,
	CURLE_TFTP_PERM,
	CURLE_REMOTE_DISK_FULL,
	CURLE_TFTP_ILLEGAL,
	CURLE_TFTP_UNKNOWNID,
	CURLE_REMOTE_FILE_EXISTS,
	CURLE_TFTP_NOSUCHUSER,
	CURLE_CONV_FAILED,
	CURLE_CONV_REQD,
	CURLE_SSL_CACERT_BADFILE,
	CURLE_REMOTE_FILE_NOT_FOUND,
	CURLE_SSH,
	CURLE_SSL_SHUTDOWN_FAILED,
	CURLE_AGAIN,
	CURLE_SSL_CRL_BADFILE,
	CURLE_SSL_ISSUER_ERROR,
	CURLE_FTP_PRET_FAILED,
	CURLE_RTSP_CSEQ_ERROR,
	CURLE_RTSP_SESSION_ERROR,
	CURLE_FTP_BAD_FILE_LIST,
	CURLE_CHUNK_FAILED,
	CURLE_NO_CONNECTION_AVAILABLE,
	CURLE_SSL_PINNEDPUBKEYNOTMATCH,
	CURLE_SSL_INVALIDCERTSTATUS,
	CURL_LAST /* never use! */
}

enum CURLOPTTYPE_LONG          = 0;
enum CURLOPTTYPE_OBJECTPOINT   = 10000;
enum CURLOPTTYPE_STRINGPOINT   = 10000;
enum CURLOPTTYPE_FUNCTIONPOINT = 20000;
enum CURLOPTTYPE_OFF_T         = 30000;

enum CURLoption {
	WRITEDATA        = CURLOPTTYPE_OBJECTPOINT   + 1,
	URL              = CURLOPTTYPE_STRINGPOINT   + 2,
	PORT             = CURLOPTTYPE_LONG          + 3,
	READDATA         = CURLOPTTYPE_OBJECTPOINT   + 9,
	WRITEFUNCTION    = CURLOPTTYPE_FUNCTIONPOINT + 11,
	READFUNCTION     = CURLOPTTYPE_FUNCTIONPOINT + 12,
	COOKIE           = CURLOPTTYPE_STRINGPOINT   + 22,
	FOLLOWLOCATION   = CURLOPTTYPE_LONG          + 52,
}


enum size_t CURL_READFUNC_ABORT = 0x10000000;
enum size_t CURL_READFUNC_PAUSE = 0x10000001;
alias curl_read_callback = extern(C) size_t function(char *buffer,
                                                     size_t size,
                                                     size_t nitems,
                                                     void *instream);

enum size_t CURL_WRITEFUNC_PAUSE = 0x10000001;
alias curl_write_callback = extern(C) size_t function(char* buffer,
                                                      size_t size,
                                                      size_t nitems,
                                                      void* outstream);

enum CURLMcode {
	CURLM_CALL_MULTI_PERFORM = -1,
	CURLM_OK = 0,
	CURLM_BAD_EASY_HANDLE = 2,
	CURLM_OUT_OF_MEMORY = 3,
	CURLM_INTERNAL_ERROR = 4,
	CURLM_BAD_SOCKET = 5,
	CURLM_UNKNOWN_OPTION = 6,
	CURLM_ADDED_ALREADY = 7,
}

enum CURLMSG {
	CURLMSG_FIRST,
	CURLMSG_DONE,
	CURLMSG_LAST,
}

struct CURLMsg {
	CURLMSG msg;       /* what this message means */
	CURL* easy_handle; /* the handle it concerns */
	union Data {
		void* whatever;    /* message-specific data */
		CURLcode result;   /* return code for transfer */
	}
	Data data;
}

CURL* curl_easy_init();
CURLcode curl_easy_setopt(CURL *curl, CURLoption option, ...);
CURLcode curl_easy_perform(CURL *curl);
void curl_easy_cleanup(CURL *curl);

CURLM* curl_multi_init();
CURLMcode curl_multi_cleanup(CURLM *multi_handle);
CURLMcode curl_multi_perform(CURLM* multi_handle, int* running_handles);
CURLMcode curl_multi_add_handle(CURLM* multi_handle, CURL* curl_handle);
CURLMcode curl_multi_remove_handle(CURLM* multi_handle, CURL* curl_handle);
CURLMsg* curl_multi_info_read(CURLM* multi_handle, int* msgs_in_queue);
