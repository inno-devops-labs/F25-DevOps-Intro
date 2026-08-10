package main

import (
	"encoding/json"
	"fmt"
	"os"
	"time"
)

var moscow = time.FixedZone("MSK", 3*60*60)

type timeResponse struct {
	Unix       int64  `json:"unix"`
	ISO        string `json:"iso"`
	HourMinute string `json:"hour_minute"`
	Zone       string `json:"zone"`
}

// This is the CGI-shaped model: request context arrives in environment
// variables, the response goes to stdout, and the process exits. There is no
// server loop — the host invokes the module once per request.
func main() {
	method := os.Getenv("REQUEST_METHOD")
	path := os.Getenv("PATH_INFO")

	if method != "" && method != "GET" {
		fmt.Println("Status: 405 Method Not Allowed")
		fmt.Println()
		return
	}
	if path != "" && path != "/time" {
		fmt.Println("Status: 404 Not Found")
		fmt.Println()
		return
	}

	now := time.Now().In(moscow)
	body, err := json.Marshal(timeResponse{
		Unix:       now.Unix(),
		ISO:        now.Format(time.RFC3339),
		HourMinute: now.Format("15:04"),
		Zone:       "Europe/Moscow (UTC+3)",
	})
	if err != nil {
		fmt.Println("Status: 500 Internal Server Error")
		fmt.Println()
		return
	}

	fmt.Println("Content-Type: application/json")
	fmt.Println()
	fmt.Println(string(body))
}
