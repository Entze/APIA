BEGIN {
    RS=", ASPSubprogramInstantiation"
    ORS="\n    ASPSubprogramInstantiation"
}

{
    $1 = $1
    print $0
}
