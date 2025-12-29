#!/usr/bin/env nu

# List docker containers
export def 'nu-docker ps' []: nothing -> table {
  run-external "docker" "ps" "--format" "json"
  | lines
  | each {|entry|
    $entry | from json
    }
}

# Get a container ID by container name
@example 'Get caddy id' { 'caddy' | nu-docker get-container-id }
export def 'nu-docker get-container-id' []: string -> record {
  let pipeline_input = (
    try { $in }
    catch { error make { msg: "Pipeline input required" } }
  )

  (nu-docker ps)
  | where Command =~ $"\"($pipeline_input)"
  | get ID
}

# Gracefully reload caddy configuration
@example 'Reload Caddyfile after changes' { nu-docker reload-caddy }
export def 'nu-docker reload-caddy' [] {
  try {
    run-external "docker" "exec" "-w" "/etc/caddy" ('caddy' | nu-docker get-container-id | to text) "caddy" "reload"
    } catch {
      error make { msg: "Something bad happened." }
      }
}

# Format Caddyfile
@example 'Format Caddyfile' { nu-docker format-caddyfile }
export def 'nu-docker format-caddyfile' [] {
  try {
    run-external "docker" "exec" "-w" "/etc/caddy/" ('caddy' | nu-docker get-container-id | to text) "caddy" "fmt" "--overwrite"
  } catch {
    error make { msg: $"Could not execute (ansi cyan)caddy fmt --overwrite(ansi reset)" }
  }
}
