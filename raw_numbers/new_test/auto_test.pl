#! /usr/bin/env perl
#
# Author Yuzhong Wen <wyz2014@vt.edu>
# Version 0.1
# Modified On 2016-04-16 17:18
# Created  2016-04-16 17:18
#
# This script is for running tests within a tmux session
#

use strict;
use warnings;

my $cerberus = "10.1.1.10";
my $operator = "wen";
my $mklinux_utils = "/home/wen/Projects/mklinux-utils/";

sub tmux_send_key_cmd {
    my $session = shift(@_);
    my $window = shift(@_);
    my $cmd = shift(@_);

    my $ret = "tmux send-keys -t $session:$window \"$cmd\" C-m";
    return $ret;
}

sub run_ssh {
    my $host = shift(@_);
    my $user = shift(@_);
    my $cmd = shift(@_);

    my $ret = `ssh $user\@$host \'$cmd\'`;

    return $ret;
}

sub create_tmux_session_cmd {
    my $session = shift(@_);

    my $ret = "tmux new-session -s $session -d;";

    return $ret;
}

sub create_tmux_window_cmd {
    my $session = shift(@_);
    my $window = shift(@_);

    my $ret = "tmux new-window -t $session:$window";

    return $ret;
}

sub ipmi_reboot {
    my $host = shift(@_);
    my $cmd = "ipmitool -I lanplus -H $host -U ADMIN -P ADMIN chassis power cycle";

    run_ssh($cerberus, "ywen", $cmd);
}

sub prepare_pcn_env {
    my $host = shift(@_);
    my $user = shift(@_);;
    my $cmd = '';

    # Setup 2 windows, one for primary and one for secondary
    $cmd = create_tmux_session_cmd("ftpop");
    run_ssh($host, $user, $cmd);
    $cmd = create_tmux_window_cmd("ftpop", "1");
    run_ssh($host, $user, $cmd);
    $cmd = create_tmux_window_cmd("ftpop", "2");
    run_ssh($host, $user, $cmd);
    print "TMUX session created on $host, take a rest...\n";

    sleep 2;
    print "Be ready to get into Jupiter\n";
    $cmd = tmux_send_key_cmd("ftpop", "1", "cd $mklinux_utils");
    run_ssh($host, $user, $cmd);
    $cmd = tmux_send_key_cmd("ftpop", "1", "sudo su");
    run_ssh($host, $user, $cmd);
    $cmd = tmux_send_key_cmd("ftpop", "1", "./mklinux_boot.sh 1");
    run_ssh($host, $user, $cmd);
    print "Booting 2nd kernel on $host, wait for 40 seconds\n";
    sleep 40;

    $cmd = tmux_send_key_cmd("ftpop", "1", "./tunnelize.sh");
    run_ssh($host, $user, $cmd);
    print "Tunnelize done\n";

    $cmd = tmux_send_key_cmd("ftpop", "2", "ssh root\@10.1.2.33");
    run_ssh($host, $user, $cmd);
    $cmd = tmux_send_key_cmd("ftpop", "2", "passwd");
    run_ssh($host, $user, $cmd);
    sleep 5;
    $cmd = tmux_send_key_cmd("ftpop", "2", "ifconfig ft_dummy_driver 10.1.1.47");
    run_ssh($host, $user, $cmd);
    print "Into the 2nd kernel, will leave the session there\n";

    $cmd = tmux_send_key_cmd("ftpop", "1", "cd ns;./launch_ns.sh");
    run_ssh($host, $user, $cmd);
    $cmd = tmux_send_key_cmd("ftpop", "1", "./popcorn_rep.sh 2");
    run_ssh($host, $user, $cmd);
    print "Into namespace\n";
}

sub mongoose_pcn_test {
    my $host = shift(@_);
    my $reps = shift(@_);
    #my @thread_cnts = ("2", "4", "8", "16", "32");
    my @file_set = ("t50k", "t100k", "t200k", "t400k", "t800k");
    #my @thread_cnts = ("4", "8", "16");
    my @thread_cnts = ("16");
    #my @file_set = ("500KB" , "1MB");

    my $cmd = '';

    # Steps:
    # 1. Start environment
    # 2. Start mongoose
    # 3. Reboot

    foreach my $iter (@thread_cnts) {
        my $working_dir = "mongoose_pcn_thread_$iter";
        print "Starting pcn-nginx test with $iter threads in dir $working_dir\n";
        `rm -rf $working_dir`;
        `mkdir $working_dir`;
        for (my $i = 0; $i < $reps; $i++) {
	    foreach my $file_size (@file_set) {
		    prepare_pcn_env($host, $operator);

		    # Setup a new window, for doing the file copying
		    $cmd = create_tmux_window_cmd("ftpop", "3");
		    run_ssh($host, $operator, $cmd);
		    $cmd = tmux_send_key_cmd("ftpop", "3", "sudo su");
		    run_ssh($host, $operator, $cmd);

		    # Run mongoose on window 1 (the one with namespace on)
		    $cmd = tmux_send_key_cmd("ftpop", "1", $mklinux_utils."custom_ramdisk/packages/mongoose/mg-server -r /root/web -t ". $iter);
		    run_ssh($host, $operator, $cmd);
		    sleep 5;

	    	    print "Testing iteration $i file size $file_size\n";
		    # Start ab
		    print "Starting test...\n";
		    `echo "STARTING thread count mongoose $iter file size $file_size iter $i" >>$working_dir/test_out-$file_size 2>&1`;
		    `ab -c 100 -n 20000 -r -s 999999 -g $working_dir/test-$i-$file_size http://$host:8080/$file_size >> $working_dir/test_out-$file_size 2>&1`;

		    `echo " ******************************************************************************************************* " >>$working_dir/test_out-$file_size 2>&1`;
		    #print "$working_dir/test-$i-$j-$file_size $working_dir/test_out_iter-$i-$j-$file_size";
		    print "Test finished\n";
		    print "Going to reboot...\n";
		    $cmd = tmux_send_key_cmd("ftpop", "3", "reboot");
		    run_ssh($host, $operator, $cmd);
		    sleep 10;
		    # Reboot and run it again
		    ipmi_reboot("10.1.1.107");
		    print "After 5mins we will have another shot!\n";
		    sleep 300;
	    }

        }
    }
}

sub mongoose_linux_test {
    my $host = shift(@_);
    my $reps = shift(@_);
    #my @thread_cnts = ("2", "4", "8", "16", "32");
    my @file_set = ("t10k", "t50k", "t100k", "t200k", "t300k", "t400k", "t800k");
    my @thread_cnts = ("4", "8", "16");
    #my @file_set = ("500KB" , "1MB");

    my $cmd = '';

    # Steps:
    # 1. Start environment
    # 2. Start mongoose
    # 3. Reboot
    # Setup 2 windows, one for primary and one for secondary
    $cmd = create_tmux_session_cmd("ftpop");
    run_ssh($host, $operator, $cmd);
    $cmd = create_tmux_window_cmd("ftpop", "1");
    run_ssh($host, $operator, $cmd);
    $cmd = create_tmux_window_cmd("ftpop", "2");
    run_ssh($host, $operator, $cmd);
    print "TMUX session created on $host, take a rest...\n";

    # Setup a new window, for doing the file copying
    $cmd = create_tmux_window_cmd("ftpop", "3");
    run_ssh($host, $operator, $cmd);
    $cmd = tmux_send_key_cmd("ftpop", "3", "sudo su");
    run_ssh($host, $operator, $cmd);
    $cmd = tmux_send_key_cmd("ftpop", "1", "sudo su");
    run_ssh($host, $operator, $cmd);


    foreach my $iter (@thread_cnts) {
        my $working_dir = "mongoose_linux_thread_$iter";
        print "Starting pcn-nginx test with $iter threads in dir $working_dir\n";
        `rm -rf $working_dir`;
        `mkdir $working_dir`;
        for (my $i = 0; $i < $reps; $i++) {
	    foreach my $file_size (@file_set) {
    		    print "Testing iteration $i file size $file_size\n";
		    # Run mongoose on window 1 (the one with namespace on)
		    $cmd = tmux_send_key_cmd("ftpop", "1", $mklinux_utils."custom_ramdisk/packages/mongoose/mg-server -r /root/web -t ". $iter);
		    run_ssh($host, $operator, $cmd);
		    sleep 5;

		    # Start ab
		    print "Starting test...\n";
		    `echo "STARTING thread count mongoose $iter file size $file_size iter $i" >>$working_dir/test_out-$file_size 2>&1`;
		    `ab -c 100 -n 20000 -r -s 999999 -g $working_dir/test-$i-$file_size http://$host:8080/$file_size >> $working_dir/test_out-$file_size 2>&1`;

		    `echo " ******************************************************************************************************* " >>$working_dir/test_out-$file_size 2>&1`;
		    #print "$working_dir/test-$i-$j-$file_size $working_dir/test_out_iter-$i-$j-$file_size";
		    print "Test finished, going to kill...\n";
		    $cmd = tmux_send_key_cmd("ftpop", "3", "killall mg-server");
		    run_ssh($host, $operator, $cmd);
		    run_ssh($host, $operator, $cmd);
		    run_ssh($host, $operator, $cmd);
		    print "After 10s we will have another shot!\n";
		    sleep 10;
	    }
        }
    }
}
# Popcorn test for 5 reps
mongoose_pcn_test("10.1.1.47", 1);
#mongoose_linux_test("10.1.1.47", 5);
