#!/bin/bash

for filename in *.svg; do convert -background none -density 385 $filename ${filename%.svg}.png; done
