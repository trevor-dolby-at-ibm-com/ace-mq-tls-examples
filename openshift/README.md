# MQ in CP4i (OpenShift)

Running queue managers in OpenShift changes the challenges when using TLS with MQ channels, but the 
basic principles are the same. The connectivity into OpenShift is normally via ingress Routes, and
for non-HTTP traffic these work best with TLS. MQ channels can use the same TLS-based ingress as HTTPS
traffic does, and the MQ operator will (if asked) create "TLS passthrough" Routes automatically for
queue managers. This leads to something like this:

![mq-cp4i-light](/pictures/mq-cp4i-light.png#gh-light-mode-only)![mq-cp4i-dark](/pictures/mq-cp4i-dark.png#gh-dark-mode-only)

The MQ clients connect to the standard HTTPS port 443, and the OpenShift ingress will send the
connections to the appropriate queue manager. Note that connections from inside the cluster can
use the standard MQ port 1414 and do not have to use TLS.

## MQ server configuration

The [create-pki.sh](/create-pki.sh) and [create-openshift.sh](/openshift/create-openshift.sh) scripts
will create the required keys, keystores, and OpenShift YAML files that are needed to create the
queue manager. Before running the scripts, the [cp4iqm-ccdt.json](/openshift/cp4iqm-ccdt.json) and
[cp4iqm-ccdt-define.mqsc](/openshift/cp4iqm-ccdt-define.mqsc) should be adjusted to reflect the
correct external DNS name for the cluster ingress.

After the scripts have run, applying the following files will create a queue manager and 
allow clients to connect:

- generated-output/mqserver-tls-secret/mqserver-tls-secret.yaml
- generated-output/mqserver-tls-trust/mqserver-tls-trust.yaml
- openshift/mq-tls-configmap.yaml
- openshift/cp4iqm.yaml

A separate Route may be needed for clients that cannot use hostname SNI 
(see [below](#client-configuration-for-sni) for details):
- openshift/mq-client-svrconn-route.yaml

The queue manager will use the `CN=mqserver,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US` key
issued by CA1 (`CN=ace-demo-CA1,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US`).

## MQ client configuration

The MQ clients will use the `CN=mqclient,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US` key
issued by CA1 (`CN=ace-demo-CA1,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US`), but there are 
multiple options for telling the MQ clients to use this key.

The scripts will create both CMS KDB and PKCS12 keystores with the same keys, and either
can be used depending the configuration. The key setting for the client channel is `CERTLABL` (spelled 
`certificateLabel` in JSON CCDT files), as that is what tells the MQ client which certificate
to use when connecting to the queue manager; see [cp4iqm-ccdt.json](/openshift/cp4iqm-ccdt.json) and
[cp4iqm-ccdt-define.mqsc](/openshift/cp4iqm-ccdt-define.mqsc) for examples.

### Channel definition

MQ clients normally need a client channel definition table (CCDT) to connect using TLS (the old `MQSERVER`
environment variable does not work with TLS connections), and this can be either JSON or classic AMQCLCHL.TAB
format. For JSON, the `MQCCDTURL` environment variable can be used to point the client to the JSON file:
```
MQCCDTURL=file:/home/tdolby/github.com/ace-mq-tls-examples/openshift/cp4iqm-ccdt.json
```
while the `MQCHLLIB` environment variable does the equivalent for the older format:
```
MQCHLLIB=/home/tdolby/github.com/ace-mq-tls-examples/generated-output/mqclient-ccdt
```
Note that this is pointing to a directory, and the file is assumed to be named `AMQCLCHL.TAB`. The name
can be changed using `MQCHLTAB`.

### Keystores

The CCDT file specifies the certificate label (and possibly the queue manager certificate using
`SSLPEERNAME`) but does not say where the keystore resides on disk. This is specified using the
`MQSSLKEYR` environment variable to point to either a KDB or PKCS12 file:
```
MQSSLKEYR=/home/tdolby/github.com/ace-mq-tls-examples/generated-output/mqclient-kdb/mqclient
```
(which points to the mqclient KDB files but does not take the '.kdb' extension), or 
```
MQSSLKEYR=/home/tdolby/github.com/ace-mq-tls-examples/generated-output/ace-p12/aceclient-plus-CA1.p12
```
which points to the file itself. Both keystore formats have passwords, but the KDB format
has the password "stashed" with the keystore so no password needs to be provided. In this case,
the PKCS12 file does not have a stashed password, so the `MQKEYRPWD` environment variable is used
to provide the password.

### Keystore listing

The `runmqakm` command can be helpful in understanding what keys and CA certificates are present
in a keystore, as it has a `list` option:
```
$ /opt/mqm/bin/runmqakm -cert -list -pw changeit -db generated-output/ace-p12/aceclient-plus-CA1.p12
Certificates found
* default, - personal, ! trusted, # secret key
!       CN=ace-demo-CA2,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US
!       CN=ace-demo-CA1,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US
-       CN=aceclient,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US
```
and similarly for KDB:
```
$ /opt/mqm/bin/runmqakm -cert -list -db generated-output/mq-kdb/qm.kdb -stashed -v
Certificates found
* default, - personal, ! trusted, # secret key
!       CN=ace-demo-CA1,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US  CN=ace-demo-CA1,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US  CN=ace-demo-CA1,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US
!       CN=ace-demo-CA2,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US  CN=ace-demo-CA2,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US  CN=ace-demo-CA2,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US
-       CN=mqserver,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US  CN=mqserver,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US  CN=ace-demo-CA1,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US
```
Note that the `-v` option would cause the first command to display the same verbose output as the second.

### MQ client examples

Using channel tables and KDB keystores:
```
export MQCHLLIB=/home/tdolby/github.com/ace-mq-tls-examples/generated-output/mqclient-ccdt 
export MQSSLKEYR=/home/tdolby/github.com/ace-mq-tls-examples/generated-output/mqclient-kdb/mqclient 
/opt/mqm/samp/bin/amqsgetc DEMO.QUEUE cp4iqm
```

Using a JSON CCDT and PKCS12 keystore:
```
export MQCCDTURL=file:/home/tdolby/github.com/ace-mq-tls-examples/openshift/cp4iqm-ccdt.json
export MQKEYRPWD=changeit
export MQSSLKEYR=/home/tdolby/github.com/ace-mq-tls-examples/generated-output/mqclient-p12/mqclient-plus-CA1.p12
/opt/mqm/samp/bin/amqsputc DEMO.QUEUE cp4iqm
```

## ACE configuration

Connecting to the queue manager from ACE is very similar to other MQ clients:

![ace-mq-cp4i-light](/pictures/ace-mq-cp4i-light.png#gh-light-mode-only)![ace-mq-cp4i-dark](/pictures/ace-mq-cp4i-dark.png#gh-dark-mode-only)

For ACE, the important configuration settings are in the MQEndpoint policy (or possibly on MQ nodes). 
The [CP4iQM](/DefaultPolicies/CP4iQM.policyxml) policy file shows the configuration, with the host 
and port pointing to the OpenShift ingress on port 443 and the certificate label pointing to `aceclient`:
```
    <destinationQueueManagerName>cp4iqm</destinationQueueManagerName>
    <queueManagerHostname>cp4iqm-ibm-mq-qm-cp4i.apps.openshift.yourcompany.com</queueManagerHostname>
    <listenerPortNumber>443</listenerPortNumber>
    <SSLCertificateLabel>CN=aceclient,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US</SSLCertificateLabel>
```
The `aceclient` certificate was issued by a different CA (`CA2`) from the `mqserver` and `mqclient` CA, so
the queue manager must be given the CA2 public certificate to ensure `aceclient` will be accepted. This is
achieved using the [mqserver-tls-trust](/openshift/mqserver-tls-trust-template.yaml) secret, mounted as a
trusted key in the [cp4iqm YAML](/openshift/cp4iqm.yaml). With that in place, the AUTHREC statements in the
[MQ config map](/openshift/mq-tls-configmap.yaml) will give `aceclient` permission to access the queue 
manager and `DEMO.QUEUE`:
```
    SET CHLAUTH('MQ.CLIENT.SVRCONN') TYPE(SSLPEERMAP) SSLPEER('CN=aceclient') USERSRC(MAP) MCAUSER('aceclient') ACTION(REPLACE)
    SET AUTHREC PRINCIPAL('aceclient') OBJTYPE(QMGR) AUTHADD(CONNECT,INQ)
    SET AUTHREC PROFILE('DEMO.QUEUE') PRINCIPAL('aceclient') OBJTYPE(QUEUE) AUTHADD(BROWSE,PUT,GET,INQ)
```

## Non-TLS options

NodePorts can be used instead of TLS-based ingress Routes, though this brings with it more 
complicated networking and security challenges. 

From inside the cluster, the service name can be used without TLS, connecting as normal to 
port 1414.

## Key aspects of configuration

### QM SecurityPolicy set to UserExternal
For the AUTHREC statements to have any effect, the queue manager must be configured to work with
users that exist only in the MQ configuration and do not exist in the operating system user
registry or in LDAP. This is achieved by adding
```
    Service:
        Name=AuthorizationService
        EntryPoints=14
        SecurityPolicy=UserExternal
```
to qm.ini, where UserExternal signifies that MQ should not attempt to verify the existence of 
the userids presented (as shown [here](https://www.ibm.com/docs/en/ibm-mq/9.4.x?topic=manager-example-configuring-queue-mutual-tls-authentication))

### Client configuration for SNI

Although MQ can work without using the hostname for SNI data (see below), the OpenShift Route
configuration is simpler when hostnames are used and this is possible starting at 
[MQ 9.2.1](https://www.ibm.com/docs/en/ibm-mq/9.2.x?topic=mqclientini-ssl-stanza-client-configuration-file#q016900___tlsoutsni).
Adding the following 
```
SSL:
   OutboundSNI = HOSTNAME
```
to mqclient.ini, which is usually in /var/mqm/mqclient.ini but can be relocated (see 
https://www.ibm.com/docs/en/ibm-mq/9.4.x?topic=mqclientini-location-client-configuration-file).

## TLS SNI

TLS has included the concept of a “Server Name Indicator” for a while, and this normally contains 
the hostname of the server to which the connection is being made. This hostname may be one of many 
hostnames that resolve to the same IP address, so the SNI hostname allows the server to determine
which website (or service) the client is trying to reach before the TLS negotiation begins. This is 
described in many places on the Internet with HTTPS as the primary example, including a GlobalSign
blog post at https://www.globalsign.com/en/blog/what-is-server-name-indication among many others.

### MQ SNI usage

MQ by default populates the SNI field with an encoded form of the channel name rather than using 
the hostname, and uses the channel name to choose between multiple server-side certificates: without
the SNI information, there would be no way to choose which certificate to present to the incoming
client. 

The encoded form of a channel such as `MQ.CLIENT.SVRCONN` is `mq2e-client2e-svrconn.chl.mq.ibm.com`
(see [mq-client-svrconn-route](/openshift/mq-client-svrconn-route.yaml)) because the SNI data must 
follow hostname rules (so no "." characters in the channel name, etc) and the channel names must be
transformed according to the rules described at https://www.ibm.com/docs/en/ibm-mq/9.4.x?topic=requirements-how-mq-provides-multiple-certificates-capability

In practice, this looks as follows:

![mq-tls-sni-light](/pictures/mq-tls-sni-light.png#gh-light-mode-only)![mq-tls-sni-dark](/pictures/mq-tls-sni-dark.png#gh-dark-mode-only)

Modern MQ clients can use the hostname SNI Route if they have been told to do so in `mqclient.ini`
or elsewhere, while older clients may need to use the MQ encoded channel name Route. Note that the
encoded channel names must be unique, so if two queue managers running in CP4i both have a channel
named "DEFAULT.SVRCONN" then it is not possible to have both channels exposed to clients via Routes.