#!/usr/bin/env bash

dt=$(date +"%m-%d-%Y-%H:%M")

/usr/local/bin/pushover --title "TF-Deploy: ${app_name}" "Terraform deployment for ${app_name} has completed at $\{dt\}. Notes: ${notes}"