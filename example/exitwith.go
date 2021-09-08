// Exits with a given status and writes to STDLOG
// Ref: https://www.golangprograms.com/how-to-set-get-and-list-environment-variables.html
package main
import (
  "os"
  "log"
  "strconv"
)

func main() {

	logger := log.New(
		os.NewFile(3, ""), "DEBUG: ", log.Ldate|log.Ltime|log.Lshortfile,
	)
	logger.Printf("Enter -- status=%s", os.Args[1])

	v, err := strconv.Atoi(os.Args[1])
	defer logger.Printf("Exit -- status=%s", &v)

	if err != nil {
		logger.Fatalf("Failed to cast argument to uint")
		v = 128
	}
  os.Exit(v)
}
