#!/bin/bash

while [ 1 -eq 1 ]
do
  rm -rf _public
  lsc -c config.ls
  node_modules/brunch/bin/brunch watch --server -p 3333
  sleep 1
done
