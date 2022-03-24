package handlers

import (
	"log"
	"net/http"
)

func LogHTTPTraffic(request *http.Request, statusCode int) {
	log.Println(request.Method, request.URL, request.Proto, statusCode, http.StatusText(statusCode))
}
