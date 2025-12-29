def main [] {
# Config
# The directories to archive
let directories = [config data build]

# paths
let backup_dir = ($env.HOME | path join 'backups')
let data_dir   = (pwd | path join 'data')
let error_file = ($backup_dir | path join 'error.log')

# names
let ts   = (date now | format date '%Y-%m-%dT%H%M%S')
let proj = (pwd | path basename)
let final = ($backup_dir | path join $"($proj)-($ts).tar.gz")
let tmp   = ($final + '.partial')

# Setup
mkdir $backup_dir

# Optional downtime for consistency (usually only needed for DBs)
# ^docker compose stop

# Create archive atomically, then move into place

  print $"(ansi cyan)[Info](ansi reset) Creating backup archive..."
  run-external sudo tar ...[
  '-C'
  (pwd)
  '-czf'
  $tmp
  '--numeric-owner'
  '--one-file-system'
  '--exclude-vcs'
  ...($directories | each {|directory| if ($directory | path exists) { $directory } else { return }}) 
  ]

  ^mv $tmp $final
  print $"(ansi cyan)[Info](ansi reset) Backup archive created."

  # Optional: checksum log
  if (which sha256sum | is-not-empty) {
    ^sha256sum $final | save --append ($backup_dir | path join 'checksums.txt')
  }

  # Commit/push CONFIG changes only; your archive lives outside the repo
    print $"(ansi cyan)[Info](ansi reset) Commiting changes to remote repository..."

    try { run-external ...[
      git sudo add '.' | complete | print $"(char tab)($in.stdout)"
      ]
    } catch { error "Could not add files." }

    try { run-external ...[
      git commit '-m' $"Automatic update for ($ts)"
    ] 
    | complete 
    | lines 
    | print (
        $in.stdout 
        | str join $"(char newline)(char tab)"
      )
    } catch { error "Could not create local commit." }

    try { run-external git 'push' 
    | complete 
    | print ($in.stdout | str join $"(char newline)(char tab)")
    } catch { error "Could not push to remote." }

    print $"(ansi cyan)[Info](ansi reset) Configs commited to remote."

}

def error [message] { $"(ansi red)[Error](ansi reset) $message" }
