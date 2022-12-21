# Comprehensive set of Bash aliases

* Uses long-form argument names for clarity.
* Uses null item separators where possible, to allow file paths with any characters.
* Verbose output and confirms on overwrites and removal of many files (rm --interactive=once).
* Provides help with `help-more` that also has some useful command templates.
* Useful commands for Arch Linux.
* Creates a script (/etc/custom.bashrc) to be sourced, so it only needs to append a single line to "/etc/bash.bashrc".

## Utilizes

* exa: item listing
* fd: faster alternative to find. However, find is still needed for printf
* fzf: fast fuzzy listing searcher
* imv: interactive item renamer from renameutils
* python3: for date-tagger script, which automatically prepends a date to items
* fdupes: remove duplicate files
* nethogs: throughput traffic by process
* lazygit: tui for git
* ffmpeg: video clipping and re-encoding
* cjxl: image conversion
* paccache: pacman cache tool from pacman-contrib
* perl-rename: rename items with Perl expressions

## Install
Review the bashrc.sh and run bashrc.sh as root.

## Aliases

* rm
* cp
* mv
* chmod
* chown
* mkdir
* sudo
* doas
* execf
* openf
* cdf
* cdfr
* findf
* findfr
* ls
* lsd
* lss
* lsn
* lsm
* lse
* renamef
* renamefr
* prepend-date
* prepend-dater
* vim
* nvimf
* nvimfr
* cpf
* cpfr
* cptof
* cptofr
* mergef
* mergefr
* mvf
* mvfr
* mvtof
* mvtofr
* rmf
* rmfr
* files-dup-remove
* files-largest
* files-last-modified
* files-tar-zst
* files-tar-extract
* cpu-usage
* mem-usage
* systemctl-enable-now
* systemctl-disable-now
* systemctl-list-unit-files
* systemctl-failed
* systemctl-timers
* systemctl-daemon-reload
* systemctl-reset-failed
* systemd-analyze-security
* connections
* throughput
* ports
* nft-list-ruleset
* ipv6-rand-ip
* lg
* history-on
* history-off
* hist
* histf
* pacman-installed-explicit
* pacman-orphans
* pacman-clean-cache
* pacman-installed-foreign
* pacman-rollback
* yay-clean-aur
