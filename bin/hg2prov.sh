#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/pvcs/tree/master/bin/hg2prov.sh>;
#3>    prov:wasDerivedFrom   <https://github.com/timrdf/pvcs/tree/master/bin/git2prov.sh>;
#3>    prov:wasDerivedFrom   <https://github.com/mmlab/Git2PROV/blob/master/lib/git2provConverter.js>;
#3>    prov:wasAttributedTo  <http://tw.rpi.edu/instances/TimLebo>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/pvcs/wiki/git2prov>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/pvcs/wiki/hg2prov>;
#3> .

myHash=`md5.sh -qs \`which $0\``
# e.g. cr-base-uri=http://provenanceweb.org cr-source-id=w3-org-2011-prov cr-dataset-id=mercurial-repository cr-version-id=latest
while [[ $# > 0 ]]; do 
   if [[ "$1" =~ cr-base-uri.* ]]; then
      cr_base_uri="${1##cr-base-uri=}"
   elif [[ "$1" =~ cr-source-id.* ]]; then
      cr_source_id="${1##cr-source-id=}"
   elif [[ "$1" =~ cr-dataset-id.* ]]; then
      cr_dataset_id="${1##cr-dataset-id=}"
   elif [[ "$1" =~ cr-version-id.* ]]; then
      cr_version_id="${1##cr-version-id=}"
   fi   
   shift
done

sd="$cr_base_uri/source/$cr_source_id/dataset/$cr_dataset_id"
sdv=$cr_base_uri/source/$cr_source_id/dataset/$cr_dataset_id/version/$cr_version_id

echo '@prefix dcterms: <http://purl.org/dc/terms/>.'
echo '@prefix xsd:     <http://www.w3.org/2001/XMLSchema#>.'
echo '@prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#>.'
echo '@prefix prov:    <http://www.w3.org/ns/prov#>.'
echo '@prefix prv:     <http://purl.org/net/provenance/ns#>.'
echo '@prefix pml:     <http://provenanceweb.org/ns/pml#>.'
echo '@prefix schema:  <http://schema.org/>.'
echo '@prefix prv:     <http://purl.org/net/provenance/ns#>.'
echo '@prefix nfo:     <http://www.semanticdesktop.org/ontologies/nfo/#>.'
echo '@prefix nif:     <http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#>.'

echo 
echo "#3> <> pml:wasGeneratedWithPlan <https://github.com/timrdf/pvcs/tree/master/bin/hg2prov.sh#$myHash> ."
echo "#3> <https://github.com/timrdf/pvcs/tree/master/bin/hg2prov.sh#$myHash>"
echo "#3>    a prov:Plan;"
echo "#3>    prov:specializationOf <https://github.com/timrdf/pvcs/tree/master/bin/hg2prov.sh> ."
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
        author=`hg log -r$rev --template "{author}"`
   commit_date=`hg log -r$rev --template "{date|isodate}"`
   description=`hg log -r$rev --template "{desc}"`
      diffstat=`hg log -r$rev --template "{diffstat}"`
       parents=`hg log -r$rev --template "{parents}"`

   AGENT=$sd/id/developer/`md5.sh -qs $author`

   echo "# rev: $rev $node $node_12"
   echo "<$sd/commit/$rev>"
   echo "   #pvcs:Commit;"
   echo "   a prov:Activity;"
   echo "   prov:wasAttributedTo <$AGENT>;"
   echo "   prov:endedAtTime \"$commit_date\"^^xsd:dateTime;"
   echo "   rdfs:comment \"$description\";"
   echo "   dcterms:description \"$diffstat\";"
   if [[ -z "$parents" ]]; then
      # If the changeset has only one "natural" parent 
      # (the predecessor revision) nothing is shown. (from 'hg help templates')
      let "previous=$rev-1"
      echo "   prov:wasInformedBy <$sd/commit/$previous>;"
   else
      echo "# WARNING: handle parents $parents"
      echo "WARNING: handle parents $parents" >&2
   fi
   for file in `hg log -r$rev --template "{files}"`; do
      echo "   prov:generated <$sd/revision/$rev/$file>;"
   done
   echo "."
   echo "<$AGENT>"
   echo "   a prov:Agent;"
   echo "   rdfs:label \"$author\";"
   echo "."

   for file in `hg log -r$rev --template "{files}"`; do
      echo "#    * $file"   
      echo "<$sd/revision/$rev/$file>"
      echo "   a prv:Immutable, nif:String, prov:Entity;"
      echo "   #prov:value __contents of the file__"
      echo "   #pvcs:hasHash [ nfo:hashAlgorithm, nfo:hashValue ];"
      echo "   prov:alternateOf      <$web_page/file/$node_12/$file>;"
      echo "   prv:serializedBy      <$web_page/raw-file/$node_12/$file>;"
      echo "   prov:specializationOf <$sd/$file>;"
      echo "."
      echo "<$sd/$file>"
      echo "   a nfo:FileDataObject, prov:Entity;"
      echo "   rdfs:label   \"$file\";"
      echo "   nfo:fileName \"$file\";"
      echo "   prov:alternateOf <$web_page/file/tip/$file>;"
      echo "   prv:serializedBy <$web_page/raw-file/tip/$file>;"
      echo "   nfo:fileURL      <$web_page/raw-file/tip/$file>;"
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
done
