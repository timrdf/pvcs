#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/pvcs/tree/master/bin/git2prov.sh>;
#3>    prov:wasDerivedFrom   <https://github.com/mmlab/Git2PROV/blob/master/lib/git2provConverter.js>;
#3>    prov:wasAttributedTo  <http://tw.rpi.edu/instances/TimLebo>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/pvcs/wiki/git2prov>;
#3> .

# git remote -v
# origin   git@github.com:timrdf/prizms.git (fetch)
# origin   git@github.com:timrdf/prizms.git (push)
# origin   https://github.com/tetherless-world/opendap.git (fetch)
# origin   https://github.com/tetherless-world/opendap.git (push)
origin=`git remote -v | grep "^origin" | awk '{print $2}' | head -1`
if [[ -n "$origin" && "$origin" =~ git@github.com:* ]]; then
   # echo $origin
   # e.g. git@github.com:timrdf/prizms.git
   #                                              README.md
   # <==>
   # https://github.com/timrdf/prizms/tree/master/README.md
   # https://raw.github.com/timrdf/prizms/master/README.md

   #                                                  "user" / "repo"
   web_page=''
   web_page=`echo $origin | sed 's/^git@github.com:\(.*\)\/\(.*\).git$/https:\/\/github.com\/\1\/\2\/tree\/master\//'`
   web_raw=''
   web_raw=` echo $origin | sed 's/^git@github.com:\(.*\)\/\(.*\).git$/https:\/\/raw.github.com\/\1\/\2\/master\//'`
elif [[ -n "$origin" && "$origin" =~ https://github.com/* ]]; then # Note, the s/ below could apply to those above, but IIABDFI...
   # echo $origin
   # e.g. https://github.com/timrdf/prizms.git
   #                                              README.md
   # <==>
   # https://github.com/timrdf/prizms/tree/master/README.md
   # https://raw.github.com/timrdf/prizms/master/README.md

   #                                                   "user" / "repo"
   web_page=''
   web_page=`echo $origin | sed 's/^https:..github.com.\(.*\)\/\(.*\).git$/https:\/\/github.com\/\1\/\2\/tree\/master\//'`
   web_raw=''
   web_raw=` echo $origin | sed 's/^https:..github.com.\(.*\)\/\(.*\).git$/https:\/\/raw.github.com\/\1\/\2\/master\//'`
else
   web_page=''
fi
if [[ "$origin" == "$web_page" ]]; then
   web_page=''
   web_raw=''
fi

for file in `git --no-pager log --pretty=format: --name-only --diff-filter=A | sort -u | grep -v '^$'`; do
   echo "# $file"
   echo "#3> <$web_page$file>"
   echo "#3>    a prov:Entity;"
   echo "#3>    rdfs:label \"$file\";"
   echo "#3>    prv:serializedBy <$web_raw$file> ."
   echo
   # Ignore commit messages (%s) for the CSV:
   #git --no-pager log --date=iso --name-status --pretty=format:"$file,%H,%P,%an,%ad,%cn,%cd," -- "$file" \
   # https://github.com/timrdf/pvcs/wiki/git2prov#git2provconverterjs
   #                                                                   commit hash
   #                                                                   | parent hash
   #                                                                   | |
   #                                                                   | |   author name
   #                                                                   | |   |   author date
   #                                                                   | |   |---|
   #                                                                   | |   |   |   committer name
   #                                                                   | |   |---|   |   committer date
   #                                                                   | |   |   |   |---|
   #                                                                   | |   |---|   |   |   subject (i.e. commit msg)
   #                                                                   | |   |---|   |---|   |
   git --no-pager log --date=iso --name-status --pretty=format:"$file,%H,%P,%an,%ad,%cn,%cd,%s," -- "$file" \
    | sed '/^$/d;s/ *$//' \
    | awk 'ORS=NR%2?FS:RS' \
    | sed 's/, \(.\)[^,]*$/,\1/'
done
