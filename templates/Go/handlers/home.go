package handlers

import (
	"net/http"
)

func HomeHandler(response http.ResponseWriter, request *http.Request) {
	var statusCode int

	defer func() {
		LogHTTPTraffic(request, statusCode)
	}()

	switch request.Method {
	case "GET":
		data := map[string]string{
			"title":  "Home",
			"header": "Welcome To The Homepage",
		}

		statusCode = http.StatusOK
		err := tmpl.ExecuteTemplate(response, "home.html", data)
		if err != nil {
			statusCode = http.StatusInternalServerError
			response.WriteHeader(statusCode)
		}
	default:
		statusCode = http.StatusMethodNotAllowed
		response.WriteHeader(statusCode)
	}
}
