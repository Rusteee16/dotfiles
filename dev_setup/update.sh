#!/bin/bash
echo "Updating System..."
sudo dnf update -y
echo "Cleaning up..."
sudo dnf clean all
echo "System Updated!"
