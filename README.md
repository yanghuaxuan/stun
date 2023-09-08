# (s)plit (tun)nel
**a wireguard split tunnel script**

This is a simple bash script that utilizes Linux network namespaces to selectively split tunnel applications. 

## Usage
- Require root permissions
- You must also edit the script's `$IF` variable to the external interface you're using (i.e. `eth0`). I'm currently using `eno1`, and therefore, the script is set to use `eno1`

```
split_tunnel create|destroy

create - Must be run before using exec. Create a new network namespace for split tunneling, along with other stuff to make this all work.
destroy - Destroys the network namespace for split tunneling.

split tunnel exec [COMMAND]

exec - Run command in the split tunnel network namespace
```

### Example
```
$ curl ifconfig.me
-> Your VPN's ip :(

# split_tunnel create
# split_tunnel exec curl ifconfig.me
-> Your residential ip :)
``` 
