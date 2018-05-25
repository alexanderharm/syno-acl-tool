#!/bin/sh

# check if run as root
if [ $(id -u "$(whoami)") -ne 0 ]; then
	echo "SynoAclTool needs to run as root!"
	exit 1
fi

# check if git is available
if command -v /usr/bin/git > /dev/null; then
	git="/usr/bin/git"
elif command -v /usr/local/git/bin/git > /dev/null; then
	git="/usr/local/git/bin/git"
elif command -v /opt/bin/git > /dev/null; then
	git="/opt/bin/git"
else
	echo "Git not found therefore no autoupdate. Please install the official package \"Git Server\", SynoCommunity's \"git\" or Entware-ng's."
	git=""
fi

# save today's date
today=$(date +'%Y-%m-%d')

# self update run once daily
if [ ! -z "${git}" ] && [ -d "$(dirname "$0")/.git" ]; then
	if [ ! -f /tmp/.SynoAclToolUpdate ] || [ "${today}" != "$(date -r /tmp/.SynoAclToolUpdate +'%Y-%m-%d')" ]; then
		echo "Checking for updates..."
		# touch file to indicate update has run once
		touch /tmp/.SynoAclToolUpdate
		# change dir and update via git
		cd "$(dirname "$0")" || exit 1
		git fetch
		commits=$(git rev-list HEAD...origin/master --count)
		if [ $commits -gt 0 ]; then
			echo "Found a new version, updating..."
			git pull --force
			echo "Executing new version..."
			exec "$(pwd -P)/SynoAclTool.sh" "$@"
			# In case executing new fails
			echo "Executing new version failed."
			exit 1
		fi
		echo "No updates available."
	else
		echo "Already checked for updates today."
	fi
fi

# read ACLs from passed filename
awk -F ';' 'NF {

	# set path
	path=$1

	# create dir if it doesn'\''t exist
	system("mkdir -p \"" path "\"")

	# delete existing acls from dir
	system("synoacltool -del \"" path "\"")

	# inherit acl from enclosing dir
	system("synoacltool -enforce-inherit \"" path "\"")
	
	# process acls
	split($2, acls, ",")
	for (i in acls) {
		split(acls[i], acl, ":")
		if (acl[3]=="r") {
			system("synoacltool -add \"" path "\" \"" acl[1] ":" acl[2] ":allow:r-x---a-R-c--:fd--\"")
		}
		else if (acl[3]=="w") {
			system("synoacltool -add \"" path "\" \"" acl[1] ":" acl[2] ":allow:-w-pdD-A-W---:fd--\"")
		}
		else {
			system("synoacltool -add \"" path "\" \"" acl[1] ":" acl[2] ":allow:rwxpdDaARWc--:fd--\"")
		}
	}

	# propagate all acls
	system("LC_ALL=C find \"" path "\" -mindepth 1 ! -path '\''*/@eaDir/*'\'' ! -path '\''*/#recycle/*'\'' ! -path '\''*/#snapshot/*'\'' -execdir synoacltool -enforce-inherit {} '\'';'\''")

}' $1

exit 0