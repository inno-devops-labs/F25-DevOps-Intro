package main

import (
	"encoding/json"
	"net/http"
	"time"

	spinhttp "github.com/spinframework/spin-go-sdk/v3/http"
)

// Russia abolished DST in 2011, so Moscow is a constant UTC+3 offset and needs
// no tzdata lookup — which matters because the wasip2 sandbox has no
// /usr/share/zoneinfo to read.
var moscow = time.FixedZone("MSK", 3*60*60)

type timeResponse struct {
	Unix       int64  `json:"unix"`
	ISO        string `json:"iso"`
	HourMinute string `json:"hour_minute"`
	Zone       string `json:"zone"`
}

func init() {
	spinhttp.Handle(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			w.Header().Set("Allow", "GET")
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}

		now := time.Now().In(moscow)
		resp := timeResponse{
			Unix:       now.Unix(),
			ISO:        now.Format(time.RFC3339),
			HourMinute: now.Format("15:04"),
			Zone:       "Europe/Moscow (UTC+3)",
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(resp); err != nil {
			http.Error(w, "encoding failed", http.StatusInternalServerError)
		}
	})
}

// main is required by the compiler but never executed — the entry point is the
// handler registered in init().
func main() {}
