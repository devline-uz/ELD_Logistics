package main

import (
	"fmt"
	"os"

	"github.com/devline/onebook-eld/internal/auth"
)

func main() {
	for _, pw := range os.Args[1:] {
		h, err := auth.HashPassword(pw)
		if err != nil {
			fmt.Println("ERR", err)
			os.Exit(1)
		}
		fmt.Printf("%s\t%s\n", pw, h)
	}
}
