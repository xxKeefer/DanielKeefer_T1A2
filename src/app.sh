
#!/bin/bash

clear

echo "Launching Overwatch Event Planner"

echo "Mining (installing) required gems..."

bundle install

echo "Polishing (updating) required gems..."

gem update --system

echo "Good to go! Launching now..."

ruby main.rb
