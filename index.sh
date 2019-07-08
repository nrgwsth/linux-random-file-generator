#/bin/bash

dd_bs=0
dd_count=0

f_get_size() {
	if [ "$filesize" == "small" ]; then
		unit="K"
		size=$((1+$RANDOM%4)) 
		dd_bs="$size$unit"
		dd_count=1
	elif [ "$filesize" == "large" ]; then
		unit="M"
		size=$((8 + $RANDOM % 256))
		dd_bs="$size$unit"
		dd_count=1
	else
		unit="K"
		size=$((4+$RANDOM%8192))
		dd_bs="$size$unit"
		dd_count=1024
	fi
}

f_generate_files_in_dirs() {
	local dir_name=$1
	local num_files=$2

	echo $dir_name, $num_files
	`mkdir -p ${dir_name}`

	for ((i=0;i<$num_files;i++))
	do
		f_get_size
		dd if=/dev/urandom of=${dir_name}/file_$((i+1)) bs=${dd_bs} count=${dd_count}
	done
}

dirs=()

f_get_new_directory_structure() {
	local num_dir=$1
	local local_dirs=()

	for elem in "${dirs[@]}"
	do
		for ((i=0;i<$num_dir;i++))
		do
			local_dirs+=("${elem}/dir_$((i+1))")
		done
	done

	if [ ${#dirs[@]} -eq 0 ]; then
		for ((i=0;i<$num_dir;i++))
		do
			local_dirs+=("dir_$((i+1))")
		done
	fi
	dirs=("${local_dirs[@]}")
}

f_generate_files() {
	local foldername=$1
	local childheirarchy=$2
	local childheirarchyarr=(`echo $childheirarchy | tr ',' "\n"`)
	local num_files=${childheirarchyarr[-1]}
	# remove last element
	childheirarchyarr=("${childheirarchyarr[@]::${#childheirarchyarr[@]}-1}")
	for element in "${childheirarchyarr[@]}"
	do
        f_get_new_directory_structure $element
	done
	printf '%s\n' "${dirs[@]}"
	for element in "${dirs[@]}"
	do
		f_generate_files_in_dirs $foldername/$element $num_files
	done
}

# name of parent folder. Need to be created beforehand.
foldername=$1

# comma separated list of children directory. Default 2,2,2 means rott directory will have 2 child dir and each child dir will have 2 dirs.
# last number is no of files in each dir.
childheirarchy=$2
childheirarchy="${childheirarchy:-3,2,10}"

# range of file sizes. small- 4K-1M, medium- 1M-16M, large- 16M-1G, xlarge- 16M-4G, all-4K-4G
filesize=$2
filesize="${filesize:-small}"

f_generate_files $foldername $childheirarchy $filesize

