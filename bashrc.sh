# .bashrc
#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |Some of the useful (more or less) aliases and functions for the .bashrc     |
# |file to make your life a little easier and delay the onset of carpal        |
# |tunnel syndrome.                                                            |
# |                                                                            |
# |Review the file carefully before you use it. Don't just copy/paste          |
# |and then yell at me that you can't log in. There are some package           |
# |dependencies. Also, certain command aliases require root access (this       |
# |.bashrc I use for my root accounts), so you may want to wrap them in sudo.  |
# +---------------------------------------------------------------------------*/

# /bin/cp -p ~/.bashrc ~/.bashrc_$(date +'%Y-%m-%d_%H%M%S') && \
# curl -q "https://raw.githubusercontent.com/igoros777/bashrc/main/bashrc.sh" -o ~/.bashrc && \
# chmod 644 ~/.bashrc && source ~/.bashrc


# Adds a timestamp to the prompt, which can be useful when scrolling through
# the console history to find something you did earlier in the session
# export PROMPT_COMMAND="echo -n \$(date +'%b %_d, %H:%M')\ "

#   _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |Liquid Prompt — a useful adaptive prompt for Bash & zsh. Liquid Prompt      |
# |gives you a nicely displayed prompt with useful information when you        |
# |need it. It shows you what you need when you need it. You will notice       |
# |what changes when it changes, saving time and frustration. You can even     |
# |use it with your favorite shell – Bash or zsh.                              |
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
# | Tab completion for Git branch names                                        |
# +---------------------------------------------------------------------------*/
# |                                                                            |
# |INSTALLATION:                                                               |
# |-------------                                                               |
# |curl https://raw.githubusercontent.com/git/git/master/contrib/completion/\  |
# |git-completion.bash -o ~/.git-completion.bash                               |
# +---------------------------------------------------------------------------*/
if [ -f "~/.git-completion.bash" ] && [ -f "~/.gitconfig" ]; then
  source "~/.git-completion.bash"
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific aliases and functions

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |Don't worry about these aliases - these are just for me. Feel free to       |
# |comment them out.                                                           |
# +---------------------------------------------------------------------------*/
post() {
     hashtag post || { sleep 600 && hashtag post || { sleep 600 && hashtag post; } }
     if [ $(which atjobs 2>/dev/null 1>&2; echo $?) -eq 0 ]
     then
       atrm $(atjobs | grep "Are you a robot" | awk '{print $1}') 2>/dev/null 1>&2
     fi
 }

photo() {
  cd "/mnt/nas04/backups/igor/documents/Aeternus/Photography"
}

function gitdo() {
  gdir="/mnt/c/zip/aeternus/GitHub/igoros777"
  if [ ! -z "${1}" ] && [ -d "${gdir}" ] && [ -d "${gdir}/${1}" ]; then
    cd "${gdir}"
    cd "${1}"
  	git add .
  	git status
  	git commit -am "`date +'%Y-%m-%d_%H%M%S'`"
  	git push
  fi
}

privacy_on() {
  # Disable Bash history
  unset HISTFILE
  set +o history
  f=$(mktemp)
  history | tail -2 | awk '{print $1}' | sort -rn > ${f}
  for j in $(cat ${f}); do history -d ${j}; done
  /bin/rm -f ${f}

  # Block outbound port 514 typically used by rsyslog
  tc filter add dev $(route | grep -m1 ^default | awk '{print $NF}') parent 1: pref 1 protocol ip basic match '
  (cmp (u8 at 9 layer network eq 6) or cmp (u8 at 9 layer network eq 17)) and
  cmp(u16 at 2 layer transport eq 514)' action drop
}

privacy_off() {
  # Remove port 514 block
  tc filter del dev $(route | grep -m1 ^default | awk '{print $NF}') parent 1: pref 1 protocol ip basic match '
  (cmp (u8 at 9 layer network eq 6) or cmp (u8 at 9 layer network eq 17)) and
  cmp(u16 at 2 layer transport eq 514)' action drop

  # Re-enable Bash history
  set -o history
}

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# | Git aliases                                                                |
# +---------------------------------------------------------------------------*/
alias gdf="git diff"
alias gitap="git add -p"
alias gitc="git commit -m"
alias gits="git status"
alias gco="git checkout"
alias gul="git pull"
alias gush="git push"
alias gbra="git branch"
alias glog="git log --pretty=format:'%h - %an: %s' --graph"

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

# ----------------------------------------------------------------------------
# Automatically back up files when editing them in VIM
# See more here: https://www.igoroseledko.com/automatic-file-backups-in-vim/
# ----------------------------------------------------------------------------
vish() {
  declare -a a an
  i=0
  for f in "${@}"
  do
    if [ -f "${f}" ]
    then
      fn="$(dirname "${f}")/$(basename -- "${f%.*}")_$(date -d @$(stat -c %Y "${f}") +'%Y-%m-%d_%H%M%S')@$(date +'%Y-%m-%d_%H%M%S')$([[ "${f}" = *.* ]] && echo ".${f##*.}" || echo '')"
      a+=("${f}")
      an+=("${fn}")
      /bin/cp -p "${a[$i]}" "${an[$i]}"
      (( i = i + 1 ))
    fi
  done
  vim "${@}"
  if [ $? -eq 0 ]; then
    for ((i = 0; i < ${#a[@]}; i++))
    do
      if cmp -s "${a[$i]}" "${an[$i]}"
      then
        /bin/rm -f "${an[$i]}" 2>/dev/null
      fi
    done
  fi
}

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
# |curl -L http://url.igoros.com/570 > ~/.bliss.dircolors                         |
# +---------------------------------------------------------------------------*/
[ -e ~/.bliss.dircolors ] && eval $(dircolors -b ~/.bliss.dircolors) || \
eval $(dircolors -b)
#   _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,

# ----------------------------------------------------------------------------
# Find broken links x levels deep
# ----------------------------------------------------------------------------
brokenlinks() {
 d="${1}"
 if [ -z "${d}" ]; then d="$(pwd)"; fi
 l="${2}"
 if [ -z "${l}" ]; then l="1"; fi
 find "${d}" -mindepth 1 -maxdepth ${l} -type l ! -exec test -e {} \; -print
}
# Syntax:
# brokenlinks [/path] [depth]
#
# Example:
# brokenlinks /usr/bin 2

# ----------------------------------------------------------------------------
# Clear pagecache, dentries, inodes, and swap. Note: this may cause problems
# on a busy server and is not recommended on a production system - especially
# a database server.
# ----------------------------------------------------------------------------
memclear() {
  free -h
  echo 3 > /proc/sys/vm/drop_caches && \
  swapoff -a && \
  swapon -a && \
  free -h
}

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
# you type most often. Some of those minght be good candidates for an alias or
# a function.
# ----------------------------------------------------------------------------
alias g='grep -i'

# A handy alias for the `ps -ef | grep something | grep -v grep` thing
# All you need to type is `psg something` and it will translate to
# `ps -ef | grep [s]omething` and this will exclude `grep` itself
psg() {
  ps -ef | grep $(echo "$@" | sed -r 's/(^\s*.)/[\1]/g')
}

# Highlight search terms in files or command output
spot() {
  ack --passthru $@
}

# Example:
# netstat -tuna | spot ESTABLISHED
# netstat -tuna | spot -i established
# spot local /etc/hosts

# ----------------------------------------------------------------------------
# These are probably the two most useful aliases for the `ls` command
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
# Merge lines ending with '\'
# ----------------------------------------------------------------------------
mg() {
  sed  '
: again
/\\$/ {
    N
    s/\\\n//
    t again
}
' "${1}"
}

# ----------------------------------------------------------------------------
# I don't normally use `nano`, but here is an alias sysadmins would find
# useful. It disables long line wrapping, converts tabs to spaces, and sets
# the width of a tab to 2 columns instead of the default 8.
# ----------------------------------------------------------------------------
alias nano='nano -wET 2'

# ----------------------------------------------------------------------------
# Sort output of `du` by size in human-readable format
# ----------------------------------------------------------------------------
alias ddu='du -h --max-depth=1 |sort -rh'

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
alias newpass="cat /dev/urandom | tr -dc 'a-zA-Z0-9^#@_:|<>{}=+$%' | \
fold -w ${1:-32} | head -n 1"

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
# Monitor file changes with an added timestamp
# ----------------------------------------------------------------------------
tailtime() {
  tail -F "${1}" | awk '{now=strftime("%F %T%z\t");sub(/^/, now);print}'
}

# ----------------------------------------------------------------------------
# Find the first and the last occurrences of an error message in the logs
# ----------------------------------------------------------------------------
errorframe() {
  zgrep -h "${3}" $(find "${1}" -mindepth 1 -maxdepth 1 -type f \
  -name "${2}*" | sort -V | sed '1,1{H;1h;d;};$G') | sed -n '1p;$p'
}

# Find the first and last occurrences of "NT_STATUS_END_OF_FILE" error in
# /var/log/messages*
#
# errorframe /var/log messages "NT_STATUS_END_OF_FILE"

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

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |Copying, Syncing, and Archiving Data                                        |
# |The joke about typing a useful tar command without googling has some        |
# |truth to it. The same goes for rsync, dd, and even the good old cp. Here    |
# |are some relevant aliases from my .bashrc:                                  |
# +---------------------------------------------------------------------------*/
# ----------------------------------------------------------------------------
# A function to create a compressed tarball of a directory in the current
# folder, if there's sufficient space
# ----------------------------------------------------------------------------
targz() {
  d="${1}"
  t="$(pwd)"
  if [ -d "${d}" ]
  then
    cd "${d}"
    f="${t}/$(pwd | sed -e 's@^/@@g' -e 's@/@_@g')_$(date +'%Y-%m-%d_%H%M%S').tgz"
    if [ $(stat -f --printf="%a * %s / 1024\n" . | bc) -gt $(du -sk . | awk '{print $1}') ]
    then
      #tar cvfz "${d}.tgz" "${d}"
      tar -cf - . | pv -s $(du -sb . | awk '{print $1}') | \
      gzip > "${f}"
      cd "${t}" && ls -alh "${f}" 2>/dev/null
    else
      echo "Low space in $(pwd)"
    fi
  else
    echo "Can't access ${d}"
  fi
}

# Running this will then produce folder.tgz in your home directory
# cd ~ && targz folder

# ----------------------------------------------------------------------------
# The following function would rsync stuff from the specified source to the
# target with all the common and useful options.
# ----------------------------------------------------------------------------
myrsync() {
  s="${1}"
  t="${2}"
  if [ -d "${s}" ]
  then
    if [ ! -d "${t}" ]
    then
      echo "Creating target ${t}"
      mkdir -p "${t}"
    fi
    echo "Checking the size of ${s}"
    if [ $(du -sk "${s}" | awk '{print $1}') -lt \
    $(df -k "${t}" | sed 's/ \+/ /g' | grep -oP "(?<= )[0-9]{1,}(?= [0-9]{2}%)") ]
    then
      rsync -avuKxh --progress --log-file="$(mktemp)" "${s}" "${t}"
    else
      echo "Low space in ${t}"
    fi
  else
    echo "Can't access ${s}"
  fi
}

# An example of how to run the `myrsync` function:
# myrsync /etc /opt/backups/$(date +'%Y-%m-%d_%H%M%S')

# ----------------------------------------------------------------------------
# Here's a function to find files in the source directory that
# match the specified filename mask and rsync them to another folder:
# ----------------------------------------------------------------------------
find-rsync() {
  s="${1}"
  t="${2}"
  m="${3}"
  if [ -d "${s}" ] && [ ! -z "${m// }" ]
  then
    if [ ! -d "${t}" ]
    then
      echo "Creating target ${t}"
      mkdir -p "${t}"
    fi
    find "${s}" -type f -name "${m}" -print0 | \
    rsync -avKx --relative --files-from=- --from0 / "${t}"
  else
    echo "Can't access ${s} or filename mask is not set"
  fi
}

# An example of how to run the `find-rsync` function to copy all `*.conf` files from /etc to a backup folder:
# find-rsync /etc /opt/backups/$(date +'%Y-%m-%d_%H%M%S') "*\.conf"

# ----------------------------------------------------------------------------
# Find all RAR archives in the current folder and extract only certain
# types of files from them:
# ----------------------------------------------------------------------------
unrar-here2() {
  t="${1}"
  if [ ! -z "${t}" ]
  then
    find . -maxdepth 1 -mindepth 1 -type f -name "*\.rar" -exec \
    unrar e -kb -o+ {} \
    $(for i in $(echo ${t} | sed 's/,/ /g')
    do echo -ne "*.$i "
    done) \;
  fi
}

# Here's how this would work to extract common video filetypes
# unrar-here2 "mkv,mp4,avi"

# ----------------------------------------------------------------------------
# Create a compressed tarball of a local directory and place it on a remote
# server
# ----------------------------------------------------------------------------
tar-ssh() {
  while getopts ":s:t:u:h:" opt
  do
    case ${opt} in
      s  ) s="$(echo ${OPTARG} | sed 's@/$@@g')" ;;
      t  ) t="$(echo ${OPTARG} | sed 's@/$@@g')" ;;
      u  ) u="${OPTARG}" ;;
      h  ) h="${OPTARG}" ;;
      \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
      :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
      *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
  done
  shift $((OPTIND -1))
  if [ ! -z "${s}" ] && [ ! -z "${t}" ] && [ ! -z "${u}" ] && [ ! -z "${h}" ]
  then
    f="${t}/$(hostname -s)_$(echo "${s}" | sed -e 's@^/@@g' -e 's@/@_@g')_$(date +'%Y-%m-%d_%H%M%S').tar.bz2"
    tar jcpf - "${s}" 2>/dev/null | ssh ${u}@${h} "cat > \"${f}\""
    echo "Remote archive created: ${h}:${f}"
    ssh -qtT ${u}@${h} "ls -alh \"${f}\""
  fi
}
# Example:
# This will create an archive of /tmp in ncc1701:/var/tmp/<hostname>_tmp_<timestamp>.tar.bz2
# tar-ssh -s /tmp/ -t /var/tmp -u root -h ncc1701

# ----------------------------------------------------------------------------
# Extract an archive file by running the correct command based on the
# filename extension
# ----------------------------------------------------------------------------
extract () {
  if [ -f "${1}" ] ; then
    case "${1}" in
      *.tar.bz2)  tar xjf    "${1}"    ;;
      *.tar.gz)   tar xzf    "${1}"    ;;
      *.bz2)      bunzip2    "${1}"    ;;
      *.rar)      rar x      "${1}"    ;;
      *.gz)       gunzip     "${1}"    ;;
      *.tar)      tar xf     "${1}"    ;;
      *.tbz2)     tar xjf    "${1}"    ;;
      *.tgz)      tar xzf    "${1}"    ;;
      *.zip)      unzip      "${1}"    ;;
      *.Z)        uncompress "${1}"    ;;
      *)      echo "Unknown file type" ;;
    esac
  else
    echo "Can't access ${1}"
  fi
}

# Use mysqldump to backup a database to a remote server via SSH. This requires
# passwordless SSH and, optionally, passwordless sudo access on the remote
# system
mysqldump-ssh-backup() {
  while getopts ":d:u:p:s:h:t:" opt
  do
    case ${opt} in
      d  ) d="${OPTARG}" ;;
      u  ) u="${OPTARG}" ;;
      p  ) p="${OPTARG}" ;;
      s  ) s="${OPTARG}" ;;
      h  ) h="${OPTARG}" ;;
      t  ) t="${OPTARG}" ;;
      \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
      :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
      *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
  done
  if [ -z "${u}" ]; then read -p "Enter DB username: " u; fi
  if [ -z "${p}" ]; then read -p "Enter DB password for ${u}: " p; fi
  if [ -z "${d}" ]; then mysql -u"${u}" -p"${p}" -e "show databases;"; read -p "Enter database name: " d; fi
  if [ -z "${s}" ]; then read -p "Enter SSH username: " s; fi
  if [ -z "${h}" ]; then read -p "Enter SSH host: " h; fi
  if [ -z "${t}" ]; then read -p "Enter target folder on ${h}: " t; fi
  log="${d}_error_$(date +'%Y-%m-%d_%H%M%S').log"
  f="${d}.$(date +'%Y-%m-%d_%H%M%S').sql"
  mysqldump -q --skip-opt --force --log-error="${log}" \
  -u"${u}" -p"${p}" "${d}" | \
  ssh -qtT -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o ConnectTimeout=3 -o BatchMode=yes \
  "${s}"@"${h}" "sudo su - root -c 'mkdir -p "${t}"; cd "${t}"; cat > "${f}"; gzip "${f}"'" 2>/dev/null
 }

# Syntax:
# mysqldump-ssh-backup [-u db_username ] [-p db_password] [-d db_name] \
# [-s ssh_username] [-h ssh_host] [-t target_folder]
#
# Example:
# mysqldump-ssh-backup -u root -d saltstackdb -s root -h ncc1701 -t /var/tmp

#   _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |System Management Shortcuts                                                 |
# |This is a short list of aliases and functions I have in my .bashrc for      |
# |everyday sysadmin tasks.                                                    |
# +---------------------------------------------------------------------------*/
# Show total allocated local disk space
dfalloc() {
  df -klP -t xfs -t ext2 -t ext3 -t ext4 -t reiserfs | \
  grep -oE ' [0-9]{1,}( +[0-9]{1,})+' | \
  awk '{sum_used += $1} END {printf "%.0f GB\n", sum_used/1024/1024}'
}

# Show total used local disk space
dfused() {
  df -klP -t xfs -t ext2 -t ext3 -t ext4 -t reiserfs | \
  grep -oE ' [0-9]{1,}( +[0-9]{1,})+' | \
  awk '{sum_used += $2} END {printf "%.0f GB\n", sum_used/1024/1024}'
}

# Show total available allocated local disk space
dffree() {
  df -klP -t xfs -t ext2 -t ext3 -t ext4 -t reiserfs | \
  grep -oE ' [0-9]{1,}( +[0-9]{1,})+' | \
  awk '{sum_used += $3} END {printf "%.0f GB\n", sum_used/1024/1024}'
}

# Find largest files
findhuge() {
  f="${1}"
  if [ -z "${f}" ]
  then
    f="$(awk '{print $2}' <(grep "^/dev" /etc/mtab))"
  fi
  l="${2}"; if [ -z "${l}" ]; then l=10; fi
  h=$(echo ${HOSTNAME} | awk -F. '{print $1}')
  d=$(date +'%Y-%m-%d %H:%M:%S')
  for i in ${f}; do
    find "${i}" -xdev -printf "${d},${h},%s,%TY-%Tm-%Td_%TH:%TM,%u:%g,%m,%n,%p\n" | \
    sort -t, -k3rn | head -${l}
  done | (echo "DATE,HOST,KB,MTIME,UID:GID,RWX,HL,PATH" && cat) | column -s',' -t
}
# Example:
# findhuge /opt 10

# Monitor filesystem space and file size changes in real time
fswatch() {
  target_dir="${1}"
  filename_mask="${2}"
  max_file_age="${3}"
  max_count="${4}"
  watch -d -n 5 "df -kP; echo;
  find \"${target_dir}\" -maxdepth 2 -mindepth 1 -type f -name \"${filename_mask}*\" \
  -newermt \"-${max_file_age} seconds\" -exec ls -FlAt {} \; | \
  sort -k9V | column -t | head -${max_count}"
}
# Example:
# fswatch /var/log "*" 10 20

# Find the number of physical CPUs (even if hyper-threading is enabled)
alias corecount="lscpu -p | egrep -v '^#' | sort -u -t, -k 2,4 | wc -l"

# Watch memory usage
alias memwatch='watch vmstat -sSM'

# Search file contents for a string
ff() { local IFS='|'; grep -rinE "$*" . ; }

# A more useful output of `vmstat`
vmstat1() {
  vmstat $@ | ts '[%Y-%m-%d %H:%M:%S]'
}

# Search Google from command-line
google() {
  Q="$@"
  GOOG_URL="http://www.google.com/search?q="
  AGENT="Mozilla/4.0"
  stream=$(curl -A "$AGENT" -skLm 10 "${GOOG_URL}\"${Q/\ /+}\"" | \
  grep -oP '\/url\?q=.+?&amp' | sed 's/\/url?q=//;s/&amp//')
  echo -e "${stream//\%/\x}"
}

# Generate a random alphanumeric file of certain size
filegen() {
  s="${1}"
  if [ -z "${s}" ]; then s="1M"; fi
  fsize="$(echo ${s} | grep -Eo '[0-9]{1,}')"
  sunit="$(echo ${s} | grep -oE '[Aa-Zz]{1,}')"
  (( ssize = fsize * 6 ))
  f="${2}"
  if [ -z "${f}" ] || [ -f "${f}" ]; then f="$(mktemp)"; fi
  head -c "${fsize}${sunit}" <(head -c "${ssize}${sunit}" </dev/urandom | tr -dc A-Za-z0-9) > "${f}"
  ls -alh "${f}"
}
# Example:
# filegen 10M /var/tmp/10M_file.txt

#   _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |Output formatting                                                           |                                              |
# +---------------------------------------------------------------------------*/
# Print a full-width line separator
rule () {
	printf -v _hr "%*s" $(tput cols 2>/dev/null) && echo ${_hr// /${1--}}
}

# Print a horizontal line with a message
rulem ()  {
	if [ $# -eq 0 ]; then
    echo "Usage: rulem MESSAGE [RULE_CHARACTER]"
    return 1
	fi
	printf -v _hr "%*s" $(tput cols 2>/dev/null) && echo -en ${_hr// /${2--}} && echo -e "\r\033[2C$1"
}

# Convert to lowercase
lower() { echo ${@,,}; }

# Right-align text
alias right="printf '%*s' $(tput cols 2>/dev/null)"
# Example:
# right "This is a test"

# A better alternative to the `clear` command
cls(){ printf "\33[2J";}

#   _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,


#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |Handy Network Aliases                                                       |
# |I may not need to use these often, but when I do, I am usually in a hurry   |
# |and have no time for googling.                                              |
# +---------------------------------------------------------------------------*/
# Show local primary IP address
alias localip='ifconfig | sed -rn "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'

# Show public (Internet) IP address
alias publicip='wget http://ipecho.net/plain -O - -q ; echo'

# Scan subnet for active systems
subnetscan() {
  nmap -sn ${1} -oG - | awk '$4=="Status:" && $5=="Up" {print $2}'
}
# Example:
# subnetscan 192.168.122.1/24

# Scan subnet for available IPs
subnetfree() {
  nmap -v -sn -n ${1} -oG - | awk '/Status: Down/{print $2}'
}
# Example:
# subnetfree 192.168.122.1/24

# Quick network port scan of an IP
portscan() {
  nmap -oG -T4 -F ${1} | grep "\bopen\b"
}
# Example:
# portscan 192.168.122.37

# Stealth syn scan, OS and version detection, verbose output
portscan-stealth() {
  nmap -v -sV -O -sS -T5 ${1}
}
# Examples:
# portscan-stealth 192.168.122.137
# portscan-stealth 192.168.122.1/24

# Test port connection
alias portcheck='nc -v -i1 -w1'
# Example:
# portcheck 192.168.122.137 22

# Detect frame drops using `ping`
pingdrops() {
  ping ${1} | \
  grep -oP --line-buffered "(?<=icmp_seq=)[0-9]{1,}(?= )" | \
  awk '$1!=p+1{print p+1"-"$1-1}{p=$1}'
}
# Example:
# pingdrops 192.168.122.137

# Quickly test network throughput between two servers via SSH
bandwidth-test() {
  yes | pv | ssh ${1} "cat > /dev/null"
}
# Example:
# bandwidth-test 192.168.122.137

# Identify local listening ports and services
localports() {
  for i in $(lsof -i -P -n | grep -oP '(?<=\*:)[0-9]{2,}(?= \(LISTEN)' | sort -nu)
  do
    lsof -i :${i} | grep -v COMMAND | awk -v i=$i '{print $1,$3,i}' | sort -u
  done | column -t
}

# Use Curl to check URL connection performance
urltest() {
  URL="${@}"
  if [ ! -z "${URL}" ]; then
    curl -L --write-out "URL,DNS,conn,time,speed,size\n
%{url_effective},%{time_namelookup} (s),%{time_connect} (s),%{time_total} (s),%{speed_download} (bps),%{size_download} (bytes)\n" \
-o/dev/null -s "${URL}" | column -s, -t
  fi
}
# Example:
# urltest https://igoros.com

# List processes associated with a port
portproc() {
  port="${1}"
  if [ ! -z "${port}" ]
  then
    for proto in tcp udp
    do
      for pid in $(fuser ${port}/${proto} 2>/dev/null | awk -F: '{print $NF}')
      do
        ps -eo user,pid,lstart,cmd | awk -v pid=$pid '$2 == pid'
      done
    done
  fi
}

#   _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,

#  _______________________________________________________
# /\                                                      \
# \_|  ____  _ _ _         _____ _     _                  |
#   | / ___|(_) | |_   _  |_   _| |__ (_)_ __   __ _ ___  |
#   | \___ \| | | | | | |   | | | '_ \| | '_ \ / _` / __| |
#   |  ___) | | | | |_| |   | | | | | | | | | | (_| \__ \ |
#   | |____/|_|_|_|\__, |   |_| |_| |_|_|_| |_|\__, |___/ |
#   |              |___/                       |___/      |
#   |   __________________________________________________|_
#    \_/____________________________________________________/

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |Show a random fact                                                          |
# |                                                                            |
# |Installation:                                                               |
# |-------------                                                               |
# |                                                                            |
# |Install optinal `boxes` and `coreutils` packages:                           |
# |(apt|yum|dnf) install boxes coreutils                                       |
# |                                                                            |
# |Install optional `lolcat` package:                                          |
# |pip install lolcat                                                          |
# +---------------------------------------------------------------------------*/


fact() {
  factx() {
    wget randomfunfacts.com -O - 2>/dev/null | \
    grep \<strong\> | sed "s;^.*<i>\(.*\)</i>.*$;\1;"
  }
  if hash fmt boxes lolcat 2>/dev/null; then
    factx | fmt -s -w 48 | boxes -d peek -a l -s 79 | lolcat
  elif hash fmt boxes 2>/dev/null; then
    factx | fmt -s -w 48 | boxes -d peek -a l -s 79
  elif hash fmt 2>/dev/null; then
    factx | fmt -s -w 48
  else
    factx
  fi
}

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |DuckDuckGo Terminal App                                                     |
# |ddgr is a cmdline utility to search DuckDuckGo from the terminal.           |
# |                                                                            |
# |Installation:                                                               |
# |-------------                                                               |
# |                                                                            |
# |cd ~ && git clone https://github.com/jarun/ddgr.git && cd ddgr &&           |
# |make install                                                                |
# +---------------------------------------------------------------------------*/

duck() {
  if hash fmt 2>/dev/null; then
    ddgr --noprompt --num 10 --expand "$@" | fmt -s -w 79
  else
    ddgr --noprompt --num 10 --expand "$@"
  fi
}

# Example:
# duck "search phrase"

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |Source-highlight - convert source code to syntax highlighted document       |
# |                                                                            |
# |Installation:                                                               |
# |-------------                                                               |
# |                                                                            |
# |yum -y install source-highlight                                             |
# +---------------------------------------------------------------------------*/

syntax() {
  source-highlight -f esc256 -i "$@" | less -R
}

# Example:
# syntax some_script.sh

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |TLDR - show online help and examples for Linux shell commands               |
# |                                                                            |
# |Installation:                                                               |
# |-------------                                                               |
# |                                                                            |
# |npm install -g tldr                                                         |
# +---------------------------------------------------------------------------*/

alias help='/usr/bin/tldr'

# Example:
# help rsync

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |Show keyboard showrtcuts for bash productivity                              |
# +---------------------------------------------------------------------------*/

shelp() {
  cat << EOF
#  Navigation
#  ------------------
#  Ctrl + a            Go to the beginning of the line.
#  Ctrl + e            Go to the end of the line.
#  Alt + f             Move the cursor forward one word.
#  Alt + b             Move the cursor back one word.
#  Ctrl + f            Move the cursor forward one character.
#  Ctrl + b            Move the cursor back one character.
#  Ctrl + x, x         Toggle between the current cursor position and the
#                      beginning of the line.

#  Editing
#  ------------------
#  Ctrl + _            Undo (within reason)
#  Ctrl + x, Ctrl + e  Edit the current command in your $EDITOR.
#  Alt + d             Delete the word after the cursor.
#  Alt + Delete        Delete the word before the cursor.
#  Ctrl + d            Delete the character beneath the cursor.
#  Ctrl + h            Delete the character before the cursor (like backspace).
#  Ctrl + k            Cut the line after the cursor to the clipboard.
#  Ctrl + u            Cut the line before the cursor to the clipboard.
#  Ctrl + d            Cut the word after the cursor to the clipboard.
#  Ctrl + w            Cut the word before the cursor to the clipboard.
#  Ctrl + y            Paste the last item to be cut.

#  Processes
#  ------------------
#  Ctrl + l            Clear the entire screen (like the clear command).
#  Ctrl + z            Place the currently running process into a suspended
#                      background process (and then use fg to restore it).
#  Ctrl + c            Kill the currently running process by sending the SIGINT
#                      signal.
#  Ctrl + d            Exit the current shell.
#  Enter, ~, .         Exit a stalled SSH session.

#  History
#  ------------------
#  Ctrl + r            Bring up the history search.
#  Ctrl + g            Exit the history search.
#  Ctrl + p            See the previous command in the history.
#  Ctrl + n            See the next command in the history.
EOF
}

# The command below will run the `shelp` alias when you press the F12 key. In
# my case, pressing the F12 was showing "4~" in the terminal window and so
# that's what I used. Your terminal emulator may be different, so just hit F12,
# see what you get, and insert that string in place of my "4~".

tty=$(tty); [[ $tty != "not a tty" ]] && bind '"4~":"shelp\n"'

#/*       _\|/_
#         (o o)
# +----oOO-{_}-OOo-------------------------------------------------------------+
# |asciinema is a popular tool for recording your terminal window sessions so  |
# |that you can share them with others. asciinema is fairly easy to install on |
# |modern Linux versions. If you have an older system, I have some notes that  |
# |may be of help: https://www.igoroseledko.com/asciinema-notes/               |
# |The function below is convenient as I can never remember the proper syntax  |
# |to use with asciinema.                                                      |
# +---------------------------------------------------------------------------*/

record() {
  asciinema rec --stdin --overwrite -t \
  "$(hostname | awk -F. '{print $1}')_$(date +'%Y-%m-%d_%H%M%S')" -i 3 -y -q
}

#   _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,
