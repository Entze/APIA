BEGIN {
    RS=ORS="\n\n"
    FS=OFS="\n"

    answer_count = 0
    optimal_answer_count = 0
}

/^Grounding:/ {
    print $0
}

/^Answer: [0-9]+ \(Optimal: False\)/ {
    last_answer = $0
    answer_count++
    print $0 > (temp_dir "/answer_" answer_count)
    close(temp_dir "/answer_" answer_count)
}

/^Answer: [0-9]+ \(Optimal: True\)/ {
    last_answer = $0
    optimal_answer_count++
    print $0 > (temp_dir "/optimal_answer_" optimal_answer_count)
    close(temp_dir "/optimal_answer_" optimal_answer_count)
}

/^Summary:/ {
    print last_answer
    print $0
}
