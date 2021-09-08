// List environment variables.
// Ref: https://www.golangprograms.com/how-to-set-get-and-list-environment-variables.html
package main

import (
  "os"
  "fmt"
  "strings"
)

func main() {
	// Set custom env variable
	_, exists := os.LookupEnv("FRANKIE")
  if !exists {
  	os.Setenv("FRANKIE", "poo")
  }

	// fetch specific env variables
	fmt.Println("HOSTNAME=>", os.Getenv("HOSTNAME"))

	// fetcha all env variables
	for _, pair := range os.Environ() {
  	kv := strings.Split(pair, "=")
    fmt.Println(kv[0],"=>",kv[1])
  }
}
