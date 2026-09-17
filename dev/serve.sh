#!/bin/bash

nix build .#website

nix run .#srv -- --directory ./result --port 8080
