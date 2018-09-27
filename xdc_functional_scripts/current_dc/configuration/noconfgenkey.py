#!/usr/bin/env python

# @@@ START COPYRIGHT @@@
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# @@@ END COPYRIGHT @@@

import os
import re
import sys
import pty
import subprocess
import getpass
from threading import Thread
from optparse import OptionParser

no_pexpect = 0
try:
    import pexpect
except ImportError:
    no_pexpect = 1

no_sshpass = 0
try:
    p = subprocess.Popen(['sshpass'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    p.communicate()
except OSError:
    no_sshpass = 1

SSH_CFG = 'StrictHostKeyChecking=no\nNoHostAuthenticationForLocalhost=yes\n'
TMP_SSH_DIR = '/tmp/.ssh'
SSH_CFG_FILE = TMP_SSH_DIR + '/config'
PRIVATE_KEY = TMP_SSH_DIR + '/id_rsa'
PUB_KEY = TMP_SSH_DIR + '/id_rsa.pub'
AUTH_KEY = TMP_SSH_DIR + '/authorized_keys'

TRAF_CFG_FILE = '/etc/trafodion/trafodion_config'
TRAF_USER = 'trafodion'

class PexpectRemote(object):
    def __init__(self, host, user, pwd):
        self.host = host
        self.user = user
        self.pwd = pwd

    def copy(self, local_folder, remote_folder='.'):
        cmd = 'scp -oStrictHostKeyChecking=no -r %s %s@%s:%s' % (local_folder, self.user, self.host, remote_folder)
        p = pexpect.spawn(cmd, timeout=3)
        try:
            rc = p.expect([pexpect.TIMEOUT, 'password: '])
            has_err = 0
            if rc == 0:
                has_err = 1
            else:
                rc = p.sendline(self.pwd)
                p.expect([pexpect.TIMEOUT, pexpect.EOF])
                if 'Permission denied' in p.before: has_err = 1
                if rc == 0: has_err = 1
        except pexpect.EOF:
            return

        p.close()
        if has_err:
            err('Failed to copy files to host [%s] using pexpect, check your password' % self.host)

class SSHRemote(object):
    def __init__(self, host, user='', pwd=''):
        self.host = host
        self.user = user
        self.rc = 0
        self.pwd = pwd

    def _execute(self, cmd):
        try:
            master, slave = pty.openpty()
            p = subprocess.Popen(cmd, stdin=slave, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

            self.stdout, self.stderr = p.communicate()
            if p.returncode:
                self.rc = p.returncode
                print self.stdout
        except Exception as e:
            err('Failed to run commands on remote host: %s' % e)

    def copy(self, local_folder, remote_folder='.'):
        """ copy file to user's home folder """
        if not os.path.exists(local_folder):
            err('Copy file error: %s doesn\'t exist' % local_folder)

        cmd = []
        if self.pwd: cmd = ['sshpass', '-p', self.pwd]
        cmd += ['scp', '-oStrictHostKeyChecking=no', '-r']
        cmd += [local_folder]
        if self.user:
            cmd += ['%s@%s:%s/' % (self.user, self.host, remote_folder)]
        else:
            cmd += ['%s:%s/' % (self.host, remote_folder)]

        self._execute(cmd)
        if self.rc != 0: err('Failed to copy files to host [%s] using ssh, check your password' % self.host)

def ok(msg):
    print '\n\33[32m***[OK]: %s \33[0m' % msg

def info(msg):
    print '\n\33[33m***[INFO]: %s \33[0m' % msg

def err(msg):
    """ used by main script """
    sys.stderr.write('\n\33[31m***[ERROR]: %s \33[0m\n' % msg)
    sys.exit(1)

def run_cmd(cmd):
    """ check command return value and return stdout """
    p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout, stderr = p.communicate()
    if p.returncode != 0:
        msg = stderr if stderr else stdout
        err('Failed to run command %s: %s' % (cmd, msg))
    return stdout.strip()

def gen_key_file():
    run_cmd('mkdir -p %s' % TMP_SSH_DIR)
    run_cmd('echo -e "y" | ssh-keygen -t rsa -N "" -f %s' % PRIVATE_KEY)
    run_cmd('cp -f %s %s' % (PUB_KEY, AUTH_KEY))

    with open(SSH_CFG_FILE, 'w') as f:
        f.write(SSH_CFG)
    run_cmd('chmod 600 %s %s; chmod 700 %s' % (SSH_CFG_FILE, AUTH_KEY, TMP_SSH_DIR))

def del_key_file():
    run_cmd('rm -rf %s' % TMP_SSH_DIR)

def get_nodes():
    ''' parse node list from trafodion_config '''
    node_list = ''
    #if os.path.exists(TRAF_CFG_FILE):
    #    with open(TRAF_CFG_FILE, 'r') as f:
    #        traf_cfgs = f.readlines()
    #    try:
    #        line = [l for l in traf_cfgs if 'NODE_LIST' in l][0]
    #        node_list = re.search(r'NODE_LIST="(.*)"', line).groups()[0]
    #    except Exception as e:
    #        err('Cannot get node list from %s' % TRAF_CFG_FILE)
    # user input
    #else:
    try:
        node_lists = raw_input('Enter node list to set passwordless SSH(separated by comma): ')
        if not node_lists: err('Empty value')
        node_list = ' '.join(expNumRe(node_lists))
    except KeyboardInterrupt:
        info('Aborted ...')

    return node_list.split()

def expNumRe(text):
    explist = []
    for regex in text.split(','):
        regex = regex.strip()
        r = re.match(r'(.*)\[(\d+)-(\d+)\](.*)', regex)
        if r:
            h = r.group(1)
            d1 = r.group(2)
            d2 = r.group(3)
            t = r.group(4)

            convert = lambda d: str(('%0' + str(min(len(d1), len(d2))) + 'd') % d)
            if d1 > d2: d1, d2 = d2, d1
            explist.extend([h + convert(c) + t for c in range(int(d1), int(d2)+1)])

        else:
           # keep original value if not matched
            explist.append(regex)

    return explist

def get_options():
    usage = 'usage: %prog [options]\n'
    usage += '  This tool is used to set up passwordless SSH on specific nodes for specific user.'
    parser = OptionParser(usage=usage)
    parser.add_option("-u", "--user", dest="user", metavar="USER",
                      help="User name to set up passwordless SSH for.")

    (options, args) = parser.parse_args()
    return options

def main():
    options = get_options()
    if options.user:
        user = options.user
    else:
        user = getpass.getuser()

    gen_key_file()
    nodes = get_nodes()
    remote_folder = '/root' if user == 'root' else '/opt/' + user

    info('Setting up passwordless SSH across nodes [%s] for user [%s]' % (','.join(nodes), user))
    if no_sshpass and no_pexpect:
        remotes = [SSHRemote(node, user=user, pwd='') for node in nodes]
    elif no_sshpass and not no_pexpect:
        pwd = getpass.getpass('Input remote host SSH Password: ')
        remotes = [PexpectRemote(node, user=user, pwd=pwd) for node in nodes]
    else:
        pwd = getpass.getpass('Input remote host SSH Password: ')
        remotes = [SSHRemote(node, user=user, pwd=pwd) for node in nodes]

    for remote in remotes:
        info('Setting up ssh on host [%s]' % remote.host)
        remote.copy(TMP_SSH_DIR, remote_folder)

    del_key_file()
    ok('Success!')

if __name__ == '__main__':
    main()
