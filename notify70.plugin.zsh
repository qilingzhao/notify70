#!/usr/bin/env zsh

## setup ##

[[ -o interactive ]] || return #interactive only!
zmodload zsh/datetime || { print "can't load zsh/datetime"; return } # faster than date()
autoload -Uz add-zsh-hook || { print "can't add zsh hook!"; return }
[[ ! -z $notify70_lark_bot_url ]] ||  { print "can't find notify70_lark_bot_url in your env. To create a lark bot,\
    ref: https://open.larksuite.com/document/client-docs/bot-v3/add-custom-bot"; return } #

(( ${+notify_sec_threshold} )) || notify_sec_threshold=3 #default 3 seconds

# TODO: sec_threshold by cmd prefix
# if ! (( $+notify70_cmd_to_threshold )); then
#   declare -A notify70_cmd_to_threshold
#   notify70_cmd_to_threshold[blade] = 60
# fi

# functions

function send_lark() {
  curl -X POST -H "Content-Type: application/json" \
      -d '{"msg_type":"text","content":{"text":"request example"}}' \
      "$notify70_lark_bot_url" > /dev/null 2>&1 & # async send lark message, non-block current terminal. TODO: And no output.
}


## Zsh hooks ##

function preexec_capture() {
  exec_begin_timestamp=$EPOCHSECONDS
  exec_cmd="$1"
}

# TODO: whitelist [vim, ...]
function precmd_notify() {
  {
    local exit_status=$?
    local elapsed=$(( EPOCHSECONDS - exec_begin_timestamp ))
    local is_past_threshold=$(( elapsed >= notify_sec_threshold ))
    if (( exec_begin_timestamp > 0 )) && (( is_past_threshold )); then
      print "[debug] elapsed: $elapsed"
      print "[debug] exit_code: $exit_status"
      print "[debug] exec_cmd: $exec_cmd"
      send_lark
    fi
  } always {
    exec_begin_timestamp=0 #reset it to 0!
  }

}

add-zsh-hook preexec preexec_capture
add-zsh-hook precmd precmd_notify