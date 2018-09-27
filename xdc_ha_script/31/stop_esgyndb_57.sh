#!/bin/bash

echo "stop esgyndb of cluster 57"
pdsh -w 10.10.23.57 "ckillall"

