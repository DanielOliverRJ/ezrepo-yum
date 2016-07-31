#!/bin/sh

MIRRORLIST='/etc/ezrepo/mirrorlist.txt'
#MIRRORLIST='./mirrorlist.txt.example'

#set defaults
FORM_product='centos-7'
FORM_repo='server'
FORM_snap='latest'
FORM_arch='x86_64'


# Following code is from: bashlib 0.4
# Handle GET and POST requests... (the QUERY_STRING will be set)
if [ -n "${QUERY_STRING}" ]; then
  # name=value params, separated by either '&' or ';'
  if echo "${QUERY_STRING}" | grep '=' >/dev/null ; then
    for Q in $(echo "${QUERY_STRING}" | tr ";&" "\012") ; do
      #
      # Clear our local variables
      #
      unset name
      unset value
      unset tmpvalue

      #
      # get the name of the key, and decode it
      #
      name=${Q%%=*}
      name=$(echo "${name}" | \
             sed -e 's/%\(\)/\\\x/g' | \
             tr "+" " ")
      name=$(echo "${name}" | \
             tr -d ".-")
      name=$(printf ${name})

      #
      # get the value and decode it. This is tricky... printf chokes on
      # hex values in the form \xNN when there is another hex-ish value
      # (i.e., a-fA-F) immediately after the first two. My (horrible)
      # solution is to put a space aftet the \xNN, give the value to
      # printf, and then remove it.
      #
      tmpvalue=${Q#*=}
      tmpvalue=$(echo "${tmpvalue}" | \
                 sed -e 's/%\(..\)/\\\x\1 /g')
      #echo "Intermediate \$value: ${tmpvalue}" 1>&2

      #
      # Iterate through tmpvalue and printf each string, and append it to
      # value
      #
      for i in ${tmpvalue}; do
          g=$(printf ${i})
          value="${value}${g}"
      done
      #value=$(echo ${value})

      eval "export FORM_${name}='${value}'"
    done
  else # keywords: foo.cgi?a+b+c
    Q=$(echo "${QUERY_STRING}" | tr '+' ' ')
    eval "export KEYWORDS='${Q}'"
  fi
fi


#-----------------------------------------
# Print output to STDOUT
#-----------------------------------------
if [ 'latest' != "${FORM_snap}" ]; then
  FORM_snap="archive/${FORM_snap}"
fi

cat <<HTML_HEADER
Content-type: text/html

<HTML>
<BODY>
<PRE>
HTML_HEADER

if [ -f "${MIRRORLIST}" ]; then
  while read -r mirror; do
    echo "http://${mirror}/${FORM_snap}/yum/${FORM_product}/${FORM_arch}/${FORM_repo}/"
  done <"${MIRRORLIST}"
else
  echo '# No mirrors'
fi

cat <<HTML_FOOTER
</PRE>
</BODY>
</HTML>
HTML_FOOTER
