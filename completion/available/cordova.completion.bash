platforms() {
    get_cordova && COMPREPLY=( $(compgen -W "$(${CORDOVA_BIN} platform ls  | tr -d "[]',")" -- $1) )
}

plugins() {
    get_cordova && COMPREPLY=( $(compgen -W "$(${CORDOVA_BIN} plugin ls  | tr -d "[]',")" -- $1) )
}

get_cordova() {
    local cordova
    if [[ -n "${CORDOVA_BIN}" ]]; then return 0; fi
    cordova=$(eval echo ${COMP_WORDS[0]})
    if [[ -x $cordova ]]; then CORDOVA_BIN=$cordova; return 0; fi
    cordova=$(which cordova)
    if [[ $? -eq 0 ]]; then CORDOVA_BIN=$cordova; return 0; fi
    return 1
}

get_top_level_dir() {
    local path
    path=$(pwd)
    while [ $path != '/' ]; do
        if [ -d $path/.cordova ]; then
            echo $path
            return 0
        fi
        path=$(dirname $path)
    done
    return 1
}

_cordova()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Skip over any initial command line switches
    local i=1
    while [[ $i -lt ${#COMP_WORDS[*]} ]] && [[ "${COMP_WORDS[${i}]}" == -* ]]; do
        i=$((i+1));
    done

    # For the first word, supply all of the valid top-level commands
    if [[ ${COMP_CWORD} -eq $i ]]; then
        opts="create platform plugin prepare compile build emulate serve"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    case "${COMP_WORDS[$i]}" in
        create)
            if [[ ${COMP_CWORD} -eq $((i+1)) ]]; then
                COMPREPLY=( $(compgen -d -- ${cur}) )
                return 0
            fi
            ;;
        platform)
            if [[ ${COMP_CWORD} -eq $((i+1)) ]]; then
                opts="add rm remove ls"
                COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                return 0
            fi
            case "${COMP_WORDS[$((i+1))]}" in
                add)
                    opts="ios android wp7 wp8 blackberry www"
                    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                    return 0;
                    ;;
                rm|remove)
                    platforms ${cur}
                    return 0
                    ;;
            esac
            ;;
        plugin)
            if [[ ${COMP_CWORD} -eq $((i+1)) ]]; then
                opts="add rm remove ls"
                COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                return 0
            fi
            case "${COMP_WORDS[$((i+1))]}" in
                add)
                    COMPREPLY=( $(compgen -d -- ${cur}) )
                    return 0;
                ;;
                rm|remove)
                    plugins ${cur}
                    return 0
                    ;;
            esac
            ;;
        prepare|compile|build|emulate)
            platforms ${cur}
            return 0
            ;;
        serve)
            if [[ ${COMP_CWORD} -eq $((i+1)) ]]; then
                platforms ${cur}
                return 0
            fi
            ;;
    esac
}
complete -F _cordova cordova
