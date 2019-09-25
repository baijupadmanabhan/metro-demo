package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
)

type PassDetails struct {
	SecretKey string `json:"secretkey"`
}

const charSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + "abcdefghijklmnopqrstuvwxyz" + "0123456789" + "!#@$%"

func randPasswd(charlen int) string {
	passwd := make([]byte, charlen)
	for x := range passwd {
		passwd[x] = charSet[rand.Intn(len(charSet))]
	}
	return string(passwd)
}

func generateToken(w http.ResponseWriter, r *http.Request) {

	rand.Seed(time.Now().UnixNano())
	finalString := randPasswd(85)

	passwdDetail := PassDetails{SecretKey: finalString}

	fmt.Println(finalString)
	json.NewEncoder(w).Encode(passwdDetail)
}

func generateTokenLimited(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)

	num, err := strconv.Atoi(params["param"])
	if err == nil {
		rand.Seed(time.Now().UnixNano())
		finalString := randPasswd(int(num))

		passwdDetail := PassDetails{SecretKey: finalString}

		fmt.Println(finalString)
		json.NewEncoder(w).Encode(passwdDetail)
	}
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Application Health OK.")
}

func handleRequest() {
	reqRouter := mux.NewRouter().StrictSlash(true)

	reqRouter.HandleFunc("/health", healthCheck).Methods("GET")
	reqRouter.HandleFunc("/accessid", generateToken).Methods("GET")
	reqRouter.HandleFunc("/accessid/{param}", generateTokenLimited).Methods("GET")
	log.Fatal(http.ListenAndServe(":8080", reqRouter))
}

func main() {
	handleRequest()
}
