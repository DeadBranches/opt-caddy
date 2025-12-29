#!/usr/bin/env -S nu

def main [] {
  ^docker logs -f caddy
  | lines
  | each {|line|
      try {
        # parse JSON log lines into structured records
        $line | from json
      } catch {
        # if it's not JSON, just pass the raw line through
        $line
      }
    }
}
