package main

import (
  "fmt"
  "log"
  "os"
  "strconv"
  "path/filepath"
)

func check(e error){
  if e != nil {
    panic(e)
  }
}

func main(){
  scratchPath := "Scratch"

  err := os.Mkdir(scratchPath,0755)
  check(err)

  for curIteration := 1; curIteration <= 1000; curIteration++{
    curIterationStr := strconv.Itoa(curIteration)
    curDirectory := scratchPath + "/dir" + curIterationStr
    err := os.Mkdir(curDirectory,0755)
    check(err)
  }
  // iterate(currentDirectory)
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
