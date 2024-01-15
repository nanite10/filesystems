#!/bin/bash

scratchPath="Scratch"
mkdir "$scratchPath"
if [ $? -ne 0 ]; then echo "ERROR"; exit 1; fi
for curIteration in {1..1000}; do
  curDirectory="${scratchPath}/dir${curIteration}"
  mkdir "$curDirectory"
  if [ $? -ne 0 ]; then echo "ERROR"; exit 1; fi
done
