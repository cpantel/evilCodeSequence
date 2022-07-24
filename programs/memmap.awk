BEGIN {
  state = "searching"
}

/\/\* MEMORY MAP \*\// {
  state = "skipping"
}
/casez \(mem_address\)/ {
  state = "collecting"
}
/default/ {
  state = "finished";
  exit
}	
/.*/ {
  if (state == "collecting" && $7 ) {
    printf "#define %-8s  *((volatile uint64_t *) %s)\n", $6, $7
  }
}

END {}
