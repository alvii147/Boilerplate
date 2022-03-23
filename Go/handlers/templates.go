package handlers

import (
	"html/template"
)

const TEMPLATES_PATH string = "templates"

var tmpl *template.Template = ParseTemplates()

func ParseTemplates() *template.Template {
	return template.Must(template.ParseGlob(TEMPLATES_PATH + "/*.html"))
}
