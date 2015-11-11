#!/usr/bin/env bash

# LÖVE version
readonly LOVE_DEF_VERSION=0.9.2

readonly INSTALLED=false
readonly EMBEDDED=false

readonly OPTIONS="La:d:e:hi:l:p:r:t:u:v:x:"
readonly LONG_OPTIONS="author:,clean,description:,email:,exclude:,help,icon:,love:,pkg:,release:,title:,url:,version:"
readonly ARGS=$(getopt -o "$OPTIONS" -l "$LONG_OPTIONS" -n 'love-release' -- "$@")


# Helper functions

# Dependencies check
check_deps () {
    command -v curl  > /dev/null 2>&1 || {
        >&2 echo "curl is not installed. Aborting."
        local EXIT=true
    }
    command -v zip   > /dev/null 2>&1 || {
        >&2 echo "zip is not installed. Aborting."
        local EXIT=true
    }
    command -v unzip > /dev/null 2>&1 || {
        >&2 echo "unzip is not installed. Aborting."
        local EXIT=true
    }
    command -v getopt > /dev/null 2>&1 || {
        local opt=false
    } && {
        unset GETOPT_COMPATIBLE
        local out
        out=$(getopt -T)
        if (( $? != 4 )) && [[ -n $out ]]; then
            local opt=false
        fi
    }
    if [[ $opt == false ]]; then
        >&2 echo "GNU getopt is not installed. Aborting."
        local EXIT=true
    fi
    if ! command -v readlink > /dev/null 2>&1 || ! readlink -m / > /dev/null 2>&1; then
        command -v greadlink > /dev/null 2>&1 || {
            >&2 echo "GNU readlink is not installed. Aborting."
            local EXIT=true
        } && {
            readlink () {
                greadlink "$@"
            }
        }
    fi

    command -v lua   > /dev/null 2>&1 || {
        echo "lua is not installed. Install it to ease your releases."
    } && {
        LUA=true
    }
    if [[ $EXIT == true ]]; then
        exit_module "deps"
    fi
}

# Get user confirmation, simple Yes/No question
## $1: message, usually just a question
## $2: default choice, 0 - yes; 1 - no, default - yes
## return: 0 - yes, 1 - no
get_user_confirmation () {
    if [[ -z $2 || $2 == "0" ]]; then
        read -n 1 -p "$1 [Y/n]: " yn
        local default=0
    else
        read -n 1 -p "$1 [y/N]: " yn
        local default=1
    fi
    case $yn in
        [Yy]* )
            echo; return 0;;
        [Nn]* )
            echo; return 1;;
        "" )
            return $default;;
        * )
            echo; return $default;;
    esac
}


# Generate LÖVE version variables
## $1: LÖVE version string
## return: 0 - string matched, 1 - else
gen_version () {
    if [[ $1 =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        LOVE_VERSION=$1
        LOVE_VERSION_MAJOR=${BASH_REMATCH[1]}
        LOVE_VERSION_MINOR=${BASH_REMATCH[2]}
        LOVE_VERSION_REVISION=${BASH_REMATCH[3]}
        return 0
    fi
    return 1
}


# Compare two LÖVE versions
## $1: First LÖVE version
## $2: comparison operator
##     "ge", "le", "gt" "lt"
##     ">=", "<=", ">", "<"
## $3: Second LÖVE version
## return: 0 - true, 1 - false
compare_version () {
    if [[ $1 =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        local v1_maj=${BASH_REMATCH[1]}
        local v1_min=${BASH_REMATCH[2]}
        local v1_rev=${BASH_REMATCH[3]}
    else
        return 1
    fi
    if [[ $3 =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        local v2_maj=${BASH_REMATCH[1]}
        local v2_min=${BASH_REMATCH[2]}
        local v2_rev=${BASH_REMATCH[3]}
    else
        return 1
    fi

    case $2 in
        ge|\>= )
            if (( $v1_maj >= $v2_maj && $v1_min >= $v2_min && $v1_rev >= $v2_rev )); then
                return 0
            else
                return 1
            fi
            ;;
        le|\<= )
            if (( $v1_maj <= $v2_maj && $v1_min <= $v2_min && $v1_rev <= $v2_rev )); then
                return 0
            else
                return 1
            fi
            ;;
        gt|\> )
            if (( $v1_maj > $v2_maj || ( $v1_max == $v2_max && $v1_min > $v2_min ) ||
                ( $v1_max == $v2_max && $v1_min == $v2_min && $v1_rev > $v2_rev ) )); then
                return 0
            else
                return 1
            fi
            ;;
        lt|\< )
            if (( $v1_maj < $v2_maj || ( $v1_max == $v2_max && $v1_min < $v2_min ) ||
                ( $v1_max == $v2_max && $v1_min == $v2_min && $v1_rev < $v2_rev ) )); then
                return 0
            else
                return 1
            fi
            ;;
    esac
}


# Read configuration
## $1: system name
read_config () {
    if [[ $LUA == true ]] && [[ -f "conf.lua" ]]; then
        local var
        var=$(lua - <<EOF
f = loadfile("conf.lua")
t, love = {window = {}, modules = {}, screen = {}}, {}
f()
love.conf(t)

-- "love", "windows", "osx", "debian" or "android"
os = "$1"

fields = {
    "identity", "version", "game_version", "icon", "exclude",
    "title", "author", "email", "url", "description", }

for _, f in ipairs(fields) do
    t[f] = t[f] or ""
end

t.os = t.os or {}
for _, v in ipairs(t.os) do
    t.os[v] = {}
end

if os == "default" then
    t.os.default = {}
end

if t.os[os] then
    print(os:upper()..'=true')
    for _, f in ipairs(fields) do
        t.os[os][f] = t.os[os][f] or t[f]
        if type(t.os[os][f]) == "table" then
            str = f:upper()..'=('
            for _, v in ipairs(t.os[os][f]) do
                str = str..' "'..v..'"'
            end
            str = str..' )'
            print(str)
        else
            print(f:upper()..'="'..t.os[os][f]..'"')
        end
    end
else
    print(os:upper()..'=false')
end

if t.os.windows and os == "windows" then
    t.os.windows.x32 = t.os.windows.x32 and true or false
    t.os.windows.x64 = t.os.windows.x64 and true or false
    t.os.windows.installer = t.os.windows.installer and true or false
    t.os.windows.appid = t.os.windows.appid or ""
    print("X32="..tostring(t.os.windows.x32))
    print("X64="..tostring(t.os.windows.x64))
    print("INSTALLER="..tostring(t.os.windows.installer))
    print("APPID="..t.os.windows.appid)
end
EOF
)
        eval "$var"
    fi
}


# Read script options
## $1: options prefix
read_options () {
    local pre="$1"
    eval set -- "$ARGS"
    while true; do
        case "$1" in
            -a|--${pre}author )       AUTHOR="$2"; shift 2 ;;
            --${pre}clean )           rm -rf "$CACHE_DIR"; shift ;;
            -d|--${pre}description )  DESCRIPTION="$2"; shift 2 ;;
            -e|--${pre}email )        EMAIL="$2"; shift 2 ;;
            -h|--${pre}help )         short_help; exit 0 ;;
            -i|--${pre}icon )
                ICON="$2"
                if [[ -d $ICON ]]; then
                    local wd
                    local icon
                    icon="$(readlink -m "$ICON")"
                    wd="$(readlink -m "$PWD")"
                    EXCLUDE+=( "${icon//$wd\/}/*" )
                elif [[ -f $ICON ]]; then
                    EXCLUDE+=( "$ICON" )
                fi
                shift 2 ;;
            -l|--${pre}love )         if ! gen_version "$2"; then exit_module "version"; fi; shift 2 ;;
            -p|--${pre}pkg )          IDENTITY="$2"; shift 2 ;;
            -r|--${pre}release )      RELEASE_DIR="$2"; shift 2 ;;
            -t|--${pre}title )        TITLE="$2"; shift 2 ;;
            -u|--${pre}url )          URL="$2"; shift 2 ;;
            -v|--${pre}version )      GAME_VERSION="$2"; shift 2 ;;
            -x|--${pre}exclude )      EXCLUDE+=( "$2" ); shift 2 ;;
            -- ) shift; break ;;
            * ) shift ;;
        esac
    done
}


# Test if default module should be executed
default_module () {
    if [[ $? -ne 2 ]]; then
        DEFAULT_MODULE=false
    fi
}

# Print short help
short_help () {
    cat <<EndOfSHelp
Usage: love-release.sh [options...] [files...]
Options:
 -h           Print short help
 -t <title>   Set the project's title
 -r <release> Set the release directory
 -v <version> Set the LÖVE version
Modules:
 -L    LÖVE
EndOfSHelp
}

dump_var () {
    echo "LOVE_VERSION=$LOVE_VERSION"
    echo "LOVE_DEF_VERSION=$LOVE_DEF_VERSION"
    echo "LOVE_WEB_VERSION=$LOVE_WEB_VERSION"
    echo
    echo "RELEASE_DIR=$RELEASE_DIR"
    echo "CACHE_DIR=$CACHE_DIR"
    echo
    echo "IDENTITY=$IDENTITY"
    echo "GAME_VERSION=$GAME_VERSION"
    echo "ICON=$ICON"
    echo
    echo "TITLE=$TITLE"
    echo "AUTHOR=$AUTHOR"
    echo "EMAIL=$EMAIL"
    echo "URL=$URL"
    echo "DESCRIPTION=$DESCRIPTION"
    echo
    echo "${FILES[@]}"
}


# Modules functions

# Init module
## $1: Pretty module name
## $2: Configuration module name
## $3: Module option
## return: 0 - if module should be executed, else exit 2
init_module () {
    (
        opt="$3"
        if (( ${#opt} == 1 )); then opt="-$opt"
        elif (( ${#opt} >= 2 )); then opt="--$opt"; fi
        eval set -- "$ARGS"
        while true; do
            case "$1" in
                $opt ) exit 0 ;;
                -- )   exit 1 ;;
                * )    shift ;;
            esac
        done
    )
    local opt=$?
    local module="$2"
    read_config "$module"
    module=${module^^}
    if (( $opt == 0 )); then
        if [[ ${!module} == false ]]; then
            read_config "default"
        fi
    else
        if [[ ${!module} == false ]]; then
            exit_module "execute"
        fi
    fi
    gen_version $VERSION
    unset VERSION
    MODULE="$1"
    CACHE_DIR="$CACHE_DIR/$2"
    read_options "$3"
    LOVE_FILE="${TITLE}.love"
    mkdir -p "$RELEASE_DIR" "$CACHE_DIR"
    echo "Generating $TITLE with LÖVE $LOVE_VERSION for ${MODULE}..."
    return 0
}

# Create the LÖVE file
## $1: Compression level 0-9
create_love_file () {
    local dotfiles=()
    for file in .*; do
        if [[ $file == '.' || $file == '..' ]]; then continue; fi
        if [[ -d $file ]]; then file="$file/*"; fi
        dotfiles+=( "$file" )
    done
    local wd
    local release_dir
    release_dir="$(readlink -m "$RELEASE_DIR")"
    wd="$(readlink -m "$PWD")"
    zip -FS -$1 -r "$RELEASE_DIR/$LOVE_FILE" \
        -x "$0" "${release_dir//$wd\/}/*" "${dotfiles[@]}" "${EXCLUDE[@]}" @ \
        "${FILES[@]}"
}

# Exit module
## $1: optional error identifier
## $2: optional error message
exit_module () {
    if [[ -z $1 ]]; then
        echo "Done !"
        exit 0
    fi
    if [[ -n $2 ]]; then
        >&2 echo -e "$2"
    fi
    case $1 in
        execute )
            exit 2 ;;
        binary )
            >&2 echo "LÖVE $LOVE_VERSION could not be found or downloaded."
            exit 3 ;;
        options )
            exit 4 ;;
        version )
            >&2 echo "LÖVE version string is invalid."
            exit 5 ;;
        deps )
            exit 6 ;;
        undef|* )
            exit 1 ;;
    esac
}

# Main
main () {
    check_deps

    # Get latest LÖVE version number
    gen_version $LOVE_DEF_VERSION
    LOVE_WEB_VERSION=$(curl -s https://love2d.org/releases.xml | grep -m 2 "<title>" | tail -n 1 | grep -Eo "[0-9]+.[0-9]+.[0-9]+")
    gen_version $LOVE_WEB_VERSION

    DEFAULT_MODULE=true

    TITLE="$(basename $(pwd))"
    PROJECT_DIR="$PWD"
    RELEASE_DIR=releases
    CACHE_DIR=~/.cache/love-release
    FILES=()
    EXCLUDE=()

    if (( $? != 0 )); then short_help; exit_module "options"; fi
    eval set -- "$ARGS"
    read_options
    while [[ $1 != '--' ]]; do shift; done; shift
    for arg do
        FILES+=( "$arg" )
    done
    if (( ${#FILES} == 0 )); then FILES+=( "." ); fi
    eval set -- "$ARGS"

    if [[ $INSTALLED == false && $EMBEDDED == false ]]; then
        exit_module "undef" "love-release has not been installed, and is not embedded into one script."
    fi

    if [[ ! -f "main.lua" ]]; then
        >&2 echo "No main.lua file was found."
        exit_module 1
    fi

    if [[ $EMBEDDED == true ]]; then
        : # include_scripts_here
    elif [[ $INSTALLED == true ]]; then
        SCRIPTS_DIR="scripts"
        for file in "$SCRIPTS_DIR"/*.sh; do
            (source "$file")
            default_module
        done
    fi


    (
        init_module "LÖVE" "love" "L"
        create_love_file 9
        exit_module
    )
    if [[ $? -ne 0 && $DEFAULT_MODULE == true ]]; then
    (
        init_module "LÖVE" "default"
        create_love_file 9
        exit_module
    )
    fi

    return 0
}


main "$@"

