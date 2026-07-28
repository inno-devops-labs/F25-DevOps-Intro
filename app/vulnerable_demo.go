package main

import jwt "github.com/dgrijalva/jwt-go"

// This file exists for one CI demonstration commit only.
var vulnerableDemoResult = jwt.MapClaims{
	"aud": []string{"unexpected"},
}.VerifyAudience("quicknotes", false)
