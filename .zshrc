# ~/.zshrc — interactive zsh configuration.
# Self-contained: everything machine-local lives here, no ~/dotfiles dependency.

##########################################
# PATH
##########################################
export PATH="$HOME/.local/bin:$PATH"

##########################################
# Environment
##########################################
export VISUAL=vim
export EDITOR="$VISUAL"

##########################################
# Completion
##########################################
# Homebrew's zsh completions on $fpath. Prefix is hardcoded to avoid forking
# `brew` (slow) on every shell startup.
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
# Reuse the cached completion dump for fast startup; do the full rebuild +
# security audit only once every 24h (or when the dump is missing).
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh-24) ]]; then
  compinit -C
else
  compinit
fi

##########################################
# Version manager (Node, Ruby, Python via mise)
##########################################
# Replaces nvm/rbenv/pyenv. Honors .nvmrc/.ruby-version/.python-version.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi
# Configure mise
# mise settings set idiomatic_version_file_enable_tools "node,python,ruby"

##########################################
# Aliases
##########################################
# Colorized BSD ls (macOS). CLICOLOR enables color without a flag; LSCOLORS
# is the scheme BSD ls reads (GNU's LS_COLORS does not apply here).
export CLICOLOR=1
export LSCOLORS='ExGxBxDxCxEgEdxbxgxcxd'
alias cls='clear'
alias ll='ls -lh'

# macOS: show/hide hidden system files in Finder
alias showsysfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hidesysfiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

# VSCode key repeat (https://stackoverflow.com/questions/39972335/how-do-i-press-and-hold-a-key-and-have-it-repeat-in-vscode/44010683#44010683)
# defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
#
# Add ssh agent to keychain
#  ssh-add --apple-use-keychain ~/.ssh/id_ed25519 ~/.ssh/id_rsa


##########################################
# Functions
##########################################
# Stop all running Docker containers
function stop_docker() {
  containers=$(docker ps -qa)
  docker stop $containers
}

# Lines added/removed by an author across all of git history
function git_stats_by_author() {
  git log --author="$1" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }' -
}

# Extract jpgs from mp4s
# https://trac.ffmpeg.org/wiki/Create%20a%20thumbnail%20image%20every%20X%20seconds%20of%20the%20video
# function process_MP4s() {
#   for f in *.MP4
#   do
#       ffmpeg -i $f -f image2 -r 1 -q 1 $f-%08d.jpg
#
#       for jpg in $f*.jpg
#       do
#           SetFile -d "$(GetFileInfo -d $f)" $jpg
#           SetFile -m "$(GetFileInfo -m $f)" $jpg
#       done
#   done
# }

##########################################
# Prompt
##########################################
# user@host:dir (git-branch). vcs_info computes the branch without forking git.
autoload -Uz vcs_info
setopt PROMPT_SUBST
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b) '
PROMPT='%F{blue}%n@%m:%1~ ${vcs_info_msg_0_}%#%f '
