#!/usr/bin/env bash
# 
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.



# added by Rajesh...
# shell options  ...
export HISTSIZE=1000000
shopt -s histappend
shopt -s cdable_vars
shopt -s cdspell
shopt -s checkhash
shopt -s checkwinsize
shopt -s cmdhist
shopt -s dotglob
shopt -s expand_aliases
shopt -s extglob
shopt -s histreedit
shopt -s histverify
shopt -s hostcomplete
shopt -s interactive_comments
shopt -s lithist
shopt -s no_empty_cmd_completion
shopt -s progcomp
shopt -s promptvars

# shell completions ...
complete -A setopt set
complete -A user groups id
complete -A binding bind
complete -A helptopic help
complete -A alias alias unalias
complete -A signal -P '-' kill
complete -A stopped -P '%' fg bg
complete -A job -P '%' jobs disown
complete -A variable readonly unset
complete -A file -A directory ln chmod
complete -A user -A hostname finger pinky
complete -A directory find cd c pushd "`pwd`" mkdir rmdir mkd mkdirs rmd mvd
complete -A file -A directory -A user chown
complete -A file -A directory -A group chgrp
complete -o default -W 'Makefile' -P '-o ' qmake
complete -A command man which whatis whereis info apropos
complete -A file cat zcat pico nano vi vim view gvim gview rgvim rgview evim eview rvim rview \
				vimdiff elvis emacs edit emacsclient sudoedit red e ex joe jstar jmacs rjoe \
				jpico less zless more zmore p pg zip unzip rar unrar mplayer mp m

# added by Rajesh...
if [[ -f ~/sqllib/db2profile  ]] ; then
	source ~/sqllib/db2profile
fi

if [[ -f /etc/profile.d/bashrc.local.machine.sh ]] ; then
	source /etc/profile.d/bashrc.local.machine.sh
else
	export CLR_MACHINE=33
	export DEV_CD="/dev/hdd"
	export RK_SYS_PROFILE="gentoo-server"
fi

# RED=31, GREEN=32, YELLOW=33, BLUE=34, CYAN=36, WHITE=37  etc.
export CLR_USER_ROOT=31
export CLR_USER_OTHER=32	
FMT_USER_ROOT='\[\033[01;'${CLR_USER_ROOT}'m\]'
FMT_USER_OTHER='\[\033[01;'${CLR_USER_OTHER}'m\]'
FMT_MACHINE='\[\033[01;'${CLR_MACHINE}'m\]'
FMT_NULL='\[\033[00m\]'
# NAME_DISTRIBUTION='UBUNTU'

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now
	return
fi

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.
use_color=false
safe_term=${TERM//[^[:alnum:]]/.}	# sanitize TERM

if [[ -f /etc/DIR_COLORS ]] ; then
	grep -q "^TERM ${safe_term}" /etc/DIR_COLORS && use_color=true
elif type -p dircolors >/dev/null ; then
	if dircolors --print-database | grep -q "^TERM ${safe_term}" ; then
		use_color=true
	fi
fi

# define GIT, GITPUBLIC and GITPRIVATE because otherwise git normally
# traverses the parent directories looking for .git directory...
GIT='git --git-dir=.git --work-tree=.'
function git_branch 
{
	GIT_BRANCH=$(git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/' )
	[ -n "${GIT_BRANCH}" ] && echo -n " git:${GIT_BRANCH}" || echo -n
}

GITPUBLIC='git --git-dir=.public.git --work-tree=.'
function gitpublic_branch 
{
	GITPUBLIC_BRANCH=$( ${GITPUBLIC}  branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/' )
	[ -n "${GITPUBLIC_BRANCH}" ] && echo -n " gitpublic:${GITPUBLIC_BRANCH}" || echo -n
}

GITPRIVATE='git --git-dir=.private.git --work-tree=.'
function gitprivate_branch 
{
	GITPRIVATE_BRANCH=$( ${GITPRIVATE}  branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/' )
	[ -n "${GITPRIVATE_BRANCH}" ] && echo -n " gitprivate:${GITPRIVATE_BRANCH}" || echo -n
}

if ${use_color} ; then
	PS1_HOST="${FMT_MACHINE}\\h${FMT_NULL}"
	PS1_DIST="${FMT_MACHINE}${NAME_DISTRIBUTION}${FMT_NULL}"
	PS1_PROMPT="${FMT_MACHINE}\\\$${FMT_NULL}"
	PS1_USER=""     # initialization
	PS1_DIR=""      # initialization
	PS1_SSH=""		# initialization
	if [[ ${EUID} == 0 ]] ; then
		FMT_USER=${FMT_USER_ROOT}
		PS1_USER="${FMT_USER_ROOT}\\u${FMT_NULL}"
		PS1_DIR="${FMT_USER_ROOT}\\w${FMT_NULL}"
	else
		FMT_USER=${FMT_USER_OTHER}
        PS1_USER="${FMT_USER_OTHER}\\u${FMT_NULL}"
		PS1_DIR="${FMT_USER_OTHER}\\w${FMT_NULL}"
	fi
	
	if [ ! -z "${SSH_CLIENT}" ] ; then
		SSH_IP4="$(echo ${SSH_CLIENT} 2>/dev/null | cut -d ' ' -f 1 | cut -d '.' -f 4)"
		PS1_SSH="${FMT_MACHINE}ssh:${SSH_IP4}${FMT_NULL} "  # the space at the end is necessary for separator
	fi

	PS1_DATE=$(date)
	PS1_TTY=$(tty)
	PS1_TTY=$(echo ${PS1_TTY#/dev/} | tr '/' ':')
	PS1_TTY="${FMT_MACHINE}${PS1_TTY}${FMT_NULL}"
	PS1_SHLVL="${FMT_MACHINE}shlevel:${SHLVL}${FMT_NULL}"
	if [[ "${TERM}" == "screen" ]] ; then
		PS1_TERM="${FMT_MACHINE}${TERM}:${WINDOW}${FMT_NULL}"
	elif [[ "${TERM}" == "linux" ]] ; then
		PS1_TERM="${FMT_MACHINE}${TERM}-console${FMT_NULL}"
	else
		PS1_TERM="${FMT_MACHINE}${TERM}${FMT_NULL}"
	fi
	PS1="${PS1_USER} ${PS1_HOST} ${FMT_USER}(${FMT_NULL}${PS1_SSH}${PS1_TTY} ${PS1_TERM} ${PS1_SHLVL}${FMT_MACHINE}\$(git_branch)\$(gitprivate_branch)\$(gitpublic_branch)${FMT_NULL}${FMT_USER})${FMT_NULL} ${PS1_DIST} ${PS1_DIR}\n  ${PS1_PROMPT} "
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \w \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

# added by Rajesh...
alias mkdirp='mkdir -p -v'
alias ls='ls --color=auto'
alias ll='ls -lF'
alias reload-mouse='modprobe -r psmouse && modprobe psmouse'
export R_MAKE_CD_ISO='/usr/bin/mkisofs  -rvJR -joliet-long -allow-multidot -allow-leading-dots -allow-limited-size'
alias r-make-cd-iso="$R_MAKE_CD_ISO"  # -o out-file.iso /path/to/folder-files

export R_MAKE_DVDVIDEO_ISO='/usr/bin/mkisofs  -rvJR -dvd-video -joliet-long -allow-multidot -allow-leading-dots'
alias r-make-dvdvideo-iso="$R_MAKE_DVDVIDEO_ISO"  # -o out-file.iso  /path/to/folder/files

export R_BURN_DVD='/usr/bin/growisofs  -use-the-force-luke=notray -use-the-force-luke=tty -use-the-force-luke=dao  -speed=12 -overburn'
alias r-burn-dvd="$R_BURN_DVD"   # -Z /dev/sr0=/path/to/file.iso

# export R_BURN_CD='/usr/bin/cdrecord  -v -eject  -overburn speed=52 dev=ATAPI:0,1,0 driveropts=burnfree -dao'
export R_BURN_CD='/usr/bin/cdrecord  -v -eject  -overburn speed=52 dev=${DEV_CD} driveropts=burnfree -dao'
alias r-burn-cd="$R_BURN_CD"        # file.iso

export R_WODIM="/usr/bin/wodim -dao -v speed=48 dev=/dev/scd0 -overburn -eject driveropts=burnfree"
alias r-wodim="$R_WODIM"   # file.iso

export R_BLANK_CDRW='cdrdao blank --device /dev/hdd --blank-mode full --speed 52 --overburn --eject --save -v 2'
alias r-blank-cdrw="$R_BLANK_CDRW"  #   <no args>

# export R_CD_BURN_CUE='cdrdao write -n --device "ATAPI:/dev/hdd"  --speed 52 --overburn --eject --save -v 2 '
export R_CD_BURN_CUE='cdrdao write -n --device "${DEV_CD}"  --speed 52 --overburn --eject --save -v 2 '
alias r-cd-burn-cue="$R_BURN_CUE"  # file-name.cue

export RMEDIADIR="/mnt/backup1/rajesh/media/general/videos/temp-download/"

export PATH="/usr/lib/colorgcc/bin:$PATH:/home/local/SysAdmin/Bin:/home/local/usr/bin:/home/local/bin:/opt/bin"
# added for coloring support...
export PATH="/opt/lib/cw:/usr/share/cw:/lib/udev:$PATH"
export NOCOLOR_PIPE=1

# adding support for obsolete etcat and qpkg commands ...
export PATH="/usr/share/doc/gentoolkit-0.2.2/deprecated/etcat:/usr/share/doc/gentoolkit-0.2.2/deprecated/qpkg:$PATH"
export PATH="/usr/share/doc/gentoolkit-0.2.3_pre2/deprecated/etcat:/usr/share/doc/gentoolkit-0.2.3_pre2/deprecated/qpkg:$PATH"

export PYTHONPATH="/home/local/active/util/lib/python:/opt/sdb/interfaces/python"
# addmign module loading support for pike programming language...
export PIKE_MODULE_PATH="/home/local/SysAdmin/Lib/Pike:${HOME}/Devel/Svnroot/Krish/SysAdmin/Lib/Pike"
export PATH=${PATH}:${HOME}/devel/SvnRoot/Krish/SysAdmin/Bin:"$HOME/usr/bin"

# required for booish ...
export libdir=/usr/lib64
export MONO_PATH="/usr/lib64/boo:/usr/lib64/mono/boo:/home/rajesh/download/maxdb/dotnet/bin/mono-2.0/safe:/usr/lib/mono/nemerle"

# required for maxdb ...
export PATH="/opt/sdb/programs/bin:$PATH"

# required for superuser tools ...
export PATH="$PATH:/sbin:/usr/sbin:/usr/local/sbin"

export TEST_ECHO1='/usr/bin/echo EXECUTING nzbget -c ~/.nzbget/usenetserver.cfg -d $(pwd) *.nzb'
alias test-echo1="$TEST_ECHO1"

export FETCH_NZBS_NH='ls *nzb | /usr/bin/xargs -izz /usr/bin/nzbget -c ~/.nzbget/newshosting.cfg -d $(pwd) zz'
alias fetch-nzbs-nh="/usr/bin/echo EXECUTING: '$FETCH_NZBS_NH' ... && $FETCH_NZBS_NH"

export FETCH_NZBS_UNS='/usr/bin/ls *nzb | /usr/bin/xargs -izz /usr/bin/nzbget -c ~/.nzbget/usenetserver.cfg -d $(pwd) zz'
alias fetch-nzbs-uns="/usr/bin/echo EXECUTING: '$FETCH_NZBS_UNS' ... && $FETCH_NZBS_UNS"

export CHECK_RAR='/usr/bin/ls *.rar | /usr/bin/xargs -izz /usr/bin/unrar x -o+  zz'
alias check-rar="echo EXECUTING: '$CHECK_RAR' && $CHECK_RAR"

export CHECK_PAR2='/usr/bin/ls *.par2 | /usr/bin/xargs -izz /usr/bin/par2 r zz'
alias check-par2="echo EXECUTING:  '$CHECK_PAR2' && $CHECK_PAR2"

# using genisoimage ...
# export MOVIE=fool-and-final-2007-hindi;  genisoimage -dvd-video -publisher $MOVIE -p $MOVIE  -o ../$MOVIE.iso  .


# adding support for bash completion - Rajesh...
# set aliases to avoid Gentoo bug #98627.
[[ -f /etc/profile.d/bash-completion ]] &&  source /etc/profile.d/bash-completion

alias gi="grep -i --color=auto" 
alias girh="grep -irH --color=auto" 
alias egi="egrep -i --color=auto"
alias egirh="egrep -irH --color=auto" 
alias sxt="ssh -CXYt"

alias r-par2="ls *[pPaArR]2 | egrep -vi '.vol[0-9]+\+[0-9]+' | xargs -izz par2 r -q  -m1000  zz| egrep -i --color=auto 'target|repair is required|repair is not possible|blocks|missing|damaged'"
alias r-unrar='ls *[part][art][rt0][t0]1.rar $(ls *[Rr][Aa][Rr] | egrep -vi "part[0-9]*." ) | xargs -izz unrar x -o+ zz'
alias r-rmtemp="rm *nzb *sfv *SFV *r?? *[rR]2 *.1 *_broken *_duplicate1 *sample.avi *nfo nzbget-unknown-* *.segment0001"
alias kfmc="kfmclient openProfile filemanagement"
alias nsnp="netstat -petul --numeric-ports"
alias r-speaker-test="speaker-test -c2 -l5 -twav"

# Try to keep environment pollution down, EPA loves us.
unset use_color safe_term

export PAGER=$( [ -f /usr/bin/most ] && echo /usr/bin/most || echo "$PAGER" )

# Mysql "emerge config" related flags...

# alias r-mysqld-start="/usr/bin/mysqld_safe --defaults-file=~/private/server/mysql/config/mysql.conf"
# alias r-mysqld-stop='/bin/kill $(< ~/private/server/mysql/run/mysqld.pid )'
alias r-mysql-manager-connect="mysql -u rajesh --socket=$HOME/private/data/mysql/manager/sock/manager.sock -p"
alias r-mysql-manager-start='mysqlmanager --defaults-file=$HOME/private/data/mysql/manager/mysql.conf'
alias r-mysql-manager-stop='killall mysqlmanager'
alias r-kde='XSESSION=kde /usr/bin/startx -- -dpi 120 :0 vt7'
alias r-gnome='XSESSION=Gnome /usr/bin/startx -- -dpi 120 :1 vt8'
alias r-mouse='modprobe -vr psmouse && modprobe -v  psmouse'
export PATH="$PATH:$HOME/Bin:$HOME/devel/system/usr/bin"

# required for Fedora ...
alias vi='/usr/bin/vim'
alias r-mono='echo ":CLR:M::MZ::/usr/bin/mono:" > /proc/sys/fs/binfmt_misc/register'
alias rpmqw="rpm -q --whatprovides"
alias rpmqa="rpm -qa"
alias rpmql="rpm -ql"
alias r-mount-list="mount | egi \"sd|md\" | sort | awk '{printf(\"DEVICE: %-20s  MOUNTPT: %-30s  TYPE: %-10s   FLAGS: %s\n\", \$1, \$3, \$5, \$6)}'"
alias r-rsync-04='time for i in $( find /home/rajesh/private/media/content -mindepth 1 -maxdepth 1 -type d -exec basename {} \; )  ; do  time rsync -avpP {/home/rajesh/private/media/content,/mnt/data1/mnt/md4001/rajesh/private/media/content04}/${i}/ ; done'
alias ssu='sudo su -'

# alias git="${GIT}"
alias gitpublic="${GITPUBLIC}"
alias gitprivate="${GITPRIVATE}"

# added to use the cpu throttling feature ...
[ -f /etc/bashrc.local.cpumode.sh ] && source /etc/bashrc.local.cpumode.sh

# required by IBPP (Firebird C++ interface) ...
# export IBPP_LINUX=1

