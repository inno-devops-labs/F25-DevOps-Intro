package main

import (
	"flag"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
)

func main() {
	cert := flag.String("cert", "", "path to the TLS certificate")
	key := flag.String("key", "", "path to the TLS private key")
	flag.Parse()

	target, err := url.Parse("http://127.0.0.1:8080")
	if err != nil {
		log.Fatal(err)
	}

	server := &http.Server{
		Addr:              "127.0.0.1:8443",
		Handler:           httputil.NewSingleHostReverseProxy(target),
		ReadHeaderTimeout: 5_000_000_000,
	}
	log.Fatal(server.ListenAndServeTLS(*cert, *key))
}
