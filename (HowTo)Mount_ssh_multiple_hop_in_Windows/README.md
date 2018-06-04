# Mount Server via multiple ssh hop in Windows

1. install cygwin with including vim, ssh + ...

2. install sshfs-win
	https://github.com/billziss-gh/sshfs-win
3. copy all files of sshfs-win (bin, dev, etc) to cygwin root dir
	(do not override existing files)
4. make proper ssh setting in cygwin (authentication, config)

```bash
ssh-keygen

cat ~/.ssh/id_rsa.pub # copy to both tunnels and destination
```
```
#config
Host  sv
	Hostname 9.9.9.9 #ip of destination
	User kijong #id of destination
	Port 2030
	ProxyCommand -W %h:%p kijong@199.199.199.199 -p 2030 #id and ip of tunnel
```

if there is no vim installed in cygwin, use command below.
```
mkdir ~/.ssh
echo -en "Host sv\n\tHostname 9.9.9.9\n ......" > ~/.ssh/config
```

5. in cygwin terminal, connect remote dir to a new location (which is not exist in windows)

```bash
#first, check your id number and group id number in cygwin
# just type 
id

>localaccount, gid

#do not make destination dir (..Desktop/Server)
#the command below will make that dir. set proper uid and gid instead of 999 and 9999
sshfs -o allow_other -o uid=999 -o gid=9999 sv:/home/users/kijong/myproject /cygdrive/c/Users/kijong/Desktop/Server
or..
sshfs sv:/home/users/kijong/myproject Z:
```

