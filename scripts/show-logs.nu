#!/usr/bin/env -S nu --stdin
def main [] {
  run-external "docker" "logs" "-f" "caddy"
  | lines
  | each {|line|
    print ($line | from json)
  }
  return
}