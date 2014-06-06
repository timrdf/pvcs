#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/pvcs/tree/master/bin/hg2prov.sh>;
#3>    prov:wasDerivedFrom   <https://github.com/timrdf/pvcs/tree/master/bin/git2prov.sh>;
#3>    prov:wasDerivedFrom   <https://github.com/mmlab/Git2PROV/blob/master/lib/git2provConverter.js>;
#3>    prov:wasAttributedTo  <http://tw.rpi.edu/instances/TimLebo>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/pvcs/wiki/git2prov>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/pvcs/wiki/hg2prov>;
#3> .

echo '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.'
echo '@prefix prov: <http://www.w3.org/ns/prov#>.'
echo '@prefix prv:  <http://purl.org/net/provenance/ns#>.'
echo '@prefix pml:  <http://provenanceweb.org/ns/pml#>.'
echo 
echo "#3> <> pml:wasGeneratedWithPlan <https://github.com/timrdf/pvcs/tree/master/bin/hg2prov.sh> ."
echo 

web_page=''
web_raw=''

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
# https://github.com/timrdf/pvcs/wiki/hg2prov#suiting-git2prov
#git --no-pager log --date=iso --name-status --pretty=format:"$file,%H,%P,%an,%ad,%cn,%cd,\"%s\"," -- "$file" \
# | sed '/^$/d;s/ *$//' \
# | awk 'ORS=NR%2?FS:RS' \
# | sed 's/, \(.\)[^,]*$/,\1/'
#hg log --template="{node},{parents},{author|emailuser},{author|email},{date|isodate},committer-name?,committer-date?,{desc}\n"
# TODO: {branch}
for rev in `hg log --template="{rev}\n"`; do
   web_page=`hg paths default` # e.g. https://dvcs.w3.org/hg/prov
   node=`hg log -r$rev --template "{node}"`
   node_12=${node:0:12}
   echo "# rev: $rev $node $node_12"
   for file in `hg log -r$rev --template "{files}"`; do
      echo "#    * $file"   
      echo "<$web_page/file/$node_12/$file>"
      echo "   a prov:Entity;"
      echo "   rdfs:label \"$file\";"
      echo "   prov:specializationOf <$web_page/file/tip/$file>;"
      echo "   prv:serializedBy      <$web_page/raw-file/tip/$file>;"
      echo "."
   done
   for added in `hg log -r$rev --template "{file_adds}"`; do
      echo "#    A $added"   
   done
   for copied in `hg log -r$rev --template "{file_copies}"`; do
      echo "#    C $copied"   
   done
   for modified in `hg log -r$rev --template "{file_mods}"`; do
      echo "#    M $modified"   
   done
   for deleted in `hg log -r$rev --template "{file_dels}"`; do
      echo "#    D $deleted"   
   done
   #echo "# $file"
   #echo "#3> <$web_page$file>"
   #echo "#3>    a prov:Entity;"
   #echo "#3>    rdfs:label \"$file\";"
   #echo "#3>    prv:serializedBy <$web_raw$file> ."
   #echo
done
