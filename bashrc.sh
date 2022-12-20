#!/usr/bin/env bash

set -o errexit -o noclobber -o nounset -o pipefail

mkdir --parents --verbose /usr/local/bin/
rm --force --verbose /usr/local/bin/date-tag
cat << 'EODT' > /usr/local/bin/date-tag
#!/usr/bin/env python3
import sys
import argparse
from pathlib import Path
from datetime import datetime
class DateTagger:
    def __init__(self,date_format):
        self.date_format = date_format
        self.paths = []
        for path in sys.stdin.read().split('\0'):
            path = path.strip()
            if len(path) == 0:
                continue
            self.paths.append(Path(path))
    def rename(self):
        for path in self.paths:
            try:
                stat = path.stat()
                timestamp = stat.st_ctime if stat.st_ctime < stat.st_mtime else stat.st_mtime
                name_new = datetime.fromtimestamp(timestamp).strftime(self.date_format) + path.name
                path_new = path.with_name(name_new)
                if path_new.exists(): #Only Windows raises FileExistsError on rename().
                    raise FileExistsError(f'Destination already exists: {path_new}')
                path.rename(path_new)
            except (FileNotFoundError,ValueError,NotADirectoryError,PermissionError,FileExistsError) as exc:
                print(f'{path}: {exc}',file = sys.stderr)
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Prepends date to file names: Reads paths from STDIN')
    parser.add_argument('-f','--format',dest = 'date_format',type = str,default = '%Y%m%d-',
        help = 'Date format; see Python\'s strftime(). Default: "%%Y%%m%%d-"')
    args = parser.parse_args()
    datet = DateTagger(args.date_format)
    datet.rename()
EODT
echo 'Wrote /usr/local/bin/date-tag'
chmod --verbose +x /usr/local/bin/date-tag

rm --force --verbose /etc/custom.bashrc
###########
## START ##
###########
cat << 'EOBRC' > /etc/custom.bashrc

help-more() {
fzf --tac --no-sort --multi << 'EOHM'
Info: While using fzf in multi mode as you are currently, (de)select items with the tab or shift+tab.
Info: CWD means Current Working Directory.

Common: Execute a file: execf
Common: Open selected files by MIME type: openf
Common: Change to selected directory from home: cdf
Common: Change to selected directory from /: cdfr
Common: Search home: findf
Common: Search /: findfr
Common: Print CWD directories: lsd
Common: Print CWD sorted by size: lss
Common: Print CWD sorted by name: lsn
Common: Print CWD sorted by modified: lsm
Common: Print CWD sorted by extension: lse
Common: Rename selected files from home: renamef
Common: Rename selected files from /: renamefr
Common: Prepend oldest file date (creation or modified) to selected files' names from home: prepend-date  [--format "%Y-%m-%d-"]
Common: Prepend oldest file date (creation or modified) to selected files' names from /: prepend-dater  [--format "%Y-%m-%d-"]
Common: Open selected files from home in nvim: nvimf
Common: Open selected files from / in nvim: nvimfr
Common: Copy selected items from home into CWD: cpf
Common: Copy selected items from / into CWD: cpfr
Common: Copy passed argument items into selected directory from home: cptof  items...
Common: Copy passed argument items into selected directory from /: cptofr  items...
Common: Merge CWD items into folder selected from home: mergef
Common: Merge CWD items into folder selected from /: mergefr
Common: Move selected items from home into CWD. Avoid selecting child items of selected directories: mvf
Common: Move selected items from / into CWD. Avoid selecting child items of selected directories: mvfr
Common: Move passed argument items into selected directory from home: mvtof  items...
Common: Move passed argument items into selected directory from /: mvtofr  items...
Common: Remove selected items from home: rmf
Common: Remove selected items from /: rmfr

Files: Remove duplicate files using fdupes tool: files-dup-remove
Files: Show largest files recursively from CWD: files-largest
Files: Show newest files recursively from CWD: files-last-modified
Files: Compress items into .tar.zst: files-tar-zst  archive_name.tar.zst  items...
Files: Extract tar archive into CWD: files-tar-extract  archive_name.tar.zst

System: Show high CPU usage processes: cpu-usage
System: Show high memory usage processes: mem-usage

Systemd: Enable and start systemd unit: systemctl-enable-now  unitname
Systemd: Disable and stop systemd unit: systemctl-disable-now  unitname
Systemd: List systemd units: systemctl-list-unit-files
Systemd: List failed systemd units: systemctl-failed
Systemd: List systemd timers: systemctl-timers
Systemd: Reload systemd configs: systemctl-daemon-reload
Systemd: Reset failed systemd units: systemctl-reset-failed
Systemd: Analyze systemd unit security: systemd-analyze-security

Network: Show network connections with processes: connections
Network: Show process network usage with nethogs: throughput
Network: Show port state: ports
Network: List active netfilter ruleset: nft-list-ruleset
Network: Print a random IPv6 address for a random network and/or host: ipv6-rand-ip

Git: Show lazygit: lg

History: Instead of turning history off, add a space infront of the command (ignoreboth enables this).
History: Turn on history: history-on
History: Turn off history: history-off
History: Show history: hist
History: Search history and optionally execute selected: histf

Pacman: Suggestion: Use the Yay tool as a user instead because it supports Arch User Repositories.
Pacman: List Pacman explicitly installed packages: pacman-installed-explicit
Pacman: List Pacman orphaned packages: pacman-orphans
Pacman: Clean Pacman package cache by removing all uninstalled package caches and keeping only 2 versions of installed packages: pacman-clean-cache
Pacman: List foreign (AUR) packages: pacman-installed-foreign
Pacman: Rollback selected Pacman packages from cache: pacman-rollback
Yay: Clean AUR cache: yay-clean-aur

Template: Make a clip from a video: ffmpeg -ss 00:01:23 -to 00:04:56 -i input.mkv -codec copy output_clip.mkv
Template: Select videos to compress with AV1: fd --type file --print0 . ~/ | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null --replace ffmpeg -i "{}" -vcodec libaom-av1 -crf 35 "{}.av1.mkv"
Template: Select videos to compress with HEVC: fd --type file --print0 . ~/ | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null --replace ffmpeg -i "{}" -vcodec libx265 -crf 28 "{}.h265.mp4"
Template: Select images to convert to JPEGXL: fd --type file --print0 . ~/ | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null --replace cjxl "{}" "{}.jxl" --distance 1
Template: Ripgrep: rg --ignore-case/-i --hidden/-. --context/-C num-of-context-lines --file/-f "regex pattern" dir/or/file
Template: Rename selected files using perl's expression. Remove --just-print to apply it: fd --print0 . "$HOME" | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null perl-rename --just-print 's/\.jpeg$/\.jpg/'
Template: Generate SSH keypair: ssh-keygen -t ed25519 -a 100 -f ~/.ssh/service_name_here -C "your@email.here"
Template: Create a Rock Ridge iso archive: mkisofs -rational-rock -follow-links -output output_file.iso dir/or/file
Template: Burn iso to DVD/Bluray: growisofs -dvd-compat -speed=4 -Z /dev/device=/path/to/.iso

EOHM
}

##### COMMON #####
alias rm='rm --interactive=once --verbose'
alias cp='cp --interactive --verbose'
alias mv='mv --interactive --verbose'
alias chmod='chmod --changes'
alias chown='chown --changes'
alias mkdir='mkdir --parents --verbose'

#Allow aliases with sudo/doas
alias sudo='sudo '
#alias sudo='doas '
alias doas='doas '

alias execf='"$(fd --type executable --hidden --exclude .git --print0 . / | fzf --read0)"'
alias openf='fd --type file --hidden --exclude .git --print0 . / | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null --replace xdg-open "{}"'
alias cdf='cd "$(fd --type directory --hidden --exclude .git --print0 . "$HOME/" | fzf --read0)"'
alias cdfr='cd "$(fd --type directory --hidden --exclude .git --print0 . / | fzf --read0)"'
alias findf='fd --hidden --exclude .git --print0 . "$HOME/" | fzf --multi --read0'
alias findfr='fd --hidden --exclude .git --print0 . / | fzf --multi --read0'
alias ls='exa'
alias lsd='exa --long --header --git --only-dirs'
alias lss='exa --long --header --git --sort size'
alias lsn='exa --long --header --git --sort name'
alias lsm='exa --long --header --git --sort mod'
alias lse='exa --long --header --git --sort ext'
alias renamef='fd --type file --type symlink --hidden --print0 . "$HOME" | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --replace --null imv "{}"'
alias renamefr='fd --type file --type symlink --hidden --print0 . / | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --replace --null imv "{}"'
alias prepend-date='fd --type file --type symlink --hidden --print0 . "$HOME" | fzf --multi --read0 --print0 | date-tag'
alias prepend-dater='fd --type file --type symlink --hidden --print0 . / | fzf --multi --read0 --print0 | date-tag'
alias vim='nvim'
alias nvimf='fd --type file --type symlink --hidden --exclude .git --print0 . "$HOME/" | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null nvim'
alias nvimfr='fd --type file --type symlink --hidden --exclude .git --print0 . / | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null nvim'
alias cpf='fd --hidden --print0 . "$HOME/" | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --null cp --interactive --recursive --verbose --target-directory .'
alias cpfr='fd --hidden --print0 . / | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --null cp --interactive --recursive --verbose --target-directory .'
alias cptof='fd --type directory --hidden --print0 . "$HOME/" | fzf --read0 --print0 | xargs --no-run-if-empty --open-tty --replace --null cp --interactive --recursive --verbose --target-directory "{}"'
alias cptofr='fd --type directory --hidden --print0 . / | fzf --read0 --print0 | xargs --no-run-if-empty --open-tty --replace --null cp --interactive --recursive --verbose --target-directory "{}"'
alias mergef='fd --type directory --hidden --print0 . "$HOME/" | fzf --read0 --print0 | xargs --no-run-if-empty --null rsync --archive --verbose --itemize-changes --progress .'
alias mergefr='fd --type directory --hidden --print0 . / | fzf --read0 --print0 | xargs --no-run-if-empty --null rsync --archive --verbose --itemize-changes --progress .'
alias mvf='fd --hidden --print0 . "$HOME/" | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --null mv --interactive --verbose --target-directory .'
alias mvfr='fd --hidden --print0 . / | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --null mv --interactive --verbose --target-directory .'
alias mvtof='fd --type directory --hidden --print0 . "$HOME/" | fzf --read0 --print0 | xargs --no-run-if-empty --open-tty --replace --null mv --interactive --verbose --target-directory "{}"'
alias mvtofr='fd --type directory --hidden --print0 . / | fzf --read0 --print0 | xargs --no-run-if-empty --open-tty --replace --null mv --interactive --verbose --target-directory "{}"'
alias rmf='fd --hidden --print0 . "$HOME/" | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --null --verbose rm --interactive=once --recursive --verbose'
alias rmfr='fd --hidden --print0 . / | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --null --verbose rm --interactive=once --recursive --verbose'

alias files-dup-remove='fdupes --size --time --delete .'
alias files-largest='find . -type f -printf "%s %p\0" | sort --numeric-sort --reverse --zero-terminated | fzf --multi --no-sort --read0'
alias files-last-modified='find . -type f -not -path "*/\.git/*" -printf "%T@ %Tc %p\0" | sort --numeric-sort --reverse --zero-terminated | cut --zero-terminated --delimiter " " --fields 2- | fzf --multi --no-sort --read0'
alias files-tar-zst='tar --create --recursion --hard-dereference --dereference --verbose --zstd --file'
alias files-tar-extract='tar --extract --verbose --file'

##### SYSTEM #####
alias cpu-usage='ps aux --sort -pcpu,-pmem | fzf --multi'
alias mem-usage='ps aux --sort -pmem,-pcpu | fzf --multi'

##### SYSTEMD #####
alias systemctl-enable-now='systemctl enable --now'
alias systemctl-disable-now='systemctl disable --now'
alias systemctl-list-unit-files='systemctl list-unit-files'
alias systemctl-failed='systemctl list-units --failed'
alias systemctl-timers='systemctl list-timers --all'
alias systemctl-daemon-reload='systemctl daemon-reload'
alias systemctl-reset-failed='systemctl reset-failed'
alias systemd-analyze-security='systemd-analyze security'

##### NETWORK #####
alias connections='lsof -i -P -n | fzf --multi'
alias throughput='nethogs -a'
alias ports='ss --numeric --listening --processes --tcp --udp | fzf --multi'
alias nft-list-ruleset='nft list ruleset'
alias ipv6-rand-ip='python -c "import secrets,ipaddress;print(str(ipaddress.IPv6Address(secrets.randbits(128)).exploded))"'

##### GIT #####
alias lg='lazygit'

##### HISTORY #####
alias history-on='set -o history'
alias history-off='set +o history'
alias hist='history | sort --key 2 | less +G'
alias histf='eval $(history | sort --reverse --key 2 | fzf --multi --no-sort | cut --delimiter " " --fields 2 | xargs --no-run-if-empty --replace --delimiter "\n" echo "fc -s {};")'
HISTTIMEFORMAT='%F %T '
HISTFILESIZE=-1
HISTSIZE=-1
HISTCONTROL=ignoreboth
HISTIGNORE=''
shopt -s histappend cmdhist
shopt -u lithist
export PROMPT_COMMAND='history -a'

##### PACMAN #####
alias pacman-installed-explicit='pacman --query --explicit | fzf --multi --no-sort'
alias pacman-orphans='pacman --query --deps --quiet --unrequired'
alias pacman-clean-cache='echo "Cleaning uninstalled cache"; paccache --remove --uninstalled --keep 0; echo "Cleaning cache"; paccache --remove --keep 2'
alias pacman-installed-foreign='pacman --query --foreign'
alias pacman-rollback='find /var/cache/pacman/pkg/ -name *.zst -type f -printf "%C@ %Cc %p\0" | sort --numeric-sort --reverse --zero-terminated | cut --zero-terminated --delimiter " " --fields 2- | fzf --multi --no-sort --read0 --print0 | cut --zero-terminated --delimiter " " --fields 8- | xargs --no-run-if-empty --null --open-tty --verbose pacman --upgrade --confirm'
alias yay-clean-aur='yay --sync --clean --aur'

EOBRC
###########
##  END  ##
###########

echo 'Wrote /etc/custom.bashrc'

if ! grep -qxF 'source /etc/custom.bashrc' /etc/bash.bashrc; then
    echo -e '\nsource /etc/custom.bashrc' >> /etc/bash.bashrc
    echo 'Appended /etc/bash.bashrc'
fi
