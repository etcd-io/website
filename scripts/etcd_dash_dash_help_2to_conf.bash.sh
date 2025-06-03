#!/bin/bash

# This script takes the output of dash dash help of etcd and outputs a CONFIG_FILE_FORMAT=
# for example:  bash ./scripts/etcd_dash_dash_help_2to_conf.bash $R/sources/etcd_dash_dash_help.current > $R/configurations/defaults/etc/conf.d/etcd
# .current is the output of etcd --help - and it transforms that into a .conf style config - nice for systemd environment stuff
# this is our imperfect script, there are many like it, but this one is ours
# I had some confusion on inconsistancies on items that where quoted / etc so sorry
# tested on etcd version etcd Version: 3.5.18 on archlinux - fyi if someone reached out I have this to ansible_jinja2 that i can put somewhere
# @webdawg/neoweb


set -eo pipefail

# Set debug flag
DEBUG=false

# Debug logging function
log_debug() {
  if [ "$DEBUG" = true ]; then
    echo "[DEBUG] $@"
  fi
}

ARGUMENTS=$@

log_debug $ARGUMENTS

# Output configuration
output_config() {
    #echo "[WRITE] $@"
    echo "$@"
}


# Function to output wrapped 80 column text using no external utilities
wrap_text() {
    local input="$@"           # The input string
    local wrapped_line=""      # Variable to hold the wrapped lines
    local current_line=""      # Variable to hold the current line being built

    # Read through each word in the input string
    for word in $input; do
        # Check if the current line is empty
        if [ -z "$current_line" ]; then
            current_line="$word"
        else
            # Check if adding the next word would exceed the line length
            if [ ${#current_line} -gt 80 ]; then
                # If the current line is already greater than 80, move to the next line
                wrapped_line+="# $current_line"$'\n'
                current_line="$word"
            elif [ $(( ${#current_line} + ${#word} + 1 )) -le 80 ]; then
                # Append the word to the current line with a space
                current_line+=" $word"
            else
                # If current line + word exceeds limit, wrap the line
                wrapped_line+="# $current_line"$'\n'
                current_line="$word"
            fi
        fi
    done

    # Print the last line if it's not empty
    if [ -n "$current_line" ]; then
        wrapped_line+="# $current_line"
    fi

    # Output the wrapped lines
    output_config "$wrapped_line"
}


# Function to convert --options to screaming snake case
# https://en.wikipedia.org/wiki/Snake_case
manipulate_string() {
    local input="$1"              # The input string
    local trimmed                  # Variable to hold the modified string

    # Remove the -- prefix
    trimmed="${input#--}"

    # Replace - with _ and convert to uppercase
    trimmed="${trimmed//-/_}"     # Replace all - with _
    trimmed="${trimmed^^}"         # Convert to uppercase

    # Output the result
    echo "$trimmed"
}


output_config "################################################################################"
output_config "############################## Background ######################################"
output_config "################################################################################"
output_config ""
output_config ""
output_config "# Use this file to pull these env into a systemd service.  For instance:"
output_config "# /usr/lib/systemd/system/etcd.service.d/10-EnvironmentFile.conf"
output_config "#"
output_config "# Contents:"
output_config "# [Service]"
output_config "# EnvironmentFile=-/etc/conf.d/etcd"
output_config ""
output_config "# FYI"
output_config "# Environment variables: every flag has a corresponding environment variable"
output_config "# that has the same name but is prefixed with ETCD_ and formatted in all caps"
output_config "# aka screaming snake case. For example, --some-flag would be ETCD_SOME_FLAG."

CONFIG_NOT_STARTED=1
CONFIG_START="Member:"

while IFS= read -r config_line; do
#    log_debug "Text read from file: $config_line"

    # find the start of what we care about past useage
    if [[ $config_line =~ $CONFIG_START ]] && [[ $CONFIG_NOT_STARTED == 1 ]]; then
        log_debug "[FOUND] Member:"
        CONFIG_NOT_STARTED=0
        # at the start of every header is a blank link
        blank_line=1
    fi

    # skip any lines before where we want to start
    if [[ $CONFIG_NOT_STARTED == 1 ]]; then
        continue
    fi

#    echo $config_line
#    continue
    # a blank line was detected last loop
    # this next line should be a header / somethign else / not blank
    if [[ "$blank_line" -eq 1 ]]; then
        blank_line=2
    fi


    # blank lines mean new sections 
    if [[ -z "$config_line" ]]; then
        blank_line=1
#        log_debug "Blank Line Found"
    fi


    # we are after the blank line lets find the configuration output heading
    # be sure and match a heading, and then set that we have a configuration
    # output heading to force an output of a heading later
    if [[ "$blank_line" -eq 2 ]]; then
        if [[ $config_line =~ [a-zA-Z0-9_()\-]+: ]]; then
	        log_debug "found Heading: $config_line"
	        blank_line=0
	        output_heading=1
	    fi
        if [[ ! $config_line =~ [a-zA-Z0-9_()\-]+: ]]; then
	        log_debug "special line found after a blank, no heading: $config_line"
	        blank_line=0
            special_line=1
            output_config "#"
            output_config "####"
            output_config ""
            output_config "####### SPECIAL NOTE - !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! - SPECIAL NOTE #######"
            output_config "#"
	    fi
	fi

    # output an output heading
    if [[ "$output_heading" -eq 1 ]]; then
        # output a suffix for the last definition of each section
        # except for the first one
        if [[ $not_first -eq 1 ]]; then
            output_config "#"
            output_config "####"
            output_config ""
        fi
        # Get the length of the string
        config_line_length=${#config_line}
        # Print the length
        log_debug "whe length of the string is: $config_line_length"
        output_config ""
        output_config ""
        # output a header start
        output_config $(printf '#%.0s' {1..80})
        # get the header middle in the middle
        header_sides=$(( $(( 78 - $config_line_length)) / 2 ))
        log_debug $header_sides
        header_side_right=$header_sides
        # deal with even and odd things
        if (( $config_line_length % 2 != 0 )); then
            ((header_side_right++))
        fi
        output_config $(printf '#%.0s' $(seq 1 "$header_sides")) $config_line $(printf '#%.0s' $(seq 1 "$header_side_right"))
        # we have outputted a heading so lets reset
        output_heading=0
        # output a header end
        output_config $(printf '#%.0s' {1..80})
        output_config ""
        output_config ""
        # nothing else should worry about this config line, it was a heading
        skip_heading=1
        # do not output a directive suffix, we have not started a directive
        # do not output directive description either
        directive_start=0
        # we outputed a header
        not_first=1
	fi

    # now a configuration directive line
    # pull the directive
    # create the directive heading
    # pull the directive description
    # buffer it for configuration output
    # append more items
    # possibly default - but possibly not because default is after directive
    
    # Set what we are looking for
    # Check if the input matches the pattern '--words-like-this'


    # set some variables

    # is not a heading line, and not a blank line, and --config-variable-detection found
    # so output a config --directive and its description
    if [[ ! $skip_heading -eq 1 ]] && [[ ! -z "$config_line" ]] && [[ $config_line =~ ^[[:space:]]*--[a-zA-Z0-9-]+[[:space:]]*\'?.*\'?$ ]]; then
        if [[ $directive_start -eq 1 ]]; then
            # output the suffix for the last directive
            output_config "#"
            output_config "####"
            output_config ""
        fi
        log_debug "words like this found $config_line"
        # set the stage, the first line of a directive kicks off the rest
        directive_line1=1
        directive_content1=$config_line
        log_debug "directive_content1 = $directive_content1"
        output_config "#### $directive_content1"
        output_config "#"
        directive_arguments=$directive_content1
        # Get the item after the last space using parameter expansion
        # if there is no argument for the directive put '' in for nothing
        if [[ ${directive_arguments##* } =~ ^[[:space:]]*--[a-zA-Z0-9-]+[[:space:]]*\'?.*\'?$ ]]; then
            directive_arguments="placeholder ''"
        fi
        output_config "# ETCD_$(manipulate_string $directive_content1)=${directive_arguments##* }"
        output_config "#"
        # start the directive count / reset the count
        directive_count=1
        # start the directive work
        directive_start=1
    fi

        # is not a heading line, and not a blank line, and we are on the next
        # line of the directive description
    if [[ ! $skip_heading -eq 1 ]] && [[ ! -z "$config_line" ]] && [[ $directive_line1 -eq 1 ]] && [[ $directive_count -gt 1 ]]; then
        # skip any --directive lines
        if [[ ! $config_line =~ ^[[:space:]]*--[a-zA-Z0-9-]+[[:space:]]*\'?.*\'?$ ]]; then
        declare directive_content$directive_count="$config_line"
        declared_directive_content="directive_content$directive_count"
        log_debug "$declared_directive_content = ${!declared_directive_content}"
        input_line="${!declared_directive_content}"
        output_line="${input_line#"${input_line%%[![:space:]]*}"}"
        wrap_text $output_line
        ((directive_count++))
        fi
    fi

    if [[ ! -z "$config_line" ]] && [[ $directive_line1 -eq 1 ]] && [[ $directive_count -eq 1 ]]; then
        ((directive_count++))
    fi
    if [[ $special_line -eq 1 ]]; then
	    log_debug "special line found after a blank, no heading: $config_line"
        special_line=0
        output_config "#"
        output_config "####### SPECIAL NOTE - !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! - SPECIAL NOTE #######"
	fi
    skip_heading=0


done < $ARGUMENTS
