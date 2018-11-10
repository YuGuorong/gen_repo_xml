#!/bin/bash
#find current folders
#change character of folder / to # for easy sed/grep
dec_spec_path=( "bootchart" \
  "device#softwinner" \
  "hardware/aw"  \
  "i2c-tools-3.1.2" \
  "out" \
  "vendor/softwinner/brandy" \
  "vendor/softwinner/buildroot" \
  "vendor/softwinner/linux-3.4" \
  "vendor/softwinner/tools"   \
  "hardware/espressif" \
  "hardware/realtek" \ 
  "vendor/softwinner/out" \
  "vendor/softwinner/tools"  
)
declare -a unuse_path

function remove_parent
{
    p0=$1
    while [ "${p0}" != "" ]; do
        #echo remove paren $p0
        sed -i "/^${p0}\s*$/d" new_rep.txt
        p1=${p0%#*}
        if [ "${p1}" == "${p0}"  ] ; then
            break;
        fi
        p0=$p1
    done
}

find . -maxdepth 5 -type d ! -wholename '*.git*' -print | tee new_rep.txt
sed -i -e "s/^\.\///g" -e 's/\//#/g' new_rep.txt
sort new_rep.txt -o new_rep.txt

aosp_path=$(grep path manifest.xml | sed -e 's/.*path=\"//g' -e 's/\".*//g')

all_path=(${aosp_path[@]} ${dec_spec_path[@]})

for ap in ${all_path[@]}　;
do
    #echo aosp:[${ap}]
    ap=${ap//\//#}
    rm_prt_path=""
    grep -m 1  "^${ap}" new_rep.txt >/dev/null
    if [ $? -ne 0 ] ; then 
        unuse_path=(${unuse_path[@]} ${ap})
    else
        rm_prt_path=$ap
    fi

    #remove declare in aosp project from new_rep.txt, to list all left folders
    sed -i "/^${ap}.*$/d" new_rep.txt
    if [ "${rm_prt_path}" != "" ] ; then 
        remove_parent ${rm_prt_path}
    fi
done

rm aosp_miss.txt
cp manifest.xml clear_manifest.xml
for p in ${unuse_path[@]} 
do
    np=${p//#/\/}
    echo ${np}>>aosp_miss.txt
    pp=${np//\//\\\/}
    sed -i "/path=\"${pp}/d" clear_manifest.xml
done

sed -i "s/#/\//g" new_rep.txt
