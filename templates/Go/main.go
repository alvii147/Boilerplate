package main

import (
	"net/http"

	"github.com/{{ github_username }}/{{ project_name }}/handlers"
)

const STATIC_FILES_PATH string = "static"

func routing() {
	fs := http.FileServer(http.Dir(STATIC_FILES_PATH))
	http.Handle("/"+STATIC_FILES_PATH+"/", http.StripPrefix("/"+STATIC_FILES_PATH+"/", fs))
	http.Handle("/favicon.ico", http.NotFoundHandler())
	http.HandleFunc("/", handlers.HomeHandler)
}

func main() {
	routing()
	http.ListenAndServe(":8000", nil)
}
