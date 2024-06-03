#!/bin/bash
# fakemurk.sh v1
# by coolelectronics with help from r58

# sets up all required scripts for spoofing os verification in devmode
# this script bundles crossystem.sh and vpd.sh

# crossystem.sh v3.0.0
# made by r58Playz and stackoverflow
# emulates crossystem but with static values to trick chromeos and google
# version history:
# v3.0.0 - implemented mutable crossystem values
# v2.0.0 - implemented all functionality
# v1.1.1 - hotfix for stupid crossystem
# v1.1.0 - implemented <var>?<value> functionality (searches for value in var)
# v1.0.0 - basic functionality implemented
ascii_info() {
    cat <<-EOF
 ________ ________  ___  __    _______   _____ ______   ___  ___  ________  ___  __
|\\  _____\\\\   __  \\|\\  \\|\\  \\ |\\  ___ \\ |\\   _ \\  _   \\|\\  \\|\\  \\|\\   __  \\|\\  \\|\\  \\
\\ \\  \\__/\\ \\  \\|\\  \\ \\  \\/  /|\\ \\   __/|\\ \\  \\\\\\__\\ \\  \\ \\  \\\\\\  \\ \\  \\|\\  \\ \\  \\/  /|_
 \\ \\   __\\\\ \\   __  \\ \\   ___  \\ \\  \\_|/_\\ \\  \\\\|__| \\  \\ \\  \\\\\\  \\ \\   _  _\\ \\   ___  \\
  \\ \\  \\_| \\ \\  \\ \\  \\ \\  \\\\ \\  \\ \\  \\_|\\ \\ \\  \\    \\ \\  \\ \\  \\\\\\  \\ \\  \\\\  \\\\ \\  \\\\ \\  \\
   \\ \\__\\   \\ \\__\\ \\__\\ \\__\\\\ \\__\\ \\_______\\ \\__\\    \\ \\__\\ \\_______\\ \\__\\\\ _\\\\ \\__\\\\ \\__\\
    \\|__|    \\|__|\\|__|\\|__| \\|__|\\|_______|\\|__|     \\|__|\\|_______|\\|__|\\|__|\\|__| \\|__|

THIS IS FREE SOFTWARE! if you paid for this, you have been scammed and should demand your money back

fakemurk - a tool made by Mercury Workshop to spoof verified boot while enrolled
you can find this script, its explanation, and documentation here: https://github.com/MercuryWorkshop/fakemurk
EOF

    # spaces get mangled by makefile, so this must be separate
}
nullify_bin() {
    cat <<-EOF >$1
#!/bin/bash
exit
EOF
    chmod 777 $1
    # shebangs crash makefile
}











. /usr/share/misc/chromeos-common.sh || :



traps() {
    set -e
    trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
    trap 'echo "\"${last_command}\" command failed with exit code $?. THIS IS A BUG, REPORT IT HERE https://github.com/MercuryWorkshop/fakemurk"' EXIT
}
leave() {
    trap - EXIT
    echo "exiting successfully"
    exit
}
config() {
    swallow_stdin

    swallow_stdin
    echo
    read -r -p "Would you like to enable rootfs restore? It will add an option to quickly revert all changes and re-enroll. (Y/n)" choice
    case "$choice" in
    N | n | no | No | NO) ROOTFS_BACKUP=0 ;;
    *) ROOTFS_BACKUP=1 ;;
    esac

    if [ "$DEVBUILD" == "1" ]; then
        devbuild_config
    fi
}

swallow_stdin() {
    while read -t 0 notused; do
        read input
    done
}

fakemurk_info() {
    ascii_info
    sleep 3
    cat <<-EOF

WARNING: THIS SCRIPT WILL REQUIRE THE REMOVAL OF ROOTFS VERIFICATION, AND THE DISABLING OF AUTOUPDATES
THIS MEANS THAT IF YOU EVER TURN OFF DEVMODE, YOUR SYSTEM WILL BE BRICKED UNTIL RECOVERY

WE ARE NOT RESPONSIBLE FOR DAMAGE, YOU BEING STUPID AND MISUSING THIS, OR GETTING IN TROUBLE
DO YOU UNDERSTAND??

(enter to proceed, ctrl+c to quit)
EOF
    swallow_stdin
    read -r
}

csys() {
    if [ "$COMPAT" == "1" ]; then
        crossystem "$@"
    elif test -f "$ROOT/usr/bin/crossystem.old"; then
        "$ROOT/usr/bin/crossystem.old" "$@"
    else
        "$ROOT/usr/bin/crossystem" "$@"
    fi
}
cvpd() {
    if [ "$COMPAT" == "1" ]; then
        vpd "$@"
    elif test -f "$ROOT/usr/sbin/vpd.old"; then
        "$ROOT/usr/sbin/vpd.old" "$@"
    else
        "$ROOT/usr/sbin/vpd" "$@"
    fi
}

sed_escape() {
    echo -n "$1" | while read -n1 ch; do
        if [[ "$ch" == "" ]]; then
            echo -n "\n"
            # dumbass shellcheck not expanding is the entire point
        fi
        echo -n "\\x$(printf %x \'"$ch")"
    done
}

raw_crossystem_sh() {
    base64 -d <<-EOF | bunzip2 -dc
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
bzVPfi2mxFTkn/F3JFOFCQFdrstw
EOF
}

raw_pollen() {
    base64 -d <<-EOF | bunzip2 -dc
QlpoOTFBWSZTWYyTe/4ABQZfgAAyUARoED/3/6q/79/qUAQe44nJ2UutN2rgkk0owCbSNNT0JqfkRNqABkBoNCYjQonlGag0AAAA
DQCU0IIUyn6aU8SPSGh6gADJ6nqNBgAAAANAAAAAAkUFPTJJtA0UND9UPU/STagBoaNqNCQQSSCYhB5M69NKEg6Q/XWJ4w8X9iJO
ZP4mtkc7uwkmKkQUL1pcmj/rpaJu7YJi6OaZtGGYNpv1HUJMl9+DtLyQMcEOyYRA46UO4hJutM6EVRRNYCrDMHGDXDaERnz9S0nN
Pd8jqyI/Rh8bYYPmMZKFlFKLejHKfFhIGZG0WnuOHMgX6ZzE3JFDGUAzWexOGxmC+8HFgFFrna9VYS9H2TEMkgjSLyEhUMjBHd1F
63d5a5QDVpirOPuUNnXOJfPbM5thAod1s6ERqNKuZMsZq6qU1xBuqIjUpMlpe+k/3VSDtoGWMi4nQp4HOzabEITcjJUt+V6U2jTo
lRtsTRUj/I80Wvs+ZcXLHMqJiWJLd9fYiq4Rs2+ZYVYc2GWjJHcrcRjmYDdWcdp8IAfM2djYlzCjpkmaqGB8CjohmSibzEyVoT7D
fTXlHKDamEkkmSZux703+WPPdWwxmFxKlCOM6sbV2f7x8GX3mEMiqGJtDbYZjMIw0eAjoXw90KC8Mu9wswOTJ/SBnqjQ1D20Q1+G
srOM9c8pRiQmg793jknap58QWXhvh5IxEdFaGhxQXMEULnImOQbOJ2FSO7Y4ZzOJdtZo9gX8FOG+GQf6isXrSk6KFZnMg62w3MKX
CpyKYZjQuUxnMK+IfrtfsipzFiuCN4MNlqEI2JuC6d+I2EWeDIGm40MO3kOaqAi8fcIV2sK80RhbUIWwIuqKiFTaKfh9cZtCEoHe
gu7SJLBNZlMwg5yLOQaggZ4rSpseqoBZrFbg7Il9IO93hBMCV0swEZbg3rlC+Cgjn5ESc4xd0aWcHzz1jF9rJUlMCc94wevuw1aD
OLCwxnmn0JSWo7aQDv8tcjWMSLM2hRegxMFnw9vXv9xvK3FDIZYJOLUWwbOMaESCcyeQkMVXq05FVxiJx5kGLQUaRQaiXUDoIOgQ
rAYgIg6tkLgco7YHgQWjrjknV5nguVq4q28MKVQ5G/Ljz1xmEJWVkSXpJ1UybXDSiiNK9Tg4Na3iCHsiaNqMTHCTzBbGIMMicS+5
glNZsMUk7pXkyYwzBFAWFisaqNseXnymCOuvaAjlpEeLfavcb47n1YW6jqrzacolSHlAEqWOyTQUoljOyy7UWmDHqf8XckU4UJCM
k3v+
EOF
}
drop_daemon() {
    base64 -d <<-EOF | bunzip2 -dc >"$ROOT/etc/init/pre-startup.conf"
QlpoOTFBWSZTWWmlwXUAAGJfgEAQeef/EX8nngR//9/gQAKdbYrYtsYanqaCmRimZJ7RJkeppptQ00Ym1GCNBoINTJkmKaeoDQAN
BoAANDmATACYAATAAEwABKaJNGU00T1J6eRT1MgAA0HqHpkIdov/PF7fg3KjSXLn+Dl020t4UH6OetghpBz1bn0mpeOClP2ECSv4
bboqtBOEIUWtYzlhj/eD+pEv6aHsmMDXO205PMGrfU08JvysM5Sisk2YBfQ2pF7giWGqp/O35utse0hCSVO96uqalInhe8UK3PhP
I6wZH2ocY7+2sdVeNbxao6ha84UAux1Y+sGa6KRCQZZGl8wSBWAupak2W2fOxytzcunc6e7PgjPhOnI8SPf80oE9efFg5lTvJd9f
RjMxqKYprmACcjPZo8dYp6ShBqiJJVvVetUm1bGRppc0fHtgNGBwPrIxUz5eMEnc2eFkca+FXCqmYrNYJRdbv5RT5g2QDFPTLkpp
CYnQg0VFC5rXbw1f0yJZW8yGlyyoF41iNo+e91Blnwaj8bopXNesDhMxiZleIacrRkDo25nJFtdrmEjreefSPlU9bglCZ01lh7rY
x05t6A35ReGYqeTSZlQezJJI37erc2pp9FDAIbZj1NnicIkmsm5b2dn8jdZfSm9GkdaCNCIkzyWwEOQSqnsJTRHoodRHhXpIRD1B
oT3mYYhdjrsCVapaaugrAHPosoV6d9d4Qv9rIS1AiDHyUHK+AQ2Faq76swwTDIR3SZMjXc8ObZVad1k9cwgrQuNbWybQ2U81ekCw
xda00lEQkJDI3OlrnjnjQcyRKSChYIBQ3XCd+YT1o+uY8HueHFZY2BuKYIXBnQpWCGQtDT2NxLizwJTPQGZTDZBwigpqvJGQH2qE
iQtKlNDWlWrYTXUY/xdyRThQkGmlwXU=
EOF
    base64 -d <<-EOF | bunzip2 -dc >"$ROOT/sbin/fakemurk-daemon.sh"
QlpoOTFBWSZTWVb0qdkAAQP/gERUQAB9Z/s/LiPfjr/v3/pAAvO2mm623bAJKFPTSNJjTTSY0IAYJpo00DQBkaAkkIyaTEaGJNTZ
EwQANBoDTQD0gkSVPaoaPU9I9IHommQAAZAAAACSkMU0aEZMJgQADARp6Am0IBSAL3ZjsYy+ny4KsiP+2w7ZD6H4N31aqvw/XbPj
qcURJP7n5okaXv6a5QqpjDyZ9VF4SLYISUWSQBBCS7SXjucRSBTb4H8VxOolYdxkkKBUITujcE4OeBRVfWstrjRQVL4y2+sUS02M
2aBS0pid9Jrp46sYoRxxoyY8BjxtyLG9GU5FLMwG/frHocwtgNPy2+tl1SrNNl0uKsPbONbG0TWBlOEv7ssNMzpDjfOi5eeFr7rx
DNyNNcKefUYFA1dQNcwT8o1XSOxKij6ssUMsjMMCw184ywhgtqHkqIaBq2jAYV3rUjeiYaiZDpkblGh58lRGZfHu5QQ9MRXHIsFp
Zqcq2JRH9GFrguOCqW1tMmJYDJyN4O8OxRA+At411jXJokHIhSMT2B+WTUFVSLg3c1bH9kcHCuqUMna0o0Djb5517+avMPow0k87
UUDzSlFI7QvrrPuCnPVyyGzVLrto05kOUkah7dccbcRy4yfbmcyTBTQ6EpIiLVQdzWlOxLgK+bcIExKETqdlK+VRjGMWG8iZXS1Z
lCspbhRhwTkyJhYERIaU1VKV+eEVwvV1uuIndRbvK1GGzIonnAxMcWde3CcQ3Xpgeln33UUXpM3HyBpi0caEamvSnJ4wGNjtvL10
1sdduXyEI21ajg6B7RRPUArxBSTEsoioJC1yScTbC+DKJPMRYLWFY3VSzLHJYIYUhYkSFB0Ic+NE6htmnr0AV6GgjWXnRPBvEqgI
lfEzssaB3Ly5kXNRdt1YY0JTDOKUFheP3VbLM1htImbbWczBM5PCMx4b7GwDLivsGmBAch6HsDu8fCLJaHsjWWhA0q8dhtcjKxoi
5wrRANHUxyosK9PRE0IjvBxiQunWZHTUpGcMdx91I7LJvgnu/4u5IpwoSCt6VOyA
EOF
    chmod 777 "$ROOT/sbin/fakemurk-daemon.sh"
}
drop_startup_patch() {
    move_bin "$ROOT/sbin/chromeos_startup.sh"
    base64 -d <<-EOF | bunzip2 -dc >"$ROOT/sbin/chromeos_startup.sh"
QlpoOTFBWSZTWczrjJIAALp/gEAQQAB/5/3PJ+/fir/v//5QA4MqPNAFANCTQyjap6NTE0bSaeo00yaMTRhDNTTJ6mmgHDTTIxGE
0wEMAmmEYJiZDTI0NANTJkJpoUZ6pp6J6gANAAAAAA0HDTTIxGE0wEMAmmEYJiZDTI0NAJFAjQTTQ0TNJpNQAGRoADQNAyaKIEJ+
FA1/Bz+yRthI4IT2TyvxieVmB5xrgW04jXBBNtdPVhb7pM5RhRRW7gsERETxAhqF1wH23NoqRQ7jSzcCfNFZMt6GKOinUQKdR0PW
ncr7ypUM8MrJC11o6Fv39Nlk82um4gsT8juFBlttUk0MG+i3yF28mfNa4UOCrU7ErK8SK5Im6w8jRGRLVhjB6obvqtLOV8BeBRIy
sqNOpgbJH1X0e6IaF1TviJ+03G5HyGAvAyzKyIl8/GSW83ECZB5mKpgC4DJlTbknTan2rkxuxtUF2jukQK5mosSQTkZEKAwmWyBh
pgoDDTC406a+rVHI+K2K3piyBggJ5/Cak3kGKHcGJrMe2xcmjTdVY/XKu784mY5/0qX9qNTdUkDN7qUK1lCdIjNe8BUaNj4PLBDh
nuzCqY7Uyn2CuOSABYRpQ5WBgGYg1WOw8uJ5XGblhC+4UF6/TWt1bESqEiXn2XIeQ3PHhNQUoe1Ew2/jcv0slYau0MCwg14RLJu+
NbrQyfo26QWxGIRuIzaDBBIMzaW0x5p0towNzFfMu+1Ba97XpE7yZFeadzNnTffbkOM8Z+m6CKQuiWIsRaa7FabJjkdd/32W27iF
FLPE/jFHqYD7JdkdBmvUNlUdCR3u5RCInaWtwDstxX1RouC1TBc27oChGEEdggRiMBs70Z635ozJn+ThcVi3Nd6L6PpPhQsDyYa+
JOxp9YKwoZne4BOBoiZ0DgM2KipzqYMYdmvRz6mTfGcVKyzq8VrZft3Z30Me19M6cabMjg8vCahF8QrKuKRSFsM4RJSgmxm6EyZK
LUQcAjCipKyFI1tt3XBnuLg9eeJtFviunKeVrXOMk6Lk0xjh4rDrk/PZxH9HcHBg2GtSe3bx4584j9jDTn14bNNSdZYXMmMoIslk
zLsgxHC6AqkCcsIQiwUGk7RYAIwoiRtilCG/SRp3bZ5TIyZV+EIOsqqG/FUw63q/Q0G0FjFGim8ILhGghpl5OOh2hBDJrTIjxdhh
XBnJ5xzjlnwnWhRY+87+VITaSbcrERMRF8IRqzCto5kt5Z8d1kbRQ/7b5Indva9g0TVa1wtx5HdG8T1ROhec14+bkuNMtKk2hiOh
LbGbCbDM6V+ufm/8XckU4UJDM64ySA==
EOF
    chmod 777 "$ROOT/sbin/chromeos_startup.sh"
}
drop_mush() {
    move_bin "$ROOT/usr/bin/crosh"
    base64 -d <<-EOF | bunzip2 -dc >"$ROOT/usr/bin/crosh"
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
4g7QcvxD4dFopC5/3L26LuSKcKEgSW7lfg==
EOF
    chmod 777 "$ROOT/usr/bin/crosh"
}
drop_ssd_util(){
    base64 -d <<-EOF | bunzip2 -dc >"$ROOT/usr/share/vboot/bin/ssd_util.sh"
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
L7w/8XckU4UJDZ1hDfA=
EOF
    chmod 777 "$ROOT/usr/share/vboot/bin/ssd_util.sh"
}
drop_cr50_update(){
    base64 -d <<-EOF | bunzip2 -dc >"$ROOT/etc/init/cr50-update.conf"
QlpoOTFBWSZTWaMpNEAAAJNfgCEQWOdzEH4lnoA/7//gUANMJ4AJKYaaU9EnpkBTwpkyGg2o0yNGhoMAANAAGTQAABoBqYIAKm00
gGgAA0Mg0MAANAAGTQAABoBKaEBTINJpPQowA0EehB6JhJ7/rnUgLCBDZ+XLlvYOGhZv77lGkimoJF7LwojE54XgoQM9pbF1oDdT
RPJAa7ZZ0gIBoE2Ikz+VAZQFnyQhcslexGedapAXzKW5R4FJTAOBicrXVyYQdah5DAiyAcJbCGVWbSbCsdxWZnnhAjYYGSCiJN4D
TN1ybVhMlGl96LKM+OU7RmSSuqJG6lQ0qxNYFO1MlURHTQz7LljlNSzRjXo17NYQJLUDziIzWlxyFbBd99UHHvsxPgzoUS3ISnnu
3OdiEdp6MOGajaOC8SmZrTeR/flDN90N6Kser/ZIXrIeW7qxG3jHiwhFfBj4oLYq5BgMKkOm99PfZjVGUBoj/vP+OMar9ILWY7/8
zH41cZARZDbI3DuPo5WOY26Z5L2KqJLeabmeI+0SjoJrrVTNQ6duDF7pFOVsJYdFDNPZQvnKczqsVMmM9Y3byu92qaotS3lXJy5m
/Oo99JyX5UN/JYCwlwpxma5yQh6YcjcH37OiQl7nNaDAmKrmwtFbwVSdeCIHF/7iECTEdo7Qg5KfchW48+qCuQ4H2YjRpYdcUaLp
JyXaqLOWZ9NjQDJdCb0joWu/UOydpbjL574fp9UF0FqIgsPV+L0F34cuxR7F7UVEFZCGZ4Ca1jrMEUUD0ixMSk8lqBEJIKlJFVqS
8Dol9tkl+CpqqlZBBIHBpjAgVOAJJD57oUdijTPlTPA7NrqO11tosV9FJttbXcMQMblCL12ZOAgiOrIKFjObwjw0lHGdDttYwJ3p
juwzXnOGZW4b2N1aFbDEjQErbV3W1nSJTjxrMwmu/p7h6cE+dx3Jiefm/Bhe8iumYWYKHuk5hJy8SiVGgscBcL401EuBkvCbSb7Q
USgrwuN4oJTYGwJxaLQZvjwdtTW72sRoa2ZuoiWo1b7jT9F3iQxckQdTIEM7eB81d77IGRIgEkHOKLbyAb0J03NqkhpobF/8XckU
4UJCjKTRAA==
EOF
}



drop_crossystem_sh() {

    # this weird space replacement is used because "read" has odd behaviour with spaces and newlines
    # i don't need to worry about the jank because crossystem will never have user controlled data

    vals=$(sed "s/ /THIS_IS_A_SPACE_DUMBASS/g" <<<"$(crossystem_values)")
    raw_crossystem_sh | sed -e "s/#__SED_REPLACEME_CROSSYSTEM_VALUES#/$(sed_escape "$vals")/g" | sed -e "s/THIS_IS_A_SPACE_DUMBASS/ /g" >"$ROOT/usr/bin/crossystem"
    chmod 777 "$ROOT/usr/bin/crossystem"
}
drop_pollen() {
    mkdir -p "$ROOT/etc/opt/chrome/policies/managed"
    raw_pollen >$ROOT/etc/opt/chrome/policies/managed/policy.json
    chmod 777 "$ROOT/etc/opt/chrome/policies/managed/policy.json"

}

escape() {
    case $1 in
    '' | *[!0-9]*) echo -n "\"$1\"" ;;
    *) echo -n "$1" ;;
    esac
}

crossystem_values() {
    readarray -t csys_lines <<<"$(csys)"
    for element in "${csys_lines[@]}"; do
        line_stripped=$(echo "$element" | sed -e "s/#.*//g" | sed -e 's/ .*=/=/g')
        # sed 1: cuts out all chars after the #
        # sed 2: cuts out all spaces before =
        IFS='=' read -r -a pair <<<"$line_stripped"

        key=${pair[0]}
        # cut out all characters after an instance of 2 spaces in a row
        val="$(echo ${pair[1]} | sed -e 's/  .*//g')"
        if [ "$key" == "devsw_cur" ]; then
            val=0
        fi
        if [ "$key" == "devsw_boot" ]; then
            val=0
        fi
        if [ "$key" == "mainfw_type" ]; then
            val="normal"
        fi
        if [ "$key" == "mainfw_act" ]; then
            val="A"
        fi
        if [ "$key" == "cros_debug" ]; then
            val=1
        fi
        if [ "$key" == "dev_boot_legacy" ]; then
            val=0
        fi
        if [ "$key" == "dev_boot_signed_only" ]; then
            val=0
        fi
        if [ "$key" == "dev_boot_usb" ]; then
            val=0
        fi
        if [ "$key" == "dev_default_boot" ]; then
            val="disk"
        fi
        if [ "$key" == "dev_enable_udc" ]; then
            val=0
        fi
        if [ "$key" == "alt_os_enabled" ]; then
            val=0
        fi
        if [ "$key" == "recoverysw_boot" ]; then
            val=0
        fi
        if [ "$key" == "recoverysw_cur" ]; then
            val=0
        fi
        echo "$key=$(escape "$val")"
    done
}
move_bin() {
    if test -f "$1"; then
        mv "$1" "$1.old"
    fi
}

disable_autoupdates() {
    # thanks phene i guess?
    # this is an intentionally broken url so it 404s, but doesn't trip up network logging
    sed -i "$ROOT/etc/lsb-release" -e "s/CHROMEOS_AUSERVER=.*/CHROMEOS_AUSERVER=$(sed_escape "https://updates.gooole.com/update")/"

    # we don't want to take ANY chances
    move_bin "$ROOT/usr/sbin/chromeos-firmwareupdate"
    nullify_bin "$ROOT/usr/sbin/chromeos-firmwareupdate"

    # bye bye trollers! (trollers being cros devs)
    rm -rf "$ROOT/opt/google/cr50/firmware/" || :
}


drop_image_patcher(){
    base64 -d <<-EOF | bunzip2 -dc >"$ROOT/sbin/image_patcher.sh"
QlpoOTFBWSZTWWjFvgAABk5fgHxQfv////////6////+YJZfAfOud753AAAAPV183xl4+D3t0Ivr16+dxT7x7vr7vM60zuY6Vo6u
zXXW2adOrM1e3c7vXt5d06lTdtrDQ7tFW2usCdm23e+MR766+k2C+rm97XOzp0GPZvdcveHWdudsyfO+XfR6fdbSqJVTe4677uTe
857rF6123nOcutR2dVIB1dtS3dxutdsrWVtMrd2ec3l53Ls973eOZ91bqg2ZGXu6uwc2fTvY9fXffbvrbHRt3Zt9cq0e7s66217u
tup1HdagVrS7G+2q9b3u9Bzzd2ypsa3bcddEhdtt3wDvr30fW+8lFxye7T77VLnoPvdOniTOnrvIvbL3W9p45AE13m16967zuV67
q2W9zve3V7x220++y9vn3IJ3oei2jKfcz2fe+896+73fXefKM9vPR99ntlpFzjVzM3T56++76rr4D1O+8N559rO+3wB1t8nXWbim
5ubn1p4b2KRwe4O9CrvaO3bw9r6B3U0j0077759867a3uoR9n0HpbvbvO+we7O+FUwAAEYEwTCYmTJo0wAhCESh6g0DQ0DKn4AAA
AAAAACYIRJVAGAAhpgZVVP/8AAAAAABTwU8AKb1ElBQyANANAMp4AAAACYAmBMAJk0kqn6UAAMRhAZVT/wBk00AmJiNMRpkyTyZM
EyCTVPUaNpqaNBgEGiEAATQ0AAAAAABAhNAk8AmJqXv49AQbIhKVI0BYzMgQDpkREkyIEgxzX9lwakISSAZoXMiURISgECC5giMg
P9umI9H/kfT8/omD8P5uq6JQrJqg/1/6QkPzME1Cx/19EbiBHrDP4pAosEFG+hH/D0GF1gFjCZEk8f6mybAQc0Vf+vKbYAfBk4Y/
QwoQuI/UyfWzG3/CymkJUhqL1cUo0LGcrWTqoPmb2+E0UUEgzMlABBgQPGwf9oWMEVFYJBomSsQrDjdqsMBqCCRpMCymZibq9xZl
9K4ZVgoOpkfmpbf/n/0cS0bjPf9R9F7/v5+19zJ9YP6W/P9Kv3RY11V//ftS/v71lmctv6e32/ep+/VTav+b3Dem8eT/g419X8fy
+ur1Q6GX1A3sc2A1fKh3fJH+bnu5iJSnj8fjOmP/yDXPp+6cTABF83/4+BalkbbIJ21I/k237B+zXoDBPuIH/f42CAX0Fpg8WXoV
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
AFwFwRfsYIsYQHRWT/+LuSKcKEg0Yt8AAA==
EOF
    chmod 777 "$ROOT/sbin/image_patcher.sh"
}
is_target_booted() {
    [ -z "$COMPAT" ] && [ "$(get_booted_kernnum)" == "$TGT_KERNNUM" ]
}
opposite_num() {
    if [ "$1" == "2" ]; then
        echo -n 4
    elif [ "$1" == "4" ]; then
        echo -n 2
    elif [ "$1" == "3" ]; then
        echo -n 5
    elif [ "$1" == "5" ]; then
        echo -n 3
    else
        return 1
    fi
}



prepare_target_root() {
    sleep 2
    if verity_enabled_for_n "$TGT_KERNNUM"; then
        echo "removing rootfs verification on target kernel $TGT_KERN_DEV"
        /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --partitions "$TGT_KERNNUM" -i "$DST" 2>/dev/null
        if is_target_booted; then
            # if we're booted from the target kernel, we need to reboot. this is a pretty rare circumstance

            cat <<-EOF
ROOTFS VERIFICATION SUCCESSFULLY REMOVED
IN ORDER TO PROCCEED, THE CHROMEBOOK MUST BE REBOOTED

PRESS ENTER TO REBOOT, THEN ONCE BOOTED RUN THIS SCRIPT AGAIN
EOF
            swallow_stdin
            read -r
            reboot
            leave
        fi
    fi

    if ! is_target_booted; then
        mkdir /tmp/rootmnt
        mount "$TGT_ROOT_DEV" /tmp/rootmnt
        ROOT=/tmp/rootmnt
    else
        ROOT=
    fi
}

get_largest_nvme_namespace() {
    # this function doesn't exist if the version is old enough, so we redefine it
    local largest size tmp_size dev
    size=0
    dev=$(basename "$1")

    for nvme in /sys/block/"${dev%n*}"*; do
        tmp_size=$(cat "${nvme}"/size)
        if [ "${tmp_size}" -gt "${size}" ]; then
            largest="${nvme##*/}"
            size="${tmp_size}"
        fi
    done
    echo "${largest}"
}
verity_enabled_for_n() {
    grep -q "root=/dev/dm" <"${DST}p${1}"
}
get_booted_kernnum() {
    # for some reason priorities can be like 2 and 1 instead of just 0 and 1???
    if (($(cgpt show -n "$DST" -i 2 -P) > $(cgpt show -n "$DST" -i 4 -P))); then
        echo -n 2
    else
        echo -n 4
    fi
}
cleanup() {

    if [ "$COMPAT" == "1" ]; then
        echo "pressure washing..."
        yes | mkfs.ext4 "${DST}p1" >/dev/null 2>&1 || : # hope you didn't have anything valuable on there
    fi

    cvpd -i RW_VPD -s check_enrollment=1 2>/dev/null
    cvpd -i RW_VPD -s block_devmode=0 2>/dev/null
    csys block_devmode=0 2>/dev/null
}

set_kernel_priority() {
    cgpt add "$DST" -i 4 -P 0
    cgpt add "$DST" -i 2 -P 0
    cgpt add "$DST" -i "$TGT_KERNNUM" -P 1
}

configure_target() {

    # remember, the goal here is to end up with one kernel that can be patched, and one kernel for the revert function.
    # we prioritize the non booted kernel so a reboot isn't needed

    DST=/dev/$(get_largest_nvme_namespace)
    if [ "$DST" == "/dev/" ]; then
        DST=/dev/mmcblk0
    fi

    if verity_enabled_for_n 2 && verity_enabled_for_n 4; then
        TGT_KERNNUM=
    elif verity_enabled_for_n 2; then
        TGT_KERNNUM=4
    elif verity_enabled_for_n 4; then
        TGT_KERNNUM=2
    else
        TGT_KERNNUM=
        if [ "$ROOTFS_BACKUP" == "1" ]; then
            echo "Rootfs restore is requested to be enabled, but both partitions have rootfs verification disabled. Please go through the recovery process to enable rootfs verification or run again and do not choose to enable rootfs restore."
            leave
        fi
    fi

    if [ "$TGT_KERNNUM" != "2" ] && [ "$TGT_KERNNUM" != "4" ]; then
        if [ "$COMPAT" == "1" ]; then
            TGT_KERNNUM=2
        else
            TGT_KERNNUM=$(opposite_num "$(get_booted_kernnum)")
        fi
    fi
    TGT_ROOTNUM=$((TGT_KERNNUM + 1))
    TGT_KERN_DEV="${DST}p$TGT_KERNNUM"
    TGT_ROOT_DEV="${DST}p$TGT_ROOTNUM"

    ALT_ROOTNUM=$(opposite_num "$TGT_ROOTNUM")
    ALT_KERNNUM=$(opposite_num "$TGT_KERNNUM")
    ALT_KERN_DEV="${DST}p$ALT_KERNNUM"
    ALT_ROOT_DEV="${DST}p$ALT_ROOTNUM"

    echo "target kern is $TGT_KERNNUM@$TGT_KERN_DEV"
    echo "target root is $TGT_ROOTNUM@$TGT_ROOT_DEV"
    echo
    echo "backup kern is $ALT_KERNNUM@$ALT_KERN_DEV"
    echo "backup root is $ALT_ROOTNUM@$ALT_ROOT_DEV"
}

patch_root() {
    echo "disabling autoupdates"
    disable_autoupdates
    drop_cr50_update
    sleep 2
    echo "dropping crossystem.sh"
    mv "$ROOT/usr/bin/crossystem" "$ROOT/usr/bin/crossystem.old"
    drop_crossystem_sh
    echo "staging sshd"
    sleep 2
    echo "dropping pollen"
    drop_pollen
    sleep 2
    echo "preventing stateful bootloop"
    drop_startup_patch
    if [ "$COMPAT" == "1" ]; then
        touch "$ROOT/stateful_unfucked"
    fi
    echo "installing mush shell"
    drop_mush
    sleep 2
    echo "dropping fakemurk daemon"
    drop_daemon

    echo "preparing ausystem"
    drop_ssd_util
    drop_image_patcher

    if [ "$DEVBUILD" == "1" ]; then
        devbuild_patchroot
    fi
}
main() {
    traps
    fakemurk_info
    config

    if csys mainfw_type?recovery; then
        echo "Entering shim compatability mode"
        COMPAT=1
        stty sane
        sleep 1
    fi

    echo "----- stage 1: grabbing disk configuration -----"
    configure_target

    sleep 2

    echo "----- stage 2: patching target rootfs -----"
    prepare_target_root
    patch_root
    sync

    sleep 2

    echo "----- stage 3: cleaning up -----"
    cleanup
    sleep 1
    echo "setting kernel priority"
    set_kernel_priority

    sleep 1
    echo "done! press enter to reboot, and your chromebook should enroll into management when rebooted, but stay hidden in devmode"
    swallow_stdin
    read -r
    reboot
    leave

}
if [ "$0" = "$BASH_SOURCE" ]; then
    stty sane
    # if [ "$SHELL" != "/bin/bash" ]; then
    #     echo "hey! you ran this with \"sh\" (or some other shell). i would really prefer if you ran it with \"bash\" instead"
    # fi

    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit
    fi
    main
fi
