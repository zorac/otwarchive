# Use css parser to break up style blocks
require 'css_parser'
include CssParser

module CssCleaner

  # constant regexps for css values
  ALPHA_REGEX = Regexp.new('[a-z\-]+')
  UNITS_REGEX = Regexp.new('deg|cm|em|ex|in|mm|pc|pt|px|s|%', Regexp::IGNORECASE)
  NUMBER_REGEX = Regexp.new('-?\.?\d{1,3}\.?\d{0,3}')
  NUMBER_WITH_UNIT_REGEX = Regexp.new("#{NUMBER_REGEX}\s*#{UNITS_REGEX}?\s*,?\s*")
  PAREN_NUMBER_REGEX = Regexp.new('\(\s*' + NUMBER_WITH_UNIT_REGEX.to_s + '+\s*\)')
  PREFIX_REGEX = Regexp.new('moz|ms|o|webkit')

  FUNCTION_NAME_REGEX = Regexp.new('scalex?y?|translatex?y?|skewx?y?|rotatex?y?|matrix', Regexp::IGNORECASE)
  TRANSFORM_FUNCTION_REGEX = Regexp.new("#{FUNCTION_NAME_REGEX}#{PAREN_NUMBER_REGEX}")

  SHAPE_NAME_REGEX = Regexp.new('rect', Regexp::IGNORECASE)
  SHAPE_FUNCTION_REGEX = Regexp.new("#{SHAPE_NAME_REGEX}#{PAREN_NUMBER_REGEX}")

  RGBA_REGEX = Regexp.new('rgba?' + PAREN_NUMBER_REGEX.to_s, Regexp::IGNORECASE)
  COLOR_REGEX = Regexp.new('#[0-9a-f]{3,6}|' + ALPHA_REGEX.to_s + '|' + RGBA_REGEX.to_s)
  COLOR_STOP_FUNCTION_REGEX = Regexp.new('color-stop\s*\(' + NUMBER_WITH_UNIT_REGEX.to_s + '\s*\,?\s*' + COLOR_REGEX.to_s + '\s*\)', Regexp::IGNORECASE)

  # from the ICANN list at http://data.iana.org/TLD/tlds-alpha-by-domain.txt
  TOP_LEVEL_DOMAINS = %w(aaa aarp abarth abb abbott abbvie abc able abogado abudhabi ac academy accenture accountant accountants aco active actor ad adac ads adult ae aeg aero aetna af afamilycompany
    afl africa ag agakhan agency ai aig aigo airbus airforce airtel akdn al alfaromeo alibaba alipay allfinanz allstate ally alsace alstom am americanexpress americanfamily amex amfam amica amsterdam
    analytics android anquan anz ao aol apartments app apple aq aquarelle ar arab aramco archi army arpa art arte as asda asia associates at athleta attorney au auction audi audible audio auspost
    author auto autos avianca aw aws ax axa az azure ba baby baidu banamex bananarepublic band bank bar barcelona barclaycard barclays barefoot bargains baseball basketball bauhaus bayern bb bbc bbt
    bbva bcg bcn bd be beats beauty beer bentley berlin best bestbuy bet bf bg bh bharti bi bible bid bike bing bingo bio biz bj black blackfriday blanco blockbuster blog bloomberg blue bm bms bmw bn
    bnl bnpparibas bo boats boehringer bofa bom bond boo book booking boots bosch bostik boston bot boutique box br bradesco bridgestone broadway broker brother brussels bs bt budapest bugatti build
    builders business buy buzz bv bw by bz bzh ca cab cafe cal call calvinklein cam camera camp cancerresearch canon capetown capital capitalone car caravan cards care career careers cars cartier
    casa case caseih cash casino cat catering catholic cba cbn cbre cbs cc cd ceb center ceo cern cf cfa cfd cg ch chanel channel chase chat cheap chintai chloe christmas chrome chrysler church ci
    cipriani circle cisco citadel citi citic city cityeats ck cl claims cleaning click clinic clinique clothing cloud club clubmed cm cn co coach codes coffee college cologne com comcast commbank
    community company compare computer comsec condos construction consulting contact contractors cooking cookingchannel cool coop corsica country coupon coupons courses cr credit creditcard
    creditunion cricket crown crs cruise cruises csc cu cuisinella cv cw cx cy cymru cyou cz dabur dad dance data date dating datsun day dclk dds de deal dealer deals degree delivery dell deloitte
    delta democrat dental dentist desi design dev dhl diamonds diet digital direct directory discount discover dish diy dj dk dm dnp do docs doctor dodge dog doha domains dot download drive dtv dubai
    duck dunlop duns dupont durban dvag dvr dz earth eat ec eco edeka edu education ee eg email emerck energy engineer engineering enterprises epost epson equipment er ericsson erni es esq estate
    esurance et etisalat eu eurovision eus events everbank exchange expert exposed express extraspace fage fail fairwinds faith family fan fans farm farmers fashion fast fedex feedback ferrari
    ferrero fi fiat fidelity fido film final finance financial fire firestone firmdale fish fishing fit fitness fj fk flickr flights flir florist flowers fly fm fo foo food foodnetwork football ford
    forex forsale forum foundation fox fr free fresenius frl frogans frontdoor frontier ftr fujitsu fujixerox fun fund furniture futbol fyi ga gal gallery gallo gallup game games gap garden gb gbiz
    gd gdn ge gea gent genting george gf gg ggee gh gi gift gifts gives giving gl glade glass gle global globo gm gmail gmbh gmo gmx gn godaddy gold goldpoint golf goo goodhands goodyear goog google
    gop got gov gp gq gr grainger graphics gratis green gripe grocery group gs gt gu guardian gucci guge guide guitars guru gw gy hair hamburg hangout haus hbo hdfc hdfcbank health healthcare help
    helsinki here hermes hgtv hiphop hisamitsu hitachi hiv hk hkt hm hn hockey holdings holiday homedepot homegoods homes homesense honda honeywell horse hospital host hosting hot hoteles hotels
    hotmail house how hr hsbc ht htc hu hughes hyatt hyundai ibm icbc ice icu id ie ieee ifm ikano il im imamat imdb immo immobilien in industries infiniti info ing ink institute insurance insure int
    intel international intuit investments io ipiranga iq ir irish is iselect ismaili ist istanbul it itau itv iveco iwc jaguar java jcb jcp je jeep jetzt jewelry jio jlc jll jm jmp jnj jo jobs
    joburg jot joy jp jpmorgan jprs juegos juniper kaufen kddi ke kerryhotels kerrylogistics kerryproperties kfh kg kh ki kia kim kinder kindle kitchen kiwi km kn koeln komatsu kosher kp kpmg kpn kr
    krd kred kuokgroup kw ky kyoto kz la lacaixa ladbrokes lamborghini lamer lancaster lancia lancome land landrover lanxess lasalle lat latino latrobe law lawyer lb lc lds lease leclerc lefrak legal
    lego lexus lgbt li liaison lidl life lifeinsurance lifestyle lighting like lilly limited limo lincoln linde link lipsy live living lixil lk loan loans locker locus loft lol london lotte lotto
    love lpl lplfinancial lr ls lt ltd ltda lu lundbeck lupin luxe luxury lv ly ma macys madrid maif maison makeup man management mango map market marketing markets marriott marshalls maserati mattel
    mba mc mckinsey md me med media meet melbourne meme memorial men menu meo merckmsd metlife mg mh miami microsoft mil mini mint mit mitsubishi mk ml mlb mls mm mma mn mo mobi mobile mobily moda
    moe moi mom monash money monster mopar mormon mortgage moscow moto motorcycles mov movie movistar mp mq mr ms msd mt mtn mtr mu museum mutual mv mw mx my mz na nab nadex nagoya name nationwide
    natura navy nba nc ne nec net netbank netflix network neustar new newholland news next nextdirect nexus nf nfl ng ngo nhk ni nico nike nikon ninja nissan nissay nl no nokia northwesternmutual
    norton now nowruz nowtv np nr nra nrw ntt nu nyc nz obi observer off office okinawa olayan olayangroup oldnavy ollo om omega one ong onl online onyourside ooo open oracle orange org organic
    origins osaka otsuka ott ovh pa page pamperedchef panasonic panerai paris pars partners parts party passagens pay pccw pe pet pf pfizer pg ph pharmacy phd philips phone photo photography photos
    physio piaget pics pictet pictures pid pin ping pink pioneer pizza pk pl place play playstation plumbing plus pm pn pnc pohl poker politie porn post pr pramerica praxi press prime pro prod
    productions prof progressive promo properties property protection pru prudential ps pt pub pw pwc py qa qpon quebec quest qvc racing radio raid re read realestate realtor realty recipes red
    redstone redumbrella rehab reise reisen reit reliance ren rent rentals repair report republican rest restaurant review reviews rexroth rich richardli ricoh rightathome ril rio rip rmit ro rocher
    rocks rodeo rogers room rs rsvp ru rugby ruhr run rw rwe ryukyu sa saarland safe safety sakura sale salon samsclub samsung sandvik sandvikcoromant sanofi sap sapo sarl sas save saxo sb sbi sbs sc
    sca scb schaeffler schmidt scholarships school schule schwarz science scjohnson scor scot sd se search seat secure security seek select sener services ses seven sew sex sexy sfr sg sh shangrila
    sharp shaw shell shia shiksha shoes shop shopping shouji show showtime shriram si silk sina singles site sj sk ski skin sky skype sl sling sm smart smile sn sncf so soccer social softbank
    software sohu solar solutions song sony soy space spiegel spot spreadbetting sr srl srt st stada staples star starhub statebank statefarm statoil stc stcgroup stockholm storage store stream
    studio study style su sucks supplies supply support surf surgery suzuki sv swatch swiftcover swiss sx sy sydney symantec systems sz tab taipei talk taobao target tatamotors tatar tattoo tax taxi
    tc tci td tdk team tech technology tel telecity telefonica temasek tennis teva tf tg th thd theater theatre tiaa tickets tienda tiffany tips tires tirol tj tjmaxx tjx tk tkmaxx tl tm tmall tn to
    today tokyo tools top toray toshiba total tours town toyota toys tr trade trading training travel travelchannel travelers travelersinsurance trust trv tt tube tui tunes tushu tv tvs tw tz ua
    ubank ubs uconnect ug uk unicom university uno uol ups us uy uz va vacations vana vanguard vc ve vegas ventures verisign versicherung vet vg vi viajes video vig viking villas vin vip virgin visa
    vision vista vistaprint viva vivo vlaanderen vn vodka volkswagen volvo vote voting voto voyage vu vuelos wales walmart walter wang wanggou warman watch watches weather weatherchannel webcam weber
    website wed wedding weibo weir wf whoswho wien wiki williamhill win windows wine winners wme wolterskluwer woodside work works world wow ws wtc wtf xbox xerox xfinity xihuan xin xn--11b4c3d
    xn--1ck2e1b xn--1qqw23a xn--2scrj9c xn--30rr7y xn--3bst00m xn--3ds443g xn--3e0b707e xn--3hcrj9c xn--3oq18vl8pn36a xn--3pxu8k xn--42c2d9a xn--45br5cyl xn--45brj9c xn--45q11c xn--4gbrim
    xn--54b7fta0cc xn--55qw42g xn--55qx5d xn--5su34j936bgsg xn--5tzm5g xn--6frz82g xn--6qq986b3xl xn--80adxhks xn--80ao21a xn--80aqecdr1a xn--80asehdb xn--80aswg xn--8y0a063a xn--90a3ac xn--90ae
    xn--90ais xn--9dbq2a xn--9et52u xn--9krt00a xn--b4w605ferd xn--bck1b9a5dre4c xn--c1avg xn--c2br7g xn--cck2b3b xn--cg4bki xn--clchc0ea0b2g2a9gcd xn--czr694b xn--czrs0t xn--czru2d xn--d1acj3b
    xn--d1alf xn--e1a4c xn--eckvdtc9d xn--efvy88h xn--estv75g xn--fct429k xn--fhbei xn--fiq228c5hs xn--fiq64b xn--fiqs8s xn--fiqz9s xn--fjq720a xn--flw351e xn--fpcrj9c3d xn--fzc2c9e2c
    xn--fzys8d69uvgm xn--g2xx48c xn--gckr3f0f xn--gecrj9c xn--gk3at1e xn--h2breg3eve xn--h2brj9c xn--h2brj9c8c xn--hxt814e xn--i1b6b1a6a2e xn--imr513n xn--io0a7i xn--j1aef xn--j1amh xn--j6w193g
    xn--jlq61u9w7b xn--jvr189m xn--kcrx77d1x4a xn--kprw13d xn--kpry57d xn--kpu716f xn--kput3i xn--l1acc xn--lgbbat1ad8j xn--mgb9awbf xn--mgba3a3ejt xn--mgba3a4f16a xn--mgba7c0bbn0a xn--mgbaakc7dvf
    xn--mgbaam7a8h xn--mgbab2bd xn--mgbai9azgqp6j xn--mgbayh7gpa xn--mgbb9fbpob xn--mgbbh1a xn--mgbbh1a71e xn--mgbc0a9azcg xn--mgbca7dzdo xn--mgberp4a5d4ar xn--mgbgu82a xn--mgbi4ecexp xn--mgbpl2fh
    xn--mgbt3dhd xn--mgbtx2b xn--mgbx4cd0ab xn--mix891f xn--mk1bu44c xn--mxtq1m xn--ngbc5azd xn--ngbe9e0a xn--ngbrx xn--node xn--nqv7f xn--nqv7fs00ema xn--nyqy26a xn--o3cw4h xn--ogbpf8fl xn--p1acf
    xn--p1ai xn--pbt977c xn--pgbs0dh xn--pssy2u xn--q9jyb4c xn--qcka1pmc xn--qxam xn--rhqv96g xn--rovu88b xn--rvc1e0am3e xn--s9brj9c xn--ses554g xn--t60b56a xn--tckwe xn--tiq49xqyj xn--unup4y
    xn--vermgensberater-ctb xn--vermgensberatung-pwb xn--vhquv xn--vuq861b xn--w4r85el8fhu5dnra xn--w4rs40l xn--wgbh1c xn--wgbl6a xn--xhq521b xn--xkc2al3hye2a xn--xkc2dl3a5ee0h xn--y9a3aq
    xn--yfro4i67o xn--ygbi2ammx xn--zfr164b xperia xxx xyz yachts yahoo yamaxun yandex ye yodobashi yoga yokohama you youtube yt yun za zappos zara zero zip zippo zm zone zuerich zw)
  DOMAIN_REGEX = Regexp.new('https?://\w[\w\-\.]+\.(' + TOP_LEVEL_DOMAINS.join('|') + ')')
  DOMAIN_OR_IMAGES_REGEX = Regexp.new('\/images|' + DOMAIN_REGEX.to_s)
  URI_REGEX = Regexp.new(DOMAIN_OR_IMAGES_REGEX.to_s + '/[\w\-\.\/]*[\w\-]\.(' + ArchiveConfig.SUPPORTED_EXTERNAL_URLS.join('|') + ')')
  URL_REGEX = Regexp.new(URI_REGEX.to_s + '|"' + URI_REGEX.to_s + '"|\'' + URI_REGEX.to_s + '\'')
  URL_FUNCTION_REGEX = Regexp.new('url\(\s*' + URL_REGEX.to_s + '\s*\)')

  VALUE_REGEX = Regexp.new("#{TRANSFORM_FUNCTION_REGEX}|#{URL_FUNCTION_REGEX}|#{COLOR_STOP_FUNCTION_REGEX}|#{COLOR_REGEX}|#{NUMBER_WITH_UNIT_REGEX}|#{ALPHA_REGEX}|#{SHAPE_FUNCTION_REGEX}")


  # For use in ActiveRecord models
  # We parse and clean the CSS line by line in order to provide more helpful error messages.
  # The prefix is used if you want to make sure a particular prefix appears on all the selectors in
  # this block of css, eg ".userstuff p" instead of just "p"
  def clean_css_code(css_code, options = {})
    return "" if !css_code.match(/\w/) # only spaces of various kinds
    clean_css = ""
    parser = CssParser::Parser.new
    parser.add_block!(css_code)

    prefix = options[:prefix] || ''
    caller_check = options[:caller_check]

    if parser.to_s.blank?
      errors.add(:base, ts("We couldn't find any valid CSS rules in that code."))
    else
      parser.each_rule_set do |rs|
        selectors = rs.selectors.map do |selector|
          if selector.match(/@font-face/i)
            errors.add(:base, ts("We don't allow the @font-face feature."))
            next
          end
          # remove whitespace and convert &gt; entities back to the > direct child selector
          sel = selector.gsub(/\n/, '').gsub('&gt;', '>').strip
          (prefix.blank? || sel.start_with?(prefix)) ? sel : "#{prefix} #{sel}"
        end
        clean_declarations = ""
        rs.each_declaration do |property, value, is_important|
          if property.blank? || value.blank?
            errors.add(:base, ts("The code for #{rs.selectors.join(',')} doesn't seem to be a valid CSS rule."))
          elsif sanitize_css_property(property).blank?
            errors.add(:base, ts("We don't currently allow the CSS property #{property} -- please notify support if you think this is an error."))
          elsif (cleanval = sanitize_css_declaration_value(property, value)).blank?
            errors.add(:base, ts("The #{property} property in #{rs.selectors.join(', ')} cannot have the value #{value}, sorry!"))
          elsif (!caller_check || caller_check.call(rs, property, value))
            clean_declarations += "  #{property}: #{cleanval}#{is_important ? ' !important' : ''};\n"
          end
        end
        if clean_declarations.blank?
          errors.add(:base, ts("There don't seem to be any rules for #{rs.selectors.join(',')}"))
        else
          # everything looks ok, add it to the css
          clean_css += "#{selectors.join(",\n")} {\n"
          clean_css += clean_declarations
          clean_css += "}\n\n"
        end
      end
    end
    return clean_css
  end

  def is_legal_property(property)
    ArchiveConfig.SUPPORTED_CSS_PROPERTIES.include?(property) ||
      property.match(/-(#{PREFIX_REGEX})-(#{ArchiveConfig.SUPPORTED_CSS_PROPERTIES.join('|')})/)
  end

  def is_legal_shorthand_property(property)
    property.match(/#{ArchiveConfig.SUPPORTED_CSS_SHORTHAND_PROPERTIES.join('|')}/)
  end

  def sanitize_css_property(property)
    return (is_legal_property(property) || is_legal_shorthand_property(property)) ? property : ""
  end

  # A declaration must match the format:   property: value;
  # All properties must appear in ArchiveConfig.SUPPORTED_CSS_PROPERTIES or ArchiveConfig.SUPPORTED_CSS_SHORTHAND_PROPERTIES,
  # or that property and its value will be omitted.
  # All values are sanitized. If any values in a declaration are invalid, the value will be blanked out and an
  #   empty property returned.
  def sanitize_css_declaration_value(property, value)
    clean = ""
    property.downcase!
    if property == "font-family"
      if !sanitize_css_font(value).blank?
        # preserve the original capitalization
        clean = value
      end
    elsif property == "content"
      clean = sanitize_css_content(value)
    elsif value.match(/\burl\b/) && (!ArchiveConfig.SUPPORTED_CSS_KEYWORDS.include?("url") || !%w(background background-image border border-image list-style list-style-image).include?(property))
      # check whether we can use urls in this property
      clean = ""
    elsif is_legal_shorthand_property(property)
      clean = tokenize_and_sanitize_css_value(value)
    elsif is_legal_property(property)
      clean = sanitize_css_value(value)
    end
    clean.strip
  end

  # divide a css value into tokens and clean them individually
  def tokenize_and_sanitize_css_value(value)
    cleanval = ""
    scanner = StringScanner.new(value)

    # we scan until we find either a space, a comma, or an open parenthesis
    while scanner.exist?(/\s+|,|\(/)
      # we have some tokens left to break up
      in_paren = 0
      token = scanner.scan_until(/\s+|,|\(/)
      if token.blank? || token == ","
        cleanval += token
        next
      end
      in_paren = 1 if token.match(/\($/)
      while in_paren > 0
        # scan until closing paren or another opening paren
        nextpart = scanner.scan_until(/\(|\)/)
        if nextpart
          token += nextpart
          in_paren += 1 if token.match(/\($/)
          in_paren -= 1 if token.match(/\)$/)
        else
          # mismatched parens
          return ""
        end
      end

      # we now have a single token
      separator = token.match(/(\s|,)$/) || ""
      token.strip!
      token.chomp!(',')
      cleantoken = sanitize_css_token(token)
      return "" if cleantoken.blank?
      cleanval += cleantoken + separator.to_s
    end

    token = scanner.rest
    if token && !token.blank?
      cleantoken = sanitize_css_token(token)
      return "" if cleantoken.blank?
      cleanval += cleantoken
    end

    return cleanval
  end

  def sanitize_css_token(token)
    cleantoken = ""
    if token.match(/gradient/)
      cleantoken = sanitize_css_gradient(token)
    else
      cleantoken = sanitize_css_value(token)
    end
    return cleantoken
  end

  # sanitize a CSS gradient
  # background:-webkit-gradient( linear, left bottom, left top, color-stop(0, rgb(82,82,82)), color-stop(1, rgb(125,124,125)));
  # -moz-linear-gradient(bottom, rgba(120,120,120,1) 5%, rgba(94,94,94,1) 50%, rgba(108,108,108,1) 55%, rgba(137,137,137,1) 100%);
  def sanitize_css_gradient(value)
    if value.match(/^([a-z\-]+)\((.*)\)/)
      function = $1
      interior = $2
      cleaned_interior = tokenize_and_sanitize_css_value(interior)
      if function.match(/gradient/) && !cleaned_interior.blank?
        return "#{function}(#{cleaned_interior})"
      end
    end
    return ""
  end


  # all values must either appear in ArchiveConfig.SUPPORTED_CSS_KEYWORDS, be urls of the format url(http://url/) or be
  # rgba(), hex (#), or numeric values, or a comma-separated list of same
  def sanitize_css_value(value)
    value_stripped = value.downcase.gsub(/(!important)/, '').strip

    # if it's a comma-separated set of valid values it's fine
    return value if value_stripped =~ /^(#{VALUE_REGEX}\,?)+$/i

    # If it's explicitly in our keywords it's fine
    return value if value_stripped.split(',').all? {|subval| ArchiveConfig.SUPPORTED_CSS_KEYWORDS.include?(subval.strip)}

    return ""
  end


  def sanitize_css_content(value)
    # For now we only allow a single completely quoted string
    return value if value =~ /^\'([^\']*)\'$/
    return value if value =~ /^\"([^\"]*)\"$/

    # or a valid img url
    return value if value.match(URL_FUNCTION_REGEX)

    # or "none"
    return value if value == "none"

    return ""
  end


  # Font family names may be alphanumeric values with dashes
  def sanitize_css_font(value)
    value_stripped = value.downcase.gsub(/(!important)/, '').strip
    if value_stripped.split(',').all? {|fontname| fontname.strip =~ /^(\'?[a-z0-9\- ]+\'?|\"?[a-z0-9\- ]+\"?)$/}
      return value
    else
      return ""
    end
  end


end
