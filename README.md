# (s)plit (tun)nel
**a wireguard split tunnel script**

This is a simple bash script that utilizes Linux network namespaces to selectively split tunnel applications. 

## Usage
Require root permissions
```
split_tunnel create|destroy

create - Must be run before using exec. Create a new network namespace for split tunneling, along with other stuff to make this all work.
destroy - Destroys the network namespace for split tunneling.

split tunnel exec [COMMAND]

exec - Run command in the split tunnel network namespace
```

### Example
```
# split_tunnel create
# split_tunnel exec curl ifconfig.me
``` 
