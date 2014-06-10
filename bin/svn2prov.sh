#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/pvcs/tree/master/bin/svn2prov.sh>;
#3>    prov:wasDerivedFrom   <https://github.com/timrdf/pvcs/tree/master/bin/hg2prov.sh>;
#3>    prov:wasDerivedFrom   <https://github.com/timrdf/pvcs/tree/master/bin/git2prov.sh>;
#3>    prov:wasDerivedFrom   <https://github.com/mmlab/Git2PROV/blob/master/lib/git2provConverter.js>;
#3>    prov:wasAttributedTo  <http://tw.rpi.edu/instances/TimLebo>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/pvcs/wiki/git2prov>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/pvcs/wiki/hg2prov>;
#3> .

PVCS_HOME=$(cd ${0%/*} && echo ${PWD%/*})
me=$(cd ${0%/*} && echo ${PWD})/`basename $0`

TEMP="_"`basename $0``date +%s`_$$.tmp
svn log -v --xml > $TEMP

saxon.sh $PVCS_HOME/src/xsl/svn2prov.xsl xml ttl -v \
   cr-base-uri=http://provenanceweb.org \
   cr-source-id=github-com-provbench cr-dataset-id=meta cr-version-id=svn \
   -in $TEMP
rm $TEMP
exit

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
