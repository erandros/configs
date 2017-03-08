alias e.='explorer .'

alias vipersrc='cd /d/git/viper/src'
alias vipergen='cd /d/git/viper/generator-viper'
alias viper='cd /d/git/viper'

alias erandros='cd /d/go/src/github.com/erandros'
alias sublime='/c/Program\ Files/Sublime\ Text\ 3/sublime_text.exe $@'
alias atomp='cd ~/.atom/'
alias t='todo.sh $@'

alias ga='git add $@'
alias ga.='git add . $@'
alias gap='git add -p $@'
alias gb='git branch $@'
alias gbm='git branch --merged $@'
alias gbnm='git branch --no-merged $@'
alias gc='git commit $@'
alias gca='git commit --amend --no-edit $@'
alias gcam='git commit --amend -m $@'
alias gce='git commit --allow-empty -m $@'
alias gcm='git commit -m $@'
alias gch='git checkout $@'
alias gd='git diff $@'
alias gdc='git diff --cached $@'
alias gdmb='git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d'
alias gfo='git fetch origin $@'
alias gfd='git fetch demand $@'
alias gfg='git fetch guido $@'
alias gl='git log $@'
alias glb='git log --graph --abbrev-commit --decorate --format=format:"%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)" --all'
alias gm='git merge $@'
alias gpo='git push origin $@'
alias gpg='git push guido $@'
alias grb='git rebase -i $@'
alias grs='git reset $@'
alias grh='git reset --hard $@'
alias gs='git status $@'

# Automatically add completion for all aliases to commands having completion functions
# https://superuser.com/revisions/437508/21
function alias_completion {
    local namespace="alias_completion"

    # parse function based completion definitions, where capture group 2 => function and 3 => trigger
    local compl_regex='complete( +[^ ]+)* -F ([^ ]+) ("[^"]+"|[^ ]+)'
    # parse alias definitions, where capture group 1 => trigger, 2 => command, 3 => command arguments
    local alias_regex="alias ([^=]+)='(\"[^\"]+\"|[^ ]+)(( +[^ ]+)*)'"

    # create array of function completion triggers, keeping multi-word triggers together
    eval "local completions=($(complete -p | sed -Ene "/$compl_regex/s//'\3'/p"))"
    (( ${#completions[@]} == 0 )) && return 0

    # create temporary file for wrapper functions and completions
    rm -f "/tmp/${namespace}-*.tmp" # preliminary cleanup
    local tmp_file; tmp_file="$(mktemp "/tmp/${namespace}-${RANDOM}XXX.tmp")" || return 1

    local completion_loader; completion_loader="$(complete -p -D 2>/dev/null | sed -Ene 's/.* -F ([^ ]*).*/\1/p')"

    # read in "<alias> '<aliased command>' '<command args>'" lines from defined aliases
    local line; while read line; do
        eval "local alias_tokens; alias_tokens=($line)" 2>/dev/null || continue # some alias arg patterns cause an eval parse error
        local alias_name="${alias_tokens[0]}" alias_cmd="${alias_tokens[1]}" alias_args="${alias_tokens[2]# }"

        # skip aliases to pipes, boolan control structures and other command lists
        # (leveraging that eval errs out if $alias_args contains unquoted shell metacharacters)
        eval "local alias_arg_words; alias_arg_words=($alias_args)" 2>/dev/null || continue
        # avoid expanding wildcards
        read -a alias_arg_words <<< "$alias_args"

        # skip alias if there is no completion function triggered by the aliased command
        if [[ ! " ${completions[*]} " =~ " $alias_cmd " ]]; then
            if [[ -n "$completion_loader" ]]; then
                # force loading of completions for the aliased command
                eval "$completion_loader $alias_cmd"
                # 124 means completion loader was successful
                [[ $? -eq 124 ]] || continue
                completions+=($alias_cmd)
            else
                continue
            fi
        fi
        local new_completion="$(complete -p "$alias_cmd")"

        # create a wrapper inserting the alias arguments if any
        if [[ -n $alias_args ]]; then
            local compl_func="${new_completion/#* -F /}"; compl_func="${compl_func%% *}"
            # avoid recursive call loops by ignoring our own functions
            if [[ "${compl_func#_$namespace::}" == $compl_func ]]; then
                local compl_wrapper="_${namespace}::${alias_name}"
                    echo "function $compl_wrapper {
                        (( COMP_CWORD += ${#alias_arg_words[@]} ))
                        COMP_WORDS=($alias_cmd $alias_args \${COMP_WORDS[@]:1})
                        (( COMP_POINT -= \${#COMP_LINE} ))
                        COMP_LINE=\${COMP_LINE/$alias_name/$alias_cmd $alias_args}
                        (( COMP_POINT += \${#COMP_LINE} ))
                        $compl_func
                    }" >> "$tmp_file"
                    new_completion="${new_completion/ -F $compl_func / -F $compl_wrapper }"
            fi
        fi

        # replace completion trigger by alias
        new_completion="${new_completion% *} $alias_name"
        echo "$new_completion" >> "$tmp_file"
    done < <(alias -p | sed -Ene "s/$alias_regex/\1 '\2' '\3'/p")
    source "$tmp_file" && rm -f "$tmp_file"
}; alias_completion
animation() {
S="\033[s"
U="\033[u"

POS="\033[1000D\033[2C"
while [ : ]
do
    eval echo -ne '${S}${POS}\>\ \ ${U}'
    sleep 0.3 &
    eval echo -ne '${S}${POS}\ \>\ ${U}'
    sleep 0.3 &
    eval echo -ne '${S}${POS}\ \ \>${U}'
    sleep 0.3 &
done
}
PS1='[     ] : [ \u @ \h ] > '
PS1='\[\033]0;$TITLEPREFIX:${PWD//[^[:ascii:]]/?}\007\]\n\[\033[32m\]\u@\h \[\033[35m\]Te amo, Romi \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n$ '
