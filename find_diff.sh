#!/usr/bin/env bash
set -o errexit
#set -o nounset
set -o pipefail

function setup_var_colors() {
    COff='\e[0m'            # Text Reset
    # Regular Colors
    Black='\e[0;30m'        # Black
    Red='\e[0;31m'          # Red
    Green='\e[0;32m'        # Green
    Yellow='\e[0;33m'       # Yellow
    Blue='\e[0;34m'         # Blue
    Purple='\e[0;35m'       # Purple
    Cyan='\e[0;36m'         # Cyan
    White='\e[0;37m'        # White
    # Bold
    BBlack='\e[1;30m'       # Black
    BRed='\e[1;31m'         # Red
    BGreen='\e[1;32m'       # Green
    BYellow='\e[1;33m'      # Yellow
    BBlue='\e[1;34m'        # Blue
    BPurple='\e[1;35m'      # Purple
    BCyan='\e[1;36m'        # Cyan
    BWhite='\e[1;37m'       # White
};setup_var_colors

while getopts "s:d:t:" opt
do
    case $opt in
        s) source_dir=$OPTARG ;;
        d) destnation_dir=$OPTARG ;;
        t) templates_dir=$OPTARG ;;
        *) echo "input parameters error!\n  -s input your source directory\n  -d input your destination directory" ;;
    esac
done

function check_input(){
  [ X${source_dir} == "X" ] && echo " input your source directory " 
  [ X${destnation_dir} == "X" ] && echo "input your destination directory"
  [ X${templates_dir} == "X" ] && echo "input your templates directory"

  if [[ ! -d $source_dir ]] || [[ ! -d $destnation_dir ]] || [[ ! -d $templates_dir ]];then
      echo "source directory or destination directory do not exists"
  fi
}

check_input

python3=/Library/Frameworks/Python.framework/Versions/3.7/bin/python3
current_date=$(date +"%Y%m%d_%H%M%S")

prefix_name=${source_dir//\//_}_${destnation_dir//\//_}_${current_date}

base_dir=${templates_dir}/${prefix_name}

only_git_file_name_list_var=""
only_remote_file_name_list_var=""

# git_file_name_list=${base_dir}/git_file_name_list_${current_date}
# remote_file_name_list=${base_dir}/remote_file_name_list_${current_date}

only_git_file_name_list=${base_dir}/only_git_file_name_list_${current_date}
only_remote_file_name_list=${base_dir}/only_remote_file_name_list_${current_date}


git_find_file_name_list=${base_dir}/git_find_file_name_list_${current_date}
remote_find_file_name_list=${base_dir}/remote_find_file_name_list_${current_date}


only_git_find_file_name_list=${base_dir}/only_git_find_file_name_list_${current_date}
only_remote_find_file_name_list=${base_dir}/only_remote_find_file_name_list_${current_date}

both_find_file_name_list=${base_dir}/both_find_file_name_list_${current_date}

contain_both_compare_html_list=${base_dir}/contain_both_compare_html_list_${current_date}


if [ ! -d ${base_dir} ];then
  mkdir ${base_dir}
fi

for i in `diff -rq ${source_dir} ${destnation_dir}|grep -v "^Files.*and.*differ$"|grep "Only in ${source_dir}"|awk -F: '{print $2}'`
do
  only_git_file_name_list_var=${only_git_file_name_list_var}___${i}
done

for j in `diff -rq ${source_dir} ${destnation_dir}|grep -v "^Files.*and.*differ$"|grep "Only in ${destnation_dir}"|awk -F: '{print $2}'`
do
  only_remote_file_name_list_var=${only_remote_file_name_list_var}___${j}
done

find ${source_dir} -type f | grep -vE  "(\/\.[a-zA-z]*\/|\.git$|\.gitignore$)" > ${git_find_file_name_list}
cp ${git_find_file_name_list} ${both_find_file_name_list}

find ${destnation_dir} -type f | grep -vE  "(\/\.[a-zA-z]*\/|\.git$|\.gitignore$)" > ${remote_find_file_name_list}


for i in `echo ${only_git_file_name_list_var} | sed 's@___@ @g'`
do
  echo $i >> ${only_git_file_name_list}
done

for j in `echo ${only_remote_file_name_list_var} | sed 's@___@ @g'`
do
  echo $j >> ${only_remote_file_name_list}
done


for i in `cat ${only_git_file_name_list}`
do
  gsed -i "/^.*\/${i}$/d" ${both_find_file_name_list}
done

for i in `cat ${both_find_file_name_list}`
do
  j=${i##*/}

  git_file=`grep "^.*\/${j}$" ${git_find_file_name_list}`
  remote_file=`grep "^.*\/${j}$" ${remote_find_file_name_list}`



  # ${python3} diff2HtmlCompare.py ${git_file} ${remote_file} -d ${base_dir}/${j}.html &

  diff_n=`${python3} diff2HtmlCompare.py ${git_file} ${remote_file} -d ${base_dir}/${j}.html` && printf "%s %s %s\n" ${git_file} ${base_dir#templates/}/${j}.html ${diff_n} >> ${contain_both_compare_html_list} &
done

for i in `cat ${only_git_file_name_list}`
do
  only_git_file=`grep "^.*\/${i}$" ${git_find_file_name_list}`
  cp ${only_git_file} ${base_dir}/
  printf "%s %s\n" ${only_git_file} ${base_dir#templates/}/${i} >> ${only_git_find_file_name_list}
done

for i in `cat ${only_remote_file_name_list}`
do
  only_remote_find_file=`grep "^.*\/${i}$" ${remote_find_file_name_list}`
  cp ${only_remote_find_file} ${base_dir}/
  printf "%s %s\n" ${only_remote_find_file} ${base_dir#templates/}/${i} >> ${only_remote_find_file_name_list}
done


echo ${base_dir}
echo ${contain_both_compare_html_list}
echo ${only_git_find_file_name_list}
echo ${only_remote_find_file_name_list}