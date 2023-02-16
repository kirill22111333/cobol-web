#include <stdio.h>
#include <string.h>

#include "../../libs/http.h"

void index_page(int conn, HTTPreq *req);
void about_page(int conn, HTTPreq *req);

int main(void) {
	HTTP *serve = new_http("127.0.0.1:8000");

	handle_http(serve, "/", index_page);
    handle_http(serve, "/about", about_page);

	listen_http(serve);
	free_http(serve);
	return 0;
}

void index_page(int conn, HTTPreq *req) {
	parsehtml_http(conn, "index.html");
}

void about_page(int conn, HTTPreq *req) {
	parsehtml_http(conn, "about.html");
}
