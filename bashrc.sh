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

Common: Run a command for each selected item from home in place of {}: xargsf  command {}
Common: Run a command for each selected item from / in place of {}: xargsfr  command {}
Common: Execute a file: execf
Common: Open selected files by MIME type: openf
Common: Change to selected directory from home: cdf
Common: Change to selected directory from /: cdfr
Common: Search home: findf
Common: Search CWD: findfh
Common: Search /: findfr
Common: Print CWD directories: lsd
Common: Print CWD sorted by size: lss
Common: Print CWD sorted by name: lsn
Common: Print CWD sorted by modified: lsm
Common: Print CWD sorted by extension: lse
Common: Print device (space) usage and total for items: dut  items...
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
Common: Remove selected items from CWD: rmfh
Common: Minimal diff: diffm  old/item  new/item
Common: Minimal git diff: gitdiffm  old/item  new/item

Tar: Compress items into .tar.zst: tar-zst  archive_name.tar.zst  items...
Tar: Extract tar archive into CWD: tar-extract  archive_name.tar.zst
Tar: List files in tar archive: tar-list  tar.archive.file

Files: Remove duplicate files using fdupes tool: files-dup-remove
Files: Show largest files recursively from CWD: files-largest
Files: Show newest files recursively from CWD: files-last-modified

System: Show high CPU usage processes: cpu-usage
System: Show high memory usage processes: mem-usage

Systemd: Enable and start systemd unit: systemctl-enable-now  unitname
Systemd: Disable and stop systemd unit: systemctl-disable-now  unitname
Systemd: List systemd units: systemctl-list-unit-files
Systemd: List failed systemd units: systemctl-list-units-failed
Systemd: List systemd timers: systemctl-list-timers
Systemd: Reload systemd configs: systemctl-daemon-reload
Systemd: Reset failed systemd units: systemctl-reset-failed
Systemd: Analyze systemd unit security: systemd-analyze-security

Network: Show network connections with processes: connections
Network: Show process network usage with nethogs: throughput
Network: Show port state: ports
Network: List active netfilter ruleset: nft-list-ruleset
Network: Print a random IPv6 address for a random network and/or host: ipv6-rand-ip

Git: Show lazygit: lg
Git: Garbage collect with pruning and repacking. Don't modify the same repo while this command runs: git-gc-aggressive-prune

History: Instead of turning history off, add a space infront of the command (ignoreboth enables this).
History: Turn on history: history-on
History: Turn off history: history-off
History: Show history: hist
History: Search history and optionally execute selected: histf

Pacman: Search packages: pacman-search  regex-pattern
Pacman: Install packages: pacman-install  packages...
Pacman: Update system: pacman-update
Pacman: Remove packages with parent and child dependencies: pacman-remove  packages...
Pacman: Mark packages as explicitly installed (hidden from pacman-orphans): pacman-database-asexplicit  packages...
Pacman: Mark packages as non-explicitly installed (shown in pacman-orphans): pacman-database-asdeps  packages...
Pacman: Show packages' info: pacman-info  packages...
Pacman: Show installed packages' info: pacman-info-installed  packages...
Pacman: List Pacman explicitly installed packages: pacman-installed-explicit
Pacman: List Pacman orphaned packages: pacman-orphans
Pacman: List foreign (AUR) packages: pacman-installed-foreign
Pacman: List missing package files: pacman-list-missing-files
Pacman: Find package that owns file: pacman-query-owns  path/to/file
Pacman: Rollback selected Pacman packages from cache: pacman-rollback

Pacman/Paccache: Remove all uninstalled package caches and keep only 2 installed versions: paccache-clean

Yay: Search packages: yay-search  regex-pattern
Yay: Install packages: yay-install  packages...
Yay: Update system (or just run "yay"): yay-update
Yay: Remove packages with parent and child dependencies: yay-remove  packages...
Yay: Mark packages as explicitly installed (hidden from yay-orphans): yay-database-asexplicit  packages...
Yay: Mark packages as non-explicitly installed (shown in yay-orphans): yay-database-asdeps  packages...
Yay: Show packages' info: yay-info  packages...
Yay: Show installed packages' info: yay-info-installed  packages...
Yay: List Pacman explicitly installed packages: yay-installed-explicit
Yay: List Pacman orphaned packages: yay-orphans
Yay: List foreign (AUR) packages: yay-installed-foreign
Yay: List missing package files: yay-list-missing-files
Yay: Find package that owns file: yay-query-owns  path/to/file
Yay: Clean AUR cache: yay-clean-aur

Pikaur: Search packages: pikaur-search  regex-pattern
Pikaur: Install packages: pikaur-install  packages...
Pikaur: Update system: pikaur-update
Pikaur: Remove packages with parent and child dependencies: pikaur-remove  packages...
Pikaur: Mark packages as explicitly installed (hidden from pikaur-orphans): pikaur-database-asexplicit  packages...
Pikaur: Mark packages as non-explicitly installed (shown in pikaur-orphans): pikaur-database-asdeps  packages...
Pikaur: Show packages' info: pikaur-info  packages...
Pikaur: Show installed packages' info: pikaur-info-installed  packages...
Pikaur: List Pacman explicitly installed packages: pikaur-installed-explicit
Pikaur: List Pacman orphaned packages: pikaur-orphans
Pikaur: List foreign (AUR) packages: pikaur-installed-foreign
Pikaur: List missing package files: pikaur-list-missing-files
Pikaur: Find package that owns file: pikaur-query-owns  path/to/file
Pikaur: Clean AUR cache: pikaur-clean-aur

Arch: Build and install a PKGBUILD repository with makepkg: makepkg-install

Template: Make a clip from a video: ffmpeg -ss 00:01:23 -to 00:04:56 -i input.mkv -codec copy output_clip.mkv
Template: Select videos to compress with AV1: fd --type file --print0 . ~/ | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null --replace ffmpeg -i {} -vcodec libaom-av1 -crf 35 {}.av1.mkv
Template: Select videos to compress with HEVC: fd --type file --print0 . ~/ | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null --replace ffmpeg -i {} -vcodec libx265 -crf 28 {}.h265.mp4
Template: Select images to convert to JPEGXL: fd --type file --print0 . ~/ | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null --replace cjxl {} {}.jxl --distance 1
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

alias xargsf='fd --hidden --print0 . "$HOME/" | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null --replace'
alias xargsfr='fd --hidden --print0 . / | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null --replace'
alias execf='"$(fd --type executable --hidden --exclude .git --print0 . / | fzf --read0)"'
alias openf='fd --type file --hidden --exclude .git --print0 . / | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null --replace xdg-open {}'
alias cdf='cd "$(fd --type directory --hidden --exclude .git --print0 . "$HOME/" | fzf --read0)"'
alias cdfr='cd "$(fd --type directory --hidden --exclude .git --print0 . / | fzf --read0)"'
alias findf='fd --hidden --exclude .git --print0 . "$HOME/" | fzf --multi --read0'
alias findfh='fd --hidden --exclude .git --print0 . . | fzf --multi --read0'
alias findfr='fd --hidden --exclude .git --print0 . / | fzf --multi --read0'
alias ls='exa'
alias lsd='exa --long --header --git --only-dirs'
alias lss='exa --long --header --git --sort size'
alias lsn='exa --long --header --git --sort name'
alias lsm='exa --long --header --git --sort mod'
alias lse='exa --long --header --git --sort ext'
alias dut='du --human-readable --summarize --total --si'
alias renamef='fd --type file --type symlink --hidden --print0 . "$HOME" | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --replace --null imv {}'
alias renamefr='fd --type file --type symlink --hidden --print0 . / | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --replace --null imv {}'
alias prepend-date='fd --type file --type symlink --hidden --print0 . "$HOME" | fzf --multi --read0 --print0 | date-tag'
alias prepend-dater='fd --type file --type symlink --hidden --print0 . / | fzf --multi --read0 --print0 | date-tag'
alias vim='nvim'
alias nvimf='fd --type file --type symlink --hidden --exclude .git --print0 . "$HOME/" | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null nvim'
alias nvimfr='fd --type file --type symlink --hidden --exclude .git --print0 . / | fzf --multi --read0 --print0 | xargs --no-run-if-empty --null nvim'
alias cpf='fd --hidden --print0 . "$HOME/" | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --null cp --interactive --recursive --verbose --target-directory .'
alias cpfr='fd --hidden --print0 . / | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --null cp --interactive --recursive --verbose --target-directory .'
alias cptof='fd --type directory --hidden --print0 . "$HOME/" | fzf --read0 --print0 | xargs --no-run-if-empty --open-tty --replace --null cp --interactive --recursive --verbose --target-directory {}'
alias cptofr='fd --type directory --hidden --print0 . / | fzf --read0 --print0 | xargs --no-run-if-empty --open-tty --replace --null cp --interactive --recursive --verbose --target-directory {}'
alias mergef='fd --type directory --hidden --print0 . "$HOME/" | fzf --read0 --print0 | xargs --no-run-if-empty --null rsync --archive --verbose --itemize-changes --progress .'
alias mergefr='fd --type directory --hidden --print0 . / | fzf --read0 --print0 | xargs --no-run-if-empty --null rsync --archive --verbose --itemize-changes --progress .'
alias mvf='fd --hidden --print0 . "$HOME/" | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --null mv --interactive --verbose --target-directory .'
alias mvfr='fd --hidden --print0 . / | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --null mv --interactive --verbose --target-directory .'
alias mvtof='fd --type directory --hidden --print0 . "$HOME/" | fzf --read0 --print0 | xargs --no-run-if-empty --open-tty --replace --null mv --interactive --verbose --target-directory {}'
alias mvtofr='fd --type directory --hidden --print0 . / | fzf --read0 --print0 | xargs --no-run-if-empty --open-tty --replace --null mv --interactive --verbose --target-directory {}'
alias rmf='fd --hidden --print0 . "$HOME/" | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --null --verbose rm --interactive=once --recursive --verbose'
alias rmfr='fd --hidden --print0 . / | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --null --verbose rm --interactive=once --recursive --verbose'
alias rmfh='find . -mindepth 1 -maxdepth 1 -print0 | sort --zero-terminated --ignore-case | fzf --multi --read0 --print0 | xargs --no-run-if-empty --open-tty --null --verbose rm --interactive=once --recursive --verbose'
alias diffm='diff --color=always --unified=0 --recursive --new-file --ignore-tab-expansion --ignore-trailing-space --ignore-blank-lines'
alias gitdiffm='git diff --color=always --unified=0 --ignore-cr-at-eol --ignore-space-at-eol --ignore-blank-lines'

alias tar-zst='tar --create --recursion --hard-dereference --dereference --verbose --zstd --file'
alias tar-extract='tar --extract --verbose --file'
alias tar-list='tar --list --file'

alias files-dup-remove='fdupes --size --time --delete .'
alias files-largest='find . -type f -printf "%s %p\0" | sort --numeric-sort --reverse --zero-terminated | fzf --multi --no-sort --read0'
alias files-last-modified='find . -type f -not -path "*/\.git/*" -printf "%T@ %Tc %p\0" | sort --numeric-sort --reverse --zero-terminated | cut --zero-terminated --delimiter " " --fields 2- | fzf --multi --no-sort --read0'

##### SYSTEM #####
alias cpu-usage='ps aux --sort -pcpu,-pmem | fzf --multi'
alias mem-usage='ps aux --sort -pmem,-pcpu | fzf --multi'

##### SYSTEMD #####
alias systemctl-enable-now='systemctl enable --now'
alias systemctl-disable-now='systemctl disable --now'
alias systemctl-list-unit-files='systemctl list-unit-files'
alias systemctl-list-units-failed='systemctl list-units --failed'
alias systemctl-list-timers='systemctl list-timers --all'
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
alias git-gc-aggressive-prune='git gc --aggressive --prune=now'

##### HISTORY #####
alias history-on='set -o history'
alias history-off='set +o history'
alias hist='history | sort --key 2 | less +G'
alias histf='eval $(history | sort --reverse --key 2 | fzf --multi --no-sort | tr --squeeze-repeats " " | cut --delimiter " " --fields 2 | xargs --no-run-if-empty --replace --delimiter "\n" echo "fc -s {};")'
HISTTIMEFORMAT='%F %T '
HISTFILESIZE=-1
HISTSIZE=-1
HISTCONTROL=ignoreboth
HISTIGNORE=''
shopt -s histappend
shopt -u lithist cmdhist
export PROMPT_COMMAND='history -a'

##### PACMAN #####
alias pacman-search='pacman --sync --search'
alias pacman-install='pacman --sync'
alias pacman-update='pacman --sync --refresh --sysupgrade'
alias pacman-remove='pacman --remove --cascade --recursive'
alias pacman-database-asexplicit='pacman --database --asexplicit'
alias pacman-database-asdeps='pacman --database --asdeps'
alias pacman-info='pacman --sync --info --info'
alias pacman-info-installed='pacman --query --info --info'
alias pacman-installed-explicit='pacman --query --explicit | fzf --multi --no-sort'
alias pacman-orphans='pacman --query --deps --quiet --unrequired | fzf --multi --no-sort'
alias pacman-installed-foreign='pacman --query --foreign | fzf --multi --no-sort'
alias pacman-list-missing-files='pacman --query --check | grep --invert-match " 0 missing"'
alias pacman-query-owns='pacman --query --owns'
alias pacman-rollback='find /var/cache/pacman/pkg/ -name "*.zst" -type f -printf "%C@ %Cc %p\0" | sort --numeric-sort --reverse --zero-terminated | cut --zero-terminated --delimiter " " --fields 2- | fzf --multi --no-sort --read0 --print0 | cut --zero-terminated --delimiter " " --fields 8- | xargs --no-run-if-empty --null --open-tty --verbose pacman --upgrade --confirm'

alias paccache-clean='echo "Cleaning uninstalled cache"; paccache --remove --uninstalled --keep 0; echo "Cleaning cache"; paccache --remove --keep 2'

alias yay-search='yay --sync --search'
alias yay-install='yay --sync'
alias yay-update='yay --sync --refresh --sysupgrade'
alias yay-remove='yay --remove --cascade --recursive'
alias yay-database-asexplicit='yay --database --asexplicit'
alias yay-database-asdeps='yay --database --asdeps'
alias yay-info='yay --sync --info --info'
alias yay-info-installed='yay --query --info --info'
alias yay-installed-explicit='yay --query --explicit | fzf --multi --no-sort'
alias yay-orphans='yay --query --deps --quiet --unrequired | fzf --multi --no-sort'
alias yay-installed-foreign='yay --query --foreign | fzf --multi --no-sort'
alias yay-list-missing-files='yay --query --check | grep --invert-match " 0 missing"'
alias yay-query-owns='yay --query --owns'
alias yay-clean-aur='yay --sync --clean --aur'

alias pikaur-search='pikaur --sync --search'
alias pikaur-install='pikaur --sync'
alias pikaur-update='pikaur --sync --refresh --sysupgrade'
alias pikaur-remove='pikaur --remove --cascade --recursive'
alias pikaur-database-asexplicit='pikaur --database --asexplicit'
alias pikaur-database-asdeps='pikaur --database --asdeps'
alias pikaur-info='pikaur --sync --info --info'
alias pikaur-info-installed='pikaur --query --info --info'
alias pikaur-installed-explicit='pikaur --query --explicit | fzf --multi --no-sort'
alias pikaur-orphans='pikaur --query --deps --quiet --unrequired | fzf --multi --no-sort'
alias pikaur-installed-foreign='pikaur --query --foreign | fzf --multi --no-sort'
alias pikaur-list-missing-files='pikaur --query --check | grep --invert-match " 0 missing"'
alias pikaur-query-owns='pikaur --query --owns'
alias pikaur-clean-aur='pikaur --sync --clean --aur'

alias makepkg-install='makepkg --install --syncdeps --rmdeps --clean'

EOBRC
###########
##  END  ##
###########

echo 'Wrote /etc/custom.bashrc'

if ! grep -qxF 'source /etc/custom.bashrc' /etc/bash.bashrc; then
    echo -e '\nsource /etc/custom.bashrc' >> /etc/bash.bashrc
    echo 'Appended /etc/bash.bashrc'
fi

