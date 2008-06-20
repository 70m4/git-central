#!/bin/sh

test_description='server post-receive email notification'

. ./test-lib.sh

export POST_RECEIVE_EMAIL_DUMP=true

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git config --add branch.master.remote origin &&
	git config --add branch.master.merge refs/heads/master &&
	GIT_DIR=./server/.git git config --add hooks.mailinglist commits@list.com &&
	GIT_DIR=./server/.git git config --add hooks.debug true &&
	GIT_DIR=.
'

install_server_hook 'post-receive-email' 'post-receive'

test_expect_success 'simple commit' '
	echo $test_name >a &&
	git commit -a -m "$test_name" &&
	git push &&
	old_commit_hash=$(git rev-parse HEAD^)
	new_commit_hash=$(git rev-parse HEAD)
	new_commit_date=$(git log -n 1 --pretty=format:%cd HEAD)
	interpolate ../t2200-1.txt 1.txt old_commit_hash new_commit_hash new_commit_date
	test_cmp 1.txt server/.git/refs.heads.master.out
'

test_done

