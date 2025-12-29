#!/usr/bin/env -S nu

def main [] {
  ^docker logs -n 10 -f caddy
  | lines
  | each {|line|
      try {
        # parse JSON line and print as a Nushell record/table
        $line
        | from json
        | print
      } catch {
        # if it’s not JSON, either:
        #  - comment this out to ignore it,
        #  - or print raw for debugging:
        # $line | print
      }

      # Make sure the closure returns a neutral value,
      # so `each` doesn’t build a huge list for the REPL to display.
      null
    }
}
