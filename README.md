# ace-mq-tls-examples
ACE with MQ and TLS in various form factors

## Overview

![ace-mq-switch-tunnel-light](/pictures/ace-mq-switch-tunnel-light.png#gh-light-mode-only)![ace-mq-switch-tunnel-dark](/pictures/ace-mq-switch-tunnel-dark.png#gh-dark-mode-only)


## Notes
Using `-legacy` on openssl pkcs12 due to compatibility issues with older MQ versions.

MQ KDB fileswork as expected with 
```
BrokerRegistry:
  mqKeyRepository: '/home/tdolby/github.com/ace-mq-tls-examples/generated-output/ace-kdb/aceclient'
```

MQ p12 files work with ACE as long as MQKEYRPWD is set before startup:
```
MQKEYRPWD=changeit IntegrationServer -w ~/tmp/ace-mq-tls-examples-work-dir
```
works with server.conf.yaml of 
```
BrokerRegistry:
  mqKeyRepository: '/home/tdolby/github.com/ace-mq-tls-examples/generated-output/ace-p12/aceclient-plus-CA2.p12'
```
and setting the env var in server.conf.yaml also works:
```
EnvironmentVariables:
  MQKEYRPWD: 'changeit'
```

Remote default via the switch requires
```
ResourceManagers:
  MQConnectionManager:
    delayInitialMQConnection: true
```

For IWHI:
 - tdolby-mq-via-switch PNA with [switchclient-cloud.json](/switchclient-cloud.json) contents
 - tdolby-mq-via-switch.p12 created from `generated-output/ace-p12/aceclient-plus-CA1.p12`
 - tdolby-mq-via-switch-policy created from [DefaultPolicies](/DefaultPolicies)
 - tdolby-mq-via-switch-scy containing
```
BrokerRegistry:
  mqKeyRepository: '/home/aceuser/keystores/tdolby-mq-via-switch.p12'
EnvironmentVariables:
  MQKEYRPWD: 'changeit'
```

https://www.ibm.com/docs/en/ibm-mq/9.4.x?topic=variables-environment-descriptions#q082720___MQSSLKEYR

https://www.ibm.com/docs/en/ibm-mq/9.3.x?topic=mq-mqcsp-password-protection


## Notes on what can go wrong:


def chl('ACE.SVRCONN') CHLTYPE(SVRCONN) SSLCAUTH(OPTIONAL) SSLCIPH('ANY_TLS13_OR_HIGHER') MCAUSER('mqm')
     4 : def chl('ACE.SVRCONN') CHLTYPE(SVRCONN) SSLCAUTH(OPTIONAL) SSLCIPH('ANY_TLS13_OR_HIGHER') MCAUSER('mqm')
8/29/2025 19:53:27 Unable to access the configuration data.
Unable to access the configuration data.
AMQ8242E: SSLCIPH definition wrong.

Happened because admin privileges were needed




delete chl('ACE.SVRCONN')
def chl('ACE.SVRCONN') CHLTYPE(SVRCONN) SSLCAUTH(REQUIRED) SSLCIPH('ANY_TLS13_OR_HIGHER') MCAUSER('MUSR_MQADMIN') CERTLABL('CN=mqserver,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US') SSLPEER('CN=aceclient,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US')

delete chl('ACE.SVRCONN')
def chl('ACE.SVRCONN') CHLTYPE(SVRCONN) SSLCAUTH(OPTIONAL) SSLCIPH('ANY_TLS13_OR_HIGHER') MCAUSER('MUSR_MQADMIN') CERTLABL('CN=mqserver,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US') 



DISPLAY CHLAUTH('ACE.SVRCONN') MATCH(RUNCHECK) ALL CLNTUSER('tdolby') ADDRESS(10.0.0.3)

SET CHLAUTH('ACE.SVRCONN') TYPE(SSLPEERMAP) SSLPEER('CN=aceclient,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US') MCAUSER('MUSR_MQADMIN') CHCKCLNT(ASQMGR) DESCRIPTION('Allow ACE.SVRCONN with mTLS for testing')

SET CHLAUTH('*') TYPE(BLOCKUSER) ACTION(REPLACE) DESCR('Rule to disallow privileged - switched to WARN for testing') USERLIST('*MQADMIN') WARN(YES)



tdolby@IBM-7NGKB54:~/github.com/perf-harness$ MQCCDTURL=file:/home/tdolby/github.com/ace-mq-tls-examples/test-ccdt.json /opt/mqm/samp/bin/amqsgetc SYSTEM.DEFAULT.LOCAL.QUEUE ACEv13_QM
Sample AMQSGET0 start
MQCONNX ended with reason code 2381
tdolby@IBM-7NGKB54:~/github.com/perf-harness$ mqrc 2381

      2381  0x0000094d  MQRC_KEY_REPOSITORY_ERROR




