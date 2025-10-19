BEGIN {
  split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", n)
  for(i in n) {
    m[n[i]] = substr(0i, length(i))
  }
}
{
  i=$6 "-" m[$2] "-" substr(0$3,length($3))
  a[i] = a[i] " " $4
}
END {
  for(i in a)
    printf "%s:%-27.27s ...%36.36s\n", i, a[i], substr(a[i], length(a[i]) - 35)
}
