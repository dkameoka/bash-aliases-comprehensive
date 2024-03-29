# Comprehensive set of Bash aliases

* Uses long-form argument names for clarity.
* Uses null item separators where possible, to allow file paths with any characters.
* Verbose output and confirms on overwrites and removal of many files (rm --interactive=once).
* Provides help with `help-more` that also has some useful command templates.
* Useful commands for Arch Linux.
* Creates a script (/etc/custom.bashrc) to be sourced, so it only needs to append a single line to "/etc/bash.bashrc".

## Utilizes

* eza: item listing
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
* suc
* xargsf
* xargsfr
* execf
* openf
* cdf
* cdfr
* findf
* findfh
* findfr
* ls
* lsd
* lss
* lsn
* lsm
* lse
* dut
* renamef
* renamefr
* prepend-date
* prepend-dater
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
* rmfh
* diffm
* gitdiffm
* dot-glob
* dot-glob-off
* tar-zst
* tar-extract
* tar-list
* files-dup-remove
* files-largest
* files-last-modified
* cpu-usage
* mem-usage
* systemctl-enable-now
* systemctl-disable-now
* systemctl-list-unit-files
* systemctl-list-units-failed
* systemctl-list-timers
* systemctl-daemon-reload
* systemctl-reset-failed
* systemd-analyze-security
* connections
* throughput
* ports
* nft-list-ruleset
* ipv6-rand-ip
* lg
* git-gc-aggressive-prune
* history-on
* history-off
* hist
* histf
* pacman-search
* pacman-install
* pacman-update
* pacman-remove
* pacman-database-asexplicit
* pacman-database-asdeps
* pacman-info
* pacman-info-installed
* pacman-installed-explicit
* pacman-orphans
* pacman-installed-foreign
* pacman-list-missing-files
* pacman-query-owns
* pacman-rollback
* paccache-clean
* pikaur-search
* pikaur-install
* pikaur-update
* pikaur-remove
* pikaur-database-asexplicit
* pikaur-database-asdeps
* pikaur-info
* pikaur-info-installed
* pikaur-installed-explicit
* pikaur-orphans
* pikaur-installed-foreign
* pikaur-list-missing-files
* pikaur-query-owns
* pikaur-clean-aur
* makepkg-install
