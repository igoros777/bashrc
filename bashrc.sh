# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific aliases and functions

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |Bash history format                                                         |
# +---------------------------------------------------------------------------*/
export HISTTIMEFORMAT='| %F %T | '
export HISTSIZE=10000
export HISTCONTROL=erasedups
export HISTCONTROL=ignoredups
shopt -s histappend
shopt -s histverify

# EXAMPLES:
# Show command history from last Tuesday:
# history | egrep "\| $(date -d'last Tuesday' +'%F')"
#
# Show command history from six days ago, 10-11 am:
# history | egrep "\| $(date -d'-6 days' +'%F') (10|11):"

range_hour() {
    TZ="$(date +"%Z")"; s="${1}"; e="${2}"; i=0
    se=$(date -d "${s}" +'%s'); ee=$(date -d "${e}" +'%s')
    sd="$(date -d "${s}")"; ed="$(date -d "${e}")"
    history | grep -E \
    "$(while [ ${se} -lt ${ee} ]; do
    st="$(date -d "${sd} + 1 hour" +'%F %H')"
    [[ ${i} < 1 ]] && echo -en "\| ${st}:*|" && (( i = i + 1 ))
    s="$(date -d "${sd} + 1 hour" +'%b %e %H')"
    sd="$(date -d "${s}")"; se=$(date -d "${s}" +'%s')
    echo -en "\| ${st}:*|"
    done | sed 's/|$//g')"
}
# Example:
# Show command history for March 12, 7 am to March 16, 10 am
# history | range_hour "Mar 12 07" "Mar 16 10"

range_minute() {
    TZ="$(date +"%Z")"; s="${1}"; e="${2}"; i=0
    se=$(date -d "${s}" +'%s'); ee=$(date -d "${e}" +'%s')
    sd="$(date -d "${s}")"; ed="$(date -d "${e}")"
    history | grep -E \
    "$(while [ ${se} -lt ${ee} ]; do
    st="$(date -d "${sd} + 1 minute" +'%F %H:%M')"
    [[ ${i} < 1 ]] && echo -en "\| ${st}:*|" && (( i = i + 1 ))
    s="$(date -d "${sd} + 1 minute" +'%b %e %H:%M')"
    sd="$(date -d "${s}")"; se=$(date -d "${s}" +'%s')
    echo -en "\| ${st}:*|"
    done | sed 's/|$//g')"
}
# Example:
# Show command history for March 18, 7:24 - 8:54 am
# history | range_minute "Mar 18 07:24" "Mar 18 08:54"

# Show the top 25 most frequently typed commands that are less than 20
# characters and don't span multiple lines
fc() {
    egrep -v "\\\(\s)?$" | \
    awk '{ s = ""; for (i = 6; i <= NF; i++) s = s $i " "; print s }' | \
    sed 's/ /:/g' | awk 'length($0) < 20 { a[$0]++ } END { for ( i in a ) \
    print a[i], i | "sort -rn | head -n25"}' | \
    awk '$1 > max{ max=$1} { bar=""; i=s=10*$1/max;while(i-->0)bar=bar"*"; \
    printf "%25s %15d %s %s", $2, $1,bar, "\n"; }' | sed 's/:/ /g'
}
# Example:
# history | fc

# Clear history and log out
alias hidetracks='cat /dev/null > ~/.bash_history && history -c && exit'

#   _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |Liquid Prompt — a useful adaptive prompt for Bash & zsh. Liquid Prompt    |
# |gives you a nicely displayed prompt with useful information when you        |
# |need it. It shows you what you need when you need it. You will notice       |
# |what changes when it changes, saving time and frustration. You can even     |
# |use it with your favorite shell – Bash or zsh.                            |
# |https://github.com/nojhan/liquidprompt                                      |
# |                                                                            |
# |INSTALLATION:                                                               |
# |-------------                                                               |
# |cd ~ && git clone https://github.com/nojhan/liquidprompt.git                |
# +---------------------------------------------------------------------------*/
[[ $- = *i* ]] && source ~/liquidprompt/liquidprompt
#   _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |Bliss dircolors is a theme for the ls command in macOS and Linux, and       |
# |is made for use with dark theme terminals supporting 256 colors. Bliss      |
# |inspires calmness and tranquil, whilst maintaining readability and visual   |
# |distinction between elements. It is specifically designed with colors of    |
# |high value (lightness) and low to intermediate saturation. As a result,     |
# |the palette's tonal properties invoke a softer look that is easier on       |
# |your eyes.                                                                  |
# |https://github.com/joshjon/bliss-dircolors                                  |
# |                                                                            |
# |INSTALLATION:                                                               |
# |-------------                                                               |
# |curl http://url.igoros.com/570 > ~/.bliss.dircolors                         |
# +---------------------------------------------------------------------------*/
[ -e ~/.bliss.dircolors ] && eval $(dircolors -b ~/.bliss.dircolors) || \
eval $(dircolors -b)
#   _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,

# ----------------------------------------------------------------------------
# Correcting common typos
# ----------------------------------------------------------------------------
alias grpe='grep'
alias hsitory='history'
alias sl='ls'
alias cd..='cd ..'

# ----------------------------------------------------------------------------
# Avoiding stupid mistakes
# ----------------------------------------------------------------------------
confirm() {
  c="${@}"
  read -r -p "Are you sure you want to run ${c} in $(hostname -s):$(pwd) ? [y/N]: " response
  response=${response,,}
  if [[ "$response" =~ ^(yes|y)$ ]]
  then
    eval "${c}"
  else
    :
  fi
}
alias reboot='confirm reboot'
alias shutdown='confirm shutdown'

# ----------------------------------------------------------------------------
# This produces output similar to `df -hP` but a little easier to follow
# ----------------------------------------------------------------------------
alias ddf='df -hP | column -t'

# ----------------------------------------------------------------------------
# The `fc` function I mentioned earlier can help you determine which commands
# you type most often. Some of those minght be good candidates for an alias.
# ----------------------------------------------------------------------------
alias g='grep -i'
alias psg='ps -ef | grep '

# ----------------------------------------------------------------------------
# This are probably the two most useful aliases for the `ls` command
# ----------------------------------------------------------------------------
alias l='ls -CF --color=always'
alias ll='ls -alhF --color=always'

# ----------------------------------------------------------------------------
# This alias for the `cd` command will follow symlinks to the target location.
# Many people just alias `cd` to use this syntax.
# ----------------------------------------------------------------------------
alias ccd='cd -P'

# ----------------------------------------------------------------------------
# Just a quick way to skip typing `cd` altogether for the most common
# scenarios
# ----------------------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../../'

# ----------------------------------------------------------------------------
# I don't normally use `nano`, but here is an alias sysadmins would find
# useful. It disabled long line wrapping, converts tabs to spaces, and sets
# the width of a tab to 2 columns instead of the default 8.
# ----------------------------------------------------------------------------
alias nano='nano -wET 2'

# ----------------------------------------------------------------------------
# If you're a fan of `tmux`, which I am, then a few simple aliases will can
# save you a lot of typing over time
# ----------------------------------------------------------------------------

alias tn='tmux new-session -s'                                # tmux new session
alias ta='tmux attach -t'                                     # tmux attach session
alias tl='tmux ls'                                            # list serrions
alias tk='tmux kill-session -s'                               # kill session

# ----------------------------------------------------------------------------
# Generate a strong password
# ----------------------------------------------------------------------------
alias newpass="cat /dev/urandom | tr -dc 'a-zA-Z0-9^#@_:|<>{}=+$%' | fold -w ${1:-32} | head -n 1"

# ----------------------------------------------------------------------------
# Securely delete a file. There are better and faster tools, but this will
# work in a pinch.
# ----------------------------------------------------------------------------
filewipe() {
  p="${1}"
  f="${2}"
  re='^[0-9]+$'
  if [ ! -z "${p}" ] && [[ ${p} =~ ${re} ]] && [ ! -z "${f}" ] && [ -r "${f}" ]
  then
    for i in $(seq 1 ${p})
    do
      echo "Pass ${i} of ${p}"
      dd bs=1K count=$(stat --printf="%s / 1024 * 2 \n" "${f}" | bc) \
      iflag=fullblock if=/dev/urandom of="${f}" 2>/dev/null 1>&2
    done && /bin/rm -f "${f}"
  else
    echo "Can't access file ${f}"
  fi
}
# Example:
# filewipe 3 /var/log/messages.1

# ----------------------------------------------------------------------------
# My favorite `ssh` alias for running commands on remote servers as root
# ----------------------------------------------------------------------------
3s() {
  h="${1}"
  u="${2}"
  c="${3}"
  ssh -qtT -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o ConnectTimeout=3 -o BatchMode=yes -i /home/${u}/.ssh/id.rsa \
  ${u}@$i "sudo su - root -c '\${c}'"
}
# Example:
# 3s host username "command"

export EDITOR=vi
export VISUAL=vi
alias nloader="/usr/bin/nload -i 500000 -o 500000 -u MB \
$(route | grep -m1 ^default | awk '{print $NF}')"

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |fzf is a general-purpose command-line fuzzy finder. It's an interactive     |
# |Unix filter for command-line that can be used with any list; files,         |
# |command history, processes, hostnames, bookmarks, git commits, etc.         |
# |https://github.com/junegunn/fzf                                             |
# |                                                                            |
# |INSTALLATION:                                                               |
# |-------------                                                               |
# |cd ~ && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \ |
# |echo y | ~/.fzf/install                                                     |
# |                                                                            |
# |EXAMPLES:                                                                   |
# |-------------                                                               |
# |fzf --help                                                                  |
# |cat /var/log/messages | fzf                                                 |
# +---------------------------------------------------------------------------*/
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
alias h='history | fzf'
#   _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |autojump is a faster way to navigate your filesystem. It works by           |
# |maintaining a database of the directories you use the most from the         |
# |command line.                                                               |
# |https://github.com/wting/autojump                                           |
# |                                                                            |
# |INSTALLATION:                                                               |
# |-------------                                                               |
# |cd ~ && git clone git://github.com/wting/autojump.git && cd autojump &&     |
# |./install.py                                                                |
# |                                                                            |
# |EXAMPLES:                                                                   |
# |-------------                                                               |
# |autojump --help                                                             |
# |                                                                            |
# |Jump To A Directory That Contains foo:                                      |
# |j foo                                                                       |
# |                                                                            |
# |Jump To A Child Directory:                                                  |
# |jc bar                                                                      |
# +---------------------------------------------------------------------------*/
[[ -s /root/.autojump/etc/profile.d/autojump.sh ]] && \
source /root/.autojump/etc/profile.d/autojump.sh
#   _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,
