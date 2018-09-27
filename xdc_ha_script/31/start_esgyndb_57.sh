#!/bin/bash

echo "start esgyndb of cluster 57"
sleep 10
pdsh -w 10.10.23.57 "sqstart"
