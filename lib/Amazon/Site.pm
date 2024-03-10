use Feature::Compat::Class;

class Amazon::Site {
  field $code :param;
  field $country :param;
  field $domain :param;
  field $currency :param;
  field $sort :param;

  method code     { return $code }
  method country  { return $country }
  method domain   { return $domain }
  method currency { return $currency }
  method sort     { return $sort }
}
