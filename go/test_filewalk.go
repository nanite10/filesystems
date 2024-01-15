package main

import (
  "fmt"
  "log"
  "os"
  "path/filepath"
)

func main(){
  currentDirectory, err := os.Getwd()
  if err != nil {
    log.Fatal(err)
  }
  iterate(currentDirectory)
}

func iterate(path string){
  filepath.Walk(path, func(path string, info os.FileInfo, err error) error{
    if err != nil {
      log.Fatalf(err.Error())
    }
    fmt.Printf("File Name: %s\n", info.Name())
    return nil
  })
}
