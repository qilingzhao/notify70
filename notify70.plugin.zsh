#!/usr/bin/env zsh

## setup ##

[[ -o interactive ]] || return #interactive only!
zmodload zsh/datetime || { print "can't load zsh/datetime"; return } # faster than date()
autoload -Uz add-zsh-hook || { print "can't add zsh hook!"; return }

(( ${+bgnotify_threshold} )) || bgnotify_threshold=3 #default 3 seconds

## Zsh hooks ##

function preexec_capture() {
  exec_begin_timestamp=$EPOCHSECONDS
  exec_cmd="$1"
}

function precmd_notify() {
  didexit=$?
  elapsed=$(( EPOCHSECONDS - exec_begin_timestamp ))
  past_threshold=$(( elapsed >= bgnotify_threshold ))
  if (( exec_begin_timestamp > 0 )) && (( past_threshold )); then
    print "elapsed: $elapsed"
    print "didexit: $didexit"
    print "exec_cmd: $exec_cmd"
  fi
  exec_begin_timestamp=0 #reset it to 0!
}

add-zsh-hook preexec preexec_capture
add-zsh-hook precmd precmd_notify