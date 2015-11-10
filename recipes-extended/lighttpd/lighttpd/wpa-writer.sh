#! /bin/bash

if [ "$REQUEST_METHOD" = "POST" ]; then
    read params

    essidParam=${params%&*}
    passwordParam=${params#*&}
    
    essid=${essidParam#essid=}

    ENCRYPTED_PRIORITY=5
    NOT_ENCRYPTED_PRIPROTY=3

    if [ "$passwordParam" != "$essidParam" ]; then
        password=${passwordParam#password=}
        
        INCORRECT_PASSWORD_ERR="Passphrase must be 8..63 characters"
        passphraseRes=$(wpa_passphrase "$essid" "$password")
        if [ "$?" != "0" ]; then
            if [ "$passphraseRes" = "$INCORRECT_PASSWORD_ERR" ]; then
                echo $'HTTP/1.1 422 Unprocessable Entity\r\n'
            else
                echo $'HTTP/1.1 500 Internal Server Error\r\n'
            fi
        else
            passphraseRes=$(echo -e "$passphraseRes" | grep -v ^$'\t\#') 
            networkStr="${passphraseRes::-2}"
            networkStr=$(printf "$networkStr\n\tpriority=%d\n}" $ENCRYPTED_PRIORITY)
            $(echo -e "$networkStr" >> /etc/wpa_supplicant.conf)
            if [ "$?" = "0" ]; then
                sync
                echo "OK"
            else
                echo $'HTTP/1.1 500 Internal Server Error\r\n'
            fi
        fi
    else
        networkStr=$(printf "network={\n\tssid=\"%s\"\n\tkey_mgmt=NONE\n\tpriority=%d\n}" $essid $NOT_ENCRYPTED_PRIPROTY)
        $(echo -e "$networkStr" >> /etc/wpa_supplicant.conf)
        if [ "$?" = "0" ]; then
            sync
            echo "OK"
        else
            echo $'HTTP/1.1 500 Internal Server Error\r\n'
        fi
    fi
fi