---
tags: devops vpn
---

I was running *Raspbmc* in Raspberry Pi which I like to use once a year (but I'm
not gonna write about that part). What's interesting about that device is that I
always have it on and it's connected to my router, so it makes it a great
candidate for installing vpn server in it. And instead of getting another Pi to
run vpn server and keep it up and running 24/7, it's a good idea to just install
OpenVpn on it also since it's built on top of linux and that's what I had. There
have been lot of changes to the project and it also changed it's name to
[OSMc](https://osmc.tv/){:target="_blank"}. So I just decided to reformat,
get OSMC and install OpenVpn on it again. Since I didn't provision that server
with chef (would be interesting to see someone run chef client in Pi though)
I had to do everything manually again. Decided to write about it in case others
would be interested in creating similar setup also. And since OSMC is built on
top of Debian, this guide mostly applies to any Debian based setup.

<!--more-->

Before anything let's install needed packages and switch to root user since
most of what we'll do will require sudo permissions:
{% highlight bash %}
sudo su
apt-get update && apt-get install -y openvpn easy-rsa
{% endhighlight %}

Let's create *easy-rsa* folder:
{% highlight bash %}
cd /etc/openvpn
mkdir easy-rsa
cp -R /usr/share/easy-rsa/* easy-rsa/
{% endhighlight %}

Now set following variables in */etc/openvpn/easy-rsa/vars* file:
{% highlight bash %}
export KEY_COUNTRY=
export KEY_PROVINCE=
export KEY_CITY=
export KEY_ORG=
export KEY_EMAIL=
export KEY_OU=
{% endhighlight %}


Now let's kill old keys (if they exist) and source those variables:
{% highlight bash %}
cd easy-rsa/
./clean-all
touch keys/index.txt
echo 01 > keys/serial
. ./vars
{% endhighlight %}

It's time to build the keys and certs now. To build CA certificate run:
{% highlight bash %}
./build-ca
{% endhighlight %}

To build the server key run:
{% highlight bash %}
./build-key-server server
{% endhighlight %}

To build the DH key run:
{% highlight bash %}
./build-dh
{% endhighlight %}

After having keys generated, let's create the server config in
*/etc/openvpn/server.conf* file:
{% highlight text %}
port 1194
proto udp
dev tun

ca      /etc/openvpn/easy-rsa/keys/ca.crt    # generated keys
cert    /etc/openvpn/easy-rsa/keys/server.crt
key     /etc/openvpn/easy-rsa/keys/server.key  # keep secret
dh      /etc/openvpn/easy-rsa/keys/dh2048.pem

server 10.9.8.0 255.255.255.0  # internal tun0 connection IP
ifconfig-pool-persist ipp.txt

keepalive 10 120

comp-lzo         # Compression - must be turned on at both end
persist-key
persist-tun

# To forward traffic
push "redirect-gateway def1 bypass-dhcp"
# For hostnames to resolve
push "dhcp-option DNS 192.168.1.1"

status /var/log/openvpn-status.log

verb 3  # verbose mode
client-to-client
{% endhighlight %}

Here open vpn will listen on 1194 and it's udp, if you want it to listen on a
different port or be tcp, make sure to change this. *redirect-gateway* is to
forward internet traffic and to be able to access other boxes on the network.
Next line is to resolve dns. I put my router gateway so local hostnames will
also resolve. Your gateway may be different.
If for a scpecific client we don't want to redirect internet traffic we can add
this to client config:
{% highlight bash %}
route-nopull
route 192.168.1.0 255.255.255.0
dhcp-option DNS 192.168.1.1
{% endhighlight %}

Now we need to configure os for forwarding. Run:
{% highlight bash %}
echo 1 > /proc/sys/net/ipv4/ip_forward
{% endhighlight %}

Open **/etc/sysctl.conf* file and uncomment ```net.ipv4.ip_forward = 1``` line.

This will allow port forwarding but we still need to configure the firewall.

{% highlight bash %}
iptables -A FORWARD -i wlan0 -o tun0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s 10.9.8.0/24 -o wlan0 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.9.8.0/24 -o wlan0 -j MASQUERADE
iptables-save > /etc/iptables.up.rules
{% endhighlight %}

This will configure firewall for forwarding and we save the configuration to
*/etc/iptables.up.rules* file. We need to restore those settings when interface
starts after the reboot. Let's create a script file for it
*/etc/network/if-pre-up.d/iptables*:
{% highlight bash %}
#!/bin/sh
/sbin/iptables-restore < /etc/iptables.up.rules
{% endhighlight %}

And make the script executable:
{% highlight bash %}
chmod +x /etc/network/if-pre-up.d/iptables
{% endhighlight %}

Now vpn server is configured. We need to restart OpenVpn or just reboot the
server to make sure that firewall will still work.

## Client setup

For mac I like to use *Tunnelblick* client and for iOS *OpenVpn* app.
This should be almost same setup even if you prefer to use other clients.

Again, let's switch to root user, source the variables and generate client certs.
{% highlight bash %}
sudo su
cd /etc/openvpn/easy-rsa
. ./vars
./build-key-pass CLIENT NAME
{% endhighlight %}

I like to generate one key per device I'm using and I prefer to have password
for my mac client (using build-key-pass) and no password for iOS
client (using build-key).

We need to create the client config file also, which should look something like
this:


{% highlight text %}
client
dev tun
port 1194
proto udp

remote SERVER DNS 1194
nobind

ca ca.crt
cert CLIENT NAME.crt
key CLIENT NAME.key

comp-lzo
persist-key
persist-tun

verb 3
{% endhighlight %}

Make sure to set SERVER DNS and CLIENT NAME. For *Tunnelblick* we can just
create a folder which name ends with *.tblk*, put config file, *ca.crt*, and our
client *.crt* and *.key* files in it. Securely transfer this folder to client
and open it while you have *Tunnelblick* installed. *Tunnelblick* will create a
configuration for it.

For iOS, setup is similar but we'll use *.ovpn* file with certs and key embedded
in it. Save the above config in *.ovpn* file without *ca*, *cert* and
*key* lines, name it your CLIENT NAME.ovpn and run following lines:
{% highlight bash %}
echo "set CLIENT_CERT 0" >> CLIENT NAME.ovpn
echo "<ca>" >> CLIENT NAME.ovpn
cat ca.crt | grep -A 100 "BEGIN CERTIFICATE" | grep -B 100 "END CERTIFICATE" >> CLIENT NAME.ovpn
echo "</ca>" >> CLIENT NAME.ovpn
echo "<cert>" >> CLIENT NAME.ovpn
cat CLIENT NAME.crt | grep -A 100 "BEGIN CERTIFICATE" | grep -B 100 "END CERTIFICATE" >> CLIENT NAME.ovpn
echo "</cert>" >> CLIENT NAME.ovpn
echo "<key>" >> CLIENT NAME.ovpn
cat CLIENT NAME.key | grep -A 100 "BEGIN PRIVATE KEY" | grep -B 100 "END PRIVATE KEY" >> CLIENT NAME.ovpn
echo "</key>" >> CLIENT NAME.ovpn
{% endhighlight %}

Note to change CLIENT NAME to your client name. Transfer this file securely to your phone and open it while you have OpenVpn installed.
