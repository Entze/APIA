BEGIN {
    RS="\n"
    FS=") "

    ORS="\n\n"
    OFS=")\n"
}

{
    $1 = $1
    print $0
}
