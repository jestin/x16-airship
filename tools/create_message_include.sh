#!/bin/bash

my_dir="$(dirname "$0")"

$my_dir/filter_messages.sh $1 | \
	sed 's/\.word \(.*\)/\1/' | \
	$my_dir/number_messages.sh | \
	sed -e 's/^/'$2'_/'
