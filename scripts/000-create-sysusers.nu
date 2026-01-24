#!/usr/bin/env nu --stdin

def main [--debug --dry_run] {

  use std/log
  if ($debug) { log set-level 10 }

  const script_path = (path self)
  const unit_filename = {
    prefix: "400-svc-"
    suffix: ".conf"
  }


  let header = $"# generated from ($script_path)"

  let compose_file = open ($script_path | path split | first 3 | path join docker-compose.yaml)

  let name = $compose_file | get name
  let service_user = $compose_file | get x-account | get account_name
  let id = $compose_file | get x-account | get id

  let unit_filepath = ('/opt' | path join $name system usr lib sysusers.d ($unit_filename.prefix + $name +  $unit_filename.suffix))

  let group_string = [
    $"g ($service_user)"
    $id
    "-"
  ] | str join (char tab)

  let user_string = [
    $"u ($service_user)"
    $id
    "-"
    ('/opt' | path join $name)
    "/usr/sbin/nologin"
  ] | str join (char tab)

  let file_content = [
    $header
    (char space)
    $group_string
    $user_string
  ] | str join (char newline)


  if (not $dry_run) { $file_content | save --force $unit_filepath }

  log debug $"Saving to: ($unit_filepath)(char newline)($file_content)"
  log info $"Unit file saved to ($unit_filepath)"
}
