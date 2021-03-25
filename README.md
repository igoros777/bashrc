# Productivity Shortcuts for .bashrc

Some of the useful (more or less) aliases and functions for the .bashrc file to make your life a little easier and delay the onset of carpal tunnel syndrome.

Things to remove from .bashrc

Few things annoy me more than these three default command aliases. Removing them is one of the first things I do after installing a new OS:

~~~bash
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
~~~

Command History

Adding a timestamp to your shell command history is a must. This will help you figure out not just what stupid mistake you made, but also when you made it.

export HISTTIMEFORMAT='| %F %T | '
export HISTSIZE=30000
export HISTCONTROL=ignoredups
shopt -s histappend
shopt -s histverify

# ----------------------------------------------------------------------------
# Sample:
# ----------------------------------------------------------------------------
history | tail -1
30042  | 2021-03-18 07:50:44 | ls -als

# ----------------------------------------------------------------------------
# Clear history and log out
# ----------------------------------------------------------------------------
alias hidetracks='cat /dev/null > ~/.bash_history && history -c && exit'

# ----------------------------------------------------------------------------
# Show command history from last Tuesday:
# ----------------------------------------------------------------------------
history | egrep "\| $(date -d'last Tuesday' +'%F')"

# ----------------------------------------------------------------------------
# Show command history from six days ago, 10-11 am:
# ----------------------------------------------------------------------------
history | egrep "\| $(date -d'-6 days' +'%F') (10|11):"

# ----------------------------------------------------------------------------
# Show command history for March 12, 7 am to March 16, 10 am:
# ----------------------------------------------------------------------------
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
history | range_hour "Mar 12 07" "Mar 16 10"

# ----------------------------------------------------------------------------
# Show command history for March 18, 7:24 - 8:54 am:
# ----------------------------------------------------------------------------
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
history | range_minute "Mar 18 07:24" "Mar 18 08:54"

# ----------------------------------------------------------------------------
# Add this function to your .bashrc to show the top 25 most frequently typed
# commands that are less than 20 characters and don't span multiple lines:
# ----------------------------------------------------------------------------
fc() {
    egrep -v "\\\(\s)?$" | awk '{ s = ""; for (i = 6; i <= NF; i++) s = s $i " "; print s }' | sed 's/ /:/g' | awk 'length($0) < 20 { a[$0]++ } END { for ( i in a ) print a[i], i | "sort -rn | head -n25"}' | awk '$1 > max{ max=$1} { bar=""; i=s=10*$1/max;while(i-->0)bar=bar"*"; printf "%25s %15d %s %s", $2, $1,bar, "\n"; }' | sed 's/:/ /g'
}
history | fc

# ----------------------------------------------------------------------------
# Combine the previous `fc` function with the `range_hour` function to get a
# list of most frequently typed commands in the past 3 hours:
# ----------------------------------------------------------------------------
history | range_hour "$(date -d'-3 hours' +'%b %e %H')" "$(date +'%b %e %H')" | fc


The `fzf` command-line fuzzy search utility is tremendously useful for search your shell history for commands the syntax of which you can't quite recall. You can find the simple installation instructions here and then add this handy alias to your `.bashrc`:

alias h='history | fzf'

Common Command Aliases

Some of the other handy command aliases that I use frequently:

# ----------------------------------------------------------------------------
# The `fc` function I mentioned earlier can help you determine which commands
# you type most often. Some of those minght be good candidates for an alias.
# ----------------------------------------------------------------------------
alias g="grep -i"
alias psg='ps -ef | grep '

# ----------------------------------------------------------------------------
# This produces output similar to `df -hP` but a little easier to follow
# ----------------------------------------------------------------------------
alias ddf='df -hP | column -t'

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
filewipe 3 /var/log/messages.1

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
3s ncc1701 root "df -hlP"

System Management Shortcuts

This is a short list of aliases and functions I have in my `.bashrc` for everyday sysadmin tasks.

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
findhuge /opt 10

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
fswatch /var/log "*" 10 20

# Find the number of physical CPUs (even if hyper-threading is enabled)
alias corecount="lscpu -p | egrep -v '^#' | sort -u -t, -k 2,4 | wc -l"

Correcting Typos

There are certain commands I mistype on a regular basis. While `.bashrc` is not the best way of addressing this issue ( for this I would recommend using AutoHotkey on Windows or AutoKey on Linux), but to a limited extent it's not a terrible idea:

alias grpe='grep'
alias hsitory='history'
alias sl='ls'
alias cd..='cd ..'

Copying, Syncing, and Archiving Data

The joke about typing a useful `tar ` command without googling has some truth to it. The same goes for `rsync`, `dd`, and even the good old `cp`. Here are some relevant aliases from my `.bashrc`:

# ----------------------------------------------------------------------------
# A function to create a compressed tarball of a directory in the current
# folder, if there's sufficient space
# ----------------------------------------------------------------------------
targz() {
  d="${1}"
  if [ -d "${d}" ]
  then
    if [ $(stat -f --printf="%a * %s / 1024\n" . | bc) -gt $(du -sk ./"${d}" | awk '{print $1}') ]
    then
      tar cvfz "${d}.tgz" "${d}"
    else
      echo "Low space in $(pwd)"
    fi
  else
    echo "Can't access ${d}"
  fi
}

# Running this will then produce folder.tgz in your home directory
cd ~ && targz folder

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
myrsync /etc /opt/backups/$(date +'%Y-%m-%d_%H%M%S')

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
find-rsync /etc /opt/backups/$(date +'%Y-%m-%d_%H%M%S') "*\.conf"

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
unrar-here "mkv,mp4,avi"

# ----------------------------------------------------------------------------
# Extract an archive file by running the correct command base on the
# filename extension
# ----------------------------------------------------------------------------
extract () {
  if [ -f "${1}" ] ; then
    case $1 in
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
Handy Network Aliases

I may not need to use these often, but when I do, I am usually in a hurry and have no time for googling.

# Show local primary IP address
alias localip='ifconfig | sed -rn "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'

# Show public (Internet) IP address
alias publicip='wget http://ipecho.net/plain -O - -q ; echo'

# Scan subnet for active systems
subnetscan() {
  nmap -sn ${1} -oG - | awk '$4=="Status:" && $5=="Up" {print $2}'
}
# Example:
subnetscan 192.168.122.1/24

# Scan subnet for available IPs
subnetfree() {
  nmap -v -sn -n ${1} -oG - | awk '/Status: Down/{print $2}'
}
# Example:
subnetfree 192.168.122.1/24

# Quick network port scan of an IP
portscan() {
  nmap -oG -T4 -F ${1} | grep "\bopen\b"
}
# Example:
portscan 192.168.122.37

# Stealth syn scan, OS and version detection, verbose output
portscan-stealth() {
  nmap -v -sV -O -sS -T5 ${1}
}
# Examples:
portscan-stealth 192.168.122.137
portscan-stealth 192.168.122.1/24

# Test port connection
alias portcheck='nc -v -i1 -w1'
# Example:
portcheck 192.168.122.137 22

# Detect frame drops using `ping`
pingdrops() {
  ping ${1} | \
  grep -oP --line-buffered "(?<=icmp_seq=)[0-9]{1,}(?= )" | \ awk '$1!=p+1{print p+1"-"$1-1}{p=$1}' } # Example: pingdrops 192.168.122.137 # Quickly test network throughput between two servers via SSH bandwidth-test() { yes | pv | ssh ${1} "cat > /dev/null"
}
# Example:
bandwidth-test 192.168.122.137

# Identify local listening ports and services
localports() {
  for i in $(lsof -i -P -n | grep -oP '(?<=\*:)[0-9]{2,}(?= \(LISTEN)' | sort -nu)
  do
    lsof -i :${i} | grep -v COMMAND | awk -v i=$i '{print $1,$3,i}' | sort -u
  done | column -t
}
