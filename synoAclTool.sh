#!/bin/sh

# check if run as root
if [ $(id -u "$(whoami)") -ne 0 ]; then
	echo "SynoAclTool needs to run as root!"
	exit 1
fi

# save today's date
today=$(date +'%Y-%m-%d')

# read ACLs from passed filename
/bin/awk -F ';' 'NF {

	# set path
	path=$1

	# create dir if it doesn'\''t exist
	system("/bin/mkdir -p \"" path "\"")

	# delete existing acls from dir
	system("/usr/syno/bin/synoacltool -del \"" path "\"")

	# inherit acl from enclosing dir
	system("/usr/syno/bin/synoacltool -enforce-inherit \"" path "\"")
	
	# process acls
	split($2, acls, ",")
	for (i in acls) {
		split(acls[i], acl, ":")
		if (acl[3]=="r") {
			system("/usr/syno/bin/synoacltool -add \"" path "\" \"" acl[1] ":" acl[2] ":allow:r-x---a-R-c--:fd--\"")
		}
		else if (acl[3]=="w") {
			system("/usr/syno/bin/synoacltool -add \"" path "\" \"" acl[1] ":" acl[2] ":allow:-w-pdD-A-W---:fd--\"")
		}
		else {
			system("/usr/syno/bin/synoacltool -add \"" path "\" \"" acl[1] ":" acl[2] ":allow:rwxpdDaARWc--:fd--\"")
		}
	}

	# propagate all acls

	system("LC_ALL=C /bin/find \"" path "\" -mindepth 1 -name '\''#recycle'\'' -prune -o -name '\''#snapshot'\'' -prune -o -name '\''*/@eaDir/*'\'' -prune -o -name '\''*/.TemporaryItems/*'\'' -prune -o -exec /usr/syno/bin/synoacltool -enforce-inherit {} '\'';'\''")

}' $1

exit 0