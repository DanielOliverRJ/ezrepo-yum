#!/bin/sh
#======================================================================
# mirror yum repos
#
# Prequisites to install:
# * yumutils (for reposync)
# * yum-plugin-fastestmirror
# * createrepo (and modifyrepo)
# * deltarpm
# * crudini
#======================================================================

# read in name of config file
repo_config=$1
file=$(basename "${repo_config}")
product="${file%.*}"

path_base='/var/www/repos/latest'
path_product="${path_base}/el7/${product}"

#
# reposync
#  -l       to use fastmirror plugin
#  --source to grab *.src.rpm
#  -m       to download comps.xml
#  --download_metadata to get non-standard metadata
#
#  -c  specify a config file
#  -r  repo-id to sync
#  -p  directory to download to
#
cmd_reposync='reposync -l --source --download-metadata -m'

#
# createrepo
#  -p        to make xml output human readable
#  --update  to reuse existing metadata
#  --workers to speed things up with more threads
#
#  -g add comps.xml to repo data
#
cmd_createrepo='createrepo --update -p --workers 2'

# Start with exit being ok
global_exit=0

#===================================
# Process all repos in config file
#===================================
repo_list=$(crudini --get --list ${repo_config})

printf '%s\n' "${repo_list}"| while IFS= read -r repo_id; do
  # Skip section if called main
  if [ "${repo_id}" = 'main' ]; then
    continue
  fi

  echo "---"
  echo "Repo: ${repo_id}"
  path_repo="${path_product}/${repo_id}"

  # Mirror repo structure
  n=0
  while [ $n -lt 3 ]; do
    echo "INFO: Starting reposync run $n" 1>&2
    ${cmd_reposync} -c ${repo_config} -r ${repo_id} -p ${path_product}
    exitcode=$?
    if [ $exitcode -eq 0 ];then break; fi
    echo "WARN: Reposync run $n failed with exitcode $exitcode" 1>&2
    n=$((n+1))
  done

  # Add group data if available
  opts_createrepo=''
  if [ -f "${path_repo}/comps.xml" ]; then
    #cp ${path_repo}/comps.xml ${path_repo}/Packages/
    opts_createrepo="-g ${path_repo}/comps.xml"
    echo "INFO: Comps.xml - updating information for ${repo_id}" 1>&2
  else
    echo "INFO: Comps.xml - nothing to processed for ${repo_id}" 1>&2
  fi

  # Generate repodata
  n=0
  while [ $n -lt 2 ]; do
    echo "INFO: Starting createrepo run $n" 1>&2
    ${cmd_createrepo} ${opts_createrepo} ${path_repo}
    exitcode=$?
    if [ $exitcode -eq 0 ];then break; fi
    echo "WARN: Createrepo run $n failed with exitcode $exitcode" 1>&2
    n=$((n+1))
  done

  # Add errata if available
  set -o pipefail
  updateinfo=$(ls -1t  ${path_repo}/*-updateinfo.xml.gz 2>/dev/null | head -1 )
  if [ -f $updateinfo  &&  $? -eq 0 ]; then
    echo "INFO: Errata - updating information for ${repo_id}" 1>&2
    #\cp $updateinfo ${path_repo}/updateinfo.xml.gz
    #gunzip -df ${path_repo}/updateinfo.xml.gz
    #modifyrepo ${path_repo}/updateinfo.xml ${path_repo}/repodata/
  else
    echo "INFO: Errata - nothing to be processed for ${repo_id}" 1>&2
  fi
done

exit ${global_exit}
